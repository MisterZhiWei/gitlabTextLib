//
//  SCWhiteBoardSocketManager.m
//  WhiteBoard
//
//  Created by 胡浩 on 2019/9/2.
//  Copyright © 2019 胡浩. All rights reserved.
//

#import "SCWhiteBoardSocketManager.h"
#import "SocketMessage.pbobjc.h"

NSString * const SCWhiteBoardSocketManagerEnterNotification = @"SCWhiteBoardSocketManagerEnterNotification";
NSString * const SCWhiteBoardSocketManagerDataNotification = @"SCWhiteBoardSocketManagerDataNotification";
NSString * const SCWhiteBoardSocketManagerHistoryNotification = @"SCWhiteBoardSocketManagerHistoryNotification";
NSString * const SCWhiteBoardSocketManagerStartNotification = @"SCWhiteBoardSocketManagerStartNotification";
NSString * const SCWhiteBoardSocketManagerEndNotification = @"SCWhiteBoardSocketManagerEndNotification";
NSString * const SCWhiteBoardSocketManagerFailedNotification = @"SCWhiteBoardSocketManagerFailedNotification";

//static NSString * const kGatewayURL = @"ws://10.12.4.112:8791"; ///< 测试地址
static NSString * const kWhiteBoardGatewayURL = @"ws://123.56.17.157:8791"; ///< 临时给的地址
static NSString * const kWhiteBoardAccessKeyID = @"20190801";
static NSString * const kWhiteBoardAccessSecret = @"exEY96NT/FfXvPreWHO+sKDvS0YGD35/LJOZfl4xq9k=";

static NSString * const kWhiteBoardHostAPIURL = @"http://10.12.4.112:8991";
static NSString * const kWhiteBoardAPIPathURL = @"/api/room/accesstoken";

@interface SCWhiteBoardSocketManager () <SRWebSocketDelegate>

@property (nonatomic, strong) SRWebSocket *webSocket;
@property (nonatomic, strong) dispatch_source_t loopHeartTimer;
@property (nonatomic, copy) NSURL *socketURL;

@end

@implementation SCWhiteBoardSocketManager {
    NSInteger _notReceivedMessageNum; ///< 未收到消息次数
}

+ (instancetype)sharedManager {
    static SCWhiteBoardSocketManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SCWhiteBoardSocketManager alloc] init];
        
    });
    
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _notReceivedMessageNum = 0;
    }
    
    return self;
}

- (void)openWithURL:(NSURL *)url {
    self.socketURL = url;
    SRWebSocket *webSocket = [[SRWebSocket alloc] initWithURL:url];
    webSocket.delegate = self;
    [webSocket open];
    self.webSocket = webSocket;
}

- (void)close {
    [self.webSocket close];
    self.webSocket = nil;
    dispatch_source_cancel(self.loopHeartTimer);
}

- (void)sendData:(id)data {
    if (self.readyState == SR_OPEN) {
        [self.webSocket send:data];
    }
}

#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSDictionary *dict = (__bridge_transfer NSDictionary *)CFHTTPMessageCopyAllHeaderFields(webSocket.receivedHTTPHeaders);
    //     CFStringRef cffStr = CFHTTPMessageCopyHeaderFieldValue(webSocket.receivedHTTPHeaders, CFSTR("X-Response-Message"));
    //    NSString *info = (__bridge NSString *)cffStr;
    //    NSLog(@"%@", info);
    NSLog(@"%@", dict);
    
    if (dict[@"X-Response-Message"] && [dict[@"X-Response-Message"] isKindOfClass:NSString.class]) {
        NSString *errorMsg = dict[@"X-Response-Message"];
        if ([errorMsg isEqualToString:@"token parse failed"]) {
            NSLog(@"accessToken错误, 解析失败");
            // 需要重新获取token
            
        } else if ([errorMsg isEqualToString:@"param error"] || [errorMsg isEqualToString:@"token or roomid empty"]) {
            NSLog(@"roomid或token参数为空");
            // 需要检查参数，并重新设置参数，重新进行连接
            
        } else if ([errorMsg isEqualToString:@"token check failed"]) {
            NSLog(@"accessToken解析成功, 但验证失败, 有可能已经过期或不属于当前roomID");
            // 需要重新获取token
            
        }
    }
    
    // 建立心跳
    [self loopHeartbeat];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"连接失败");
    NSDictionary *userInfo = @{@"error" : error};
    [[NSNotificationCenter defaultCenter] postNotificationName:SCWhiteBoardSocketManagerFailedNotification object:nil userInfo:userInfo];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self openWithURL:self.socketURL];
    });
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    
//    NSLog(@"************************** socket连接断开************************** ");
//    NSLog(@"被关闭连接，code:%ld,reason:%@,wasClean:%d",(long)code,reason,wasClean);
//
//    NSError *error = [NSError errorWithDomain:@"被关闭连接" code:code userInfo:@{NSLocalizedFailureReasonErrorKey : reason}];
//    NSDictionary *userInfo = @{@"error" : error};
//    [[NSNotificationCenter defaultCenter] postNotificationName:SCWhiteBoardSocketManagerFailedNotification object:nil userInfo:userInfo];
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self openWithURL:self.socketURL];
//    });
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    if ([message isKindOfClass:NSData.class]) {
        NSError *error = nil;
        SCSocketMessage *socketMessage = [SCSocketMessage parseFromData:(NSData *)message
                                                                  error:&error];
        
        if (error) {
            NSLog(@"PB数据解析错误");
        } else {
            
            if (SCScoketMessageType_IsValidValue(socketMessage.type)) {
                switch (socketMessage.type) {
                    case SCScoketMessageType_Unknown:
                        NSLog(@"默认未知类型");
                        break;
                        
                    case SCScoketMessageType_Heartbeat:
                        NSLog(@"收到心跳消息");
                        _notReceivedMessageNum = 0;
                        break;
                        
                    case SCScoketMessageType_Kicked: // 预留消息类型，目前没用到。
                        NSLog(@"强制断开消息");
                        break;
                        
                    case SCScoketMessageType_Patch:
                        break;
                        
                    case SCScoketMessageType_Failed:
                        NSLog(@"消息发送失败");
                        break;
                        
                    case SCScoketMessageType_Receipt:
                        break;
                        
                    default:
                        [[NSNotificationCenter defaultCenter] postNotificationName:SCWhiteBoardSocketManagerDataNotification
                                                                            object:nil
                                                                          userInfo:@{@"socketMessage":socketMessage}];
                        break;
                }
                
            }
        }
    }
}

#pragma mark - Private Methods

/// 创建心跳
- (void)loopHeartbeat {
    if (self.loopHeartTimer) {
        dispatch_source_cancel(self.loopHeartTimer);
        self.loopHeartTimer = nil;
    }
    
    self.loopHeartTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)2 * NSEC_PER_SEC);
    uint64_t duration = (uint64_t)(10.0 * NSEC_PER_SEC);
    dispatch_source_set_timer(self.loopHeartTimer, start, duration, 0);
    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(self.loopHeartTimer, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf->_notReceivedMessageNum >= 2) {
            dispatch_source_cancel(strongSelf.loopHeartTimer);
            [strongSelf.webSocket close];
            strongSelf->_notReceivedMessageNum = 0;
            [strongSelf openWithURL:strongSelf.socketURL];
        } else {
            SCSocketMessage *socketMessage = [[SCSocketMessage alloc] init];
            socketMessage.type = SCScoketMessageType_Heartbeat;
            [strongSelf.webSocket send:socketMessage.data];
            NSLog(@"发送心跳");
            strongSelf->_notReceivedMessageNum++;
        }
    });
    dispatch_resume(self.loopHeartTimer);
}

#pragma mark - Getter Methods

- (SRReadyState)readyState {
    return self.webSocket.readyState;
}

@end
