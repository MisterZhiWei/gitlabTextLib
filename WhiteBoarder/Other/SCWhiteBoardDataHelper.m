//
//  SCWhiteBoardDataHelper.m
//  WhiteBoard
//
//  Created by 胡浩 on 2019/8/26.
//  Copyright © 2019 胡浩. All rights reserved.
//

#import "SCWhiteBoardDataHelper.h"
#import "SCWhiteBoardPoint.h"
#import <UIColor+YYAdd.h>
#import "SCWhiteBoardSocketManager.h"
#import "SocketMessage.pbobjc.h"

static const NSUInteger kTransformTiggerNum = 10; ///< 触发传输的数据数量

@interface SCWhiteBoardDataHelper ()

@property (nonatomic, copy) NSString *gatewayURL;
@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *lessonNum;

@property (nonatomic, strong) NSMutableArray<SCWhiteBoardPoint *> *points;
@property (nonatomic, assign) NSInteger history_count; ///< 历史数据总量

@end

@implementation SCWhiteBoardDataHelper

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithClassID:(NSString *)classID
                            uid:(NSString *)uid
                      lessonNum:(NSString *)lessonNum
                     gatewayUrl:(NSString *)wsUrl {
    _gatewayURL = wsUrl.copy;
    _roomID = classID.copy;
    _uid = uid.copy;
    _lessonNum = lessonNum.copy;
    return [self init];
}

- (instancetype)init {
    if (self = [super init]) {
        _points = [NSMutableArray array];
        
        NSString *roomid = self.roomID;
        NSString *uid = self.uid;
        NSString *lessonNum = self.lessonNum;
        NSString *gatewayUrl = self.gatewayURL;
        
        NSString *socketURL = [NSString stringWithFormat:@"%@?token=1&roomid=%@&uid=%@", gatewayUrl,[NSString stringWithFormat:@"%@:%@",roomid,lessonNum], uid];
        NSURL *url = [NSURL URLWithString:socketURL];
        [[SCWhiteBoardSocketManager sharedManager] openWithURL:url];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receivedDataNotification:)
                                                     name:SCWhiteBoardSocketManagerDataNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(socketFailedNotification:)
                                                     name:SCWhiteBoardSocketManagerFailedNotification
                                                   object:nil];
    }
    
    return self;
}

#pragma mark - Events
- (void)entryRoomUserInfo:(NSDictionary *)userInfo {
    NSLog(@"第%@次涂鸦", userInfo[@"index"]);
    
    NSInteger index = -1;
    if ([userInfo[@"index"] isKindOfClass:NSNumber.class]) {
        index = ((NSNumber *)userInfo[@"index"]).integerValue;
    }
    
    BOOL status = NO;
    if (userInfo[@"status"] && [userInfo[@"status"] isKindOfClass:NSNumber.class]) {
        status = ((NSNumber *)userInfo[@"status"]).boolValue;
    }
    
    NSInteger history_count = -1;
    if (userInfo[@"history_count"] && [userInfo[@"history_count"] isKindOfClass:NSNumber.class]) {
        history_count = ((NSNumber *)userInfo[@"history_count"]).integerValue;
    }
    self.history_count = history_count;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(whiteBoardDataHelper:index:status:userinfo:)]) {
        [self.delegate whiteBoardDataHelper:self
                                      index:index
                                     status:status
                                   userinfo:userInfo];
    }
}

- (void)startDrawing{
    if (self.delegate && [self.delegate respondsToSelector:@selector(whiteBoardDidStart:)]) {
        [self.delegate whiteBoardDidStart:self];
    }
}

- (void)endDrawing{
    if (self.delegate && [self.delegate respondsToSelector:@selector(whiteBoardDidEnd:)]) {
        [self.delegate whiteBoardDidEnd:self];
    }
}

- (void)receivedDataNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    SCSocketMessage *socketMessage = userInfo[@"socketMessage"];
    
    if (SCScoketMessageType_IsValidValue(socketMessage.type)) {
        switch (socketMessage.type) {
                
            case SCScoketMessageType_Enter: {
                NSLog(@"进入房间成功");
                NSArray<NSString *> *jsons = [self getContentJsons:socketMessage];
                [jsons enumerateObjectsUsingBlock:^(NSString * _Nonnull json, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
                    NSError *jsonError = nil;
                    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                         options:NSJSONReadingAllowFragments
                                                                           error:&jsonError];
                    
                    if (!jsonError) {
                        [self entryRoomUserInfo:dict];
                    }
                }];
            }
                break;
            case SCScoketMessageType_Data: {
                NSLog(@"收到数据");
                
                int64_t msgid = socketMessage.bodyArray.lastObject.msgid;
                NSArray<NSString *> *jsons = [self getContentJsons:socketMessage];
                NSDictionary *userInfo = @{@"jsons" : jsons,
                                           @"msgid" : @(msgid)
                                           };
                [self receivedPointData:userInfo];
            }
                
                break;
            case SCScoketMessageType_History: {
                // 只有发送过开始涂鸦的命令才会收到历史数据
                NSLog(@"收到历史数据");
                
                NSArray<NSString *> *jsons = [self getContentJsons:socketMessage];
                int64_t msgid = socketMessage.bodyArray.lastObject.msgid;
                NSDictionary *userInfo = @{@"jsons" : jsons,
                                           @"msgid" : @(msgid)
                                           };
                [self receivedHistoryData:userInfo];
            }
                break;
                
            case SCScoketMessageType_Start:
                // 状态通知
                NSLog(@"开始涂鸦");
                [self startDrawing];
                break;
                
            case SCScoketMessageType_End:
                // 状态通知
                NSLog(@"关闭涂鸦");
                [self endDrawing];
                break;
                
                
            case SCScoketMessageType_Image:{
                // 更换背景
                NSArray<NSString *> *jsons = [self getContentJsons:socketMessage];
                [self receivedBackImageJsons:jsons];
            }
                break;
                
            case SCScoketMessageType_Cleanup:
                // 清屏
                
                break;
                
            case SCScoketMessageType_GPBUnrecognizedEnumeratorValue:
                NSLog(@"未知类型");
                break;
        }
    }
    
}

- (void)receivedBackImageJsons:(NSArray *)jsons{
    if (jsons) {
        __weak typeof(self) weakSelf = self;
        [jsons enumerateObjectsUsingBlock:^(NSString * _Nonnull json, NSUInteger idx, BOOL * _Nonnull stop) {
            __strong typeof(self) strongSelf = weakSelf;
            NSDictionary *userinfo = [strongSelf dictionaryWithJsonString:json];
            if (userinfo) {
                NSString *userid = [userinfo objectForKey:@"userid"] ? [NSString stringWithFormat:@"%@",[userinfo objectForKey:@"userid"]] : @"";
                NSString *imageUrl = [userinfo objectForKey:@"image_url"] ? [NSString stringWithFormat:@"%@",[userinfo objectForKey:@"image_url"]] : @"";
                if (![userid isEqualToString:strongSelf.uid]) {
                    if ([strongSelf.delegate respondsToSelector:@selector(whiteBoardAddBackImage:)]) {
                        [strongSelf.delegate whiteBoardAddBackImage:imageUrl];
                    }
                }
            }
        }];
    }
}

- (void)receivedPointData:(NSDictionary *)userInfo{
    NSArray<NSString *> *jsons = userInfo[@"jsons"];
    
    if (jsons) {
        __weak typeof(self) weakSelf = self;
        [jsons enumerateObjectsUsingBlock:^(NSString * _Nonnull json, NSUInteger idx, BOOL * _Nonnull stop) {
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf parseWithJson:json completion:^(NSString *uid, NSInteger action_type, NSArray<SCWhiteBoardPoint *> *points, NSDictionary *info, NSError *error) {
                if (![uid isEqualToString:self.uid]) {
                    if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(whiteBoardDataHelper:uid:action_type:points:isHistoryData:error:)]) {
                        [strongSelf.delegate whiteBoardDataHelper:strongSelf
                                                              uid:uid
                                                      action_type:action_type
                                                           points:points
                                                    isHistoryData:NO
                                                            error:error];
                    }
                }
            }];
        }];
    }
}

- (NSArray<NSString *> *)getContentJsons:(SCSocketMessage *)socketMessage {
    NSMutableArray<NSString *> *jsons = [NSMutableArray array];
    [socketMessage.bodyArray enumerateObjectsUsingBlock:^(SCSocketContentMessage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //        NSLog(@"消息id为:%lld", obj.msgid);
        [obj.contentArray enumerateObjectsUsingBlock:^(NSString * _Nonnull json, NSUInteger idx, BOOL * _Nonnull stop) {
            [jsons addObject:json];
        }];
    }];
    
    return jsons.copy;
}

- (void)receivedHistoryData:(NSDictionary *)userInfo {
    NSArray<NSString *> *jsons = userInfo[@"jsons"];
    
    NSInteger msgid = ((NSNumber *)userInfo[@"msgid"]).integerValue;
    // 如果未收到全量历史数据则不做处理
    if (msgid < self.history_count) {
        return;
    }
    
    // 处理后的数据
    NSArray<NSString *> *handleJsons = [self parseHistoryWithJsons:jsons];
    __weak typeof(self) weakSelf = self;
    [handleJsons enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf parseWithJson:obj completion:^(NSString *uid, NSInteger action_type, NSArray<SCWhiteBoardPoint *> *points, NSDictionary *info, NSError *error) {
            if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(whiteBoardDataHelper:uid:action_type:points:isHistoryData:error:)]) {
                [strongSelf.delegate whiteBoardDataHelper:strongSelf
                                                      uid:uid
                                              action_type:action_type
                                                   points:points
                                            isHistoryData:YES
                                                    error:error];
            }
        }];
    }];
}

- (void)socketFailedNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSError *error = userInfo[@"error"];
    if (self.delegate && [self.delegate respondsToSelector:@selector(whiteBoardDataHelper:didFailed:)]) {
        [self.delegate whiteBoardDataHelper:self
                                  didFailed:error];
    }
}

#pragma mark - Public Methods
- (void)sendDataWithWhiteBoardPointData:(SCWhiteBoardPoint *)point
                            action_type:(SCWhiteBoardDataActionType)action_type {
    void(^task)(NSInteger action_type_data) = ^void (NSInteger action_type_data) {
        NSMutableArray<SCWhiteBoardPoint *> *removePoints = [NSMutableArray array];
        NSMutableArray<NSDictionary *> *pointsData = [NSMutableArray arrayWithCapacity:self.points.count];
        [self.points enumerateObjectsUsingBlock:^(SCWhiteBoardPoint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *point = @{@"t" : @(obj.type),
                                    @"pro_x" : @(obj.proportion_x),
                                    @"pro_y" : @(obj.proportion_y),
                                    @"w" : @(obj.width),
                                    @"c" : obj.color.hexString
                                    };
            [pointsData addObject:point];
            [removePoints addObject:obj];
        }];
        
        NSDictionary *json = @{@"uid" : self.uid,
                               @"content" : @{@"action_type" : @(action_type_data), // 操作类型 划线 撤销 清屏
                                              @"points" : pointsData.copy}
                               };
        
        if ([NSJSONSerialization isValidJSONObject:json]) {
            NSError *jsonError;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:&jsonError];
            NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            if (!jsonError) {
                [self.points removeObjectsInArray:removePoints];
                
                SCSocketMessage *socketMessage = [[SCSocketMessage alloc] init];
                socketMessage.type = SCScoketMessageType_Data;
                
                SCSocketContentMessage *contentMessage = [[SCSocketContentMessage alloc] init];
                contentMessage.roomid = self.roomID;
                [contentMessage.contentArray addObject:jsonStr];
                
                [socketMessage.bodyArray addObject:contentMessage];
                [[SCWhiteBoardSocketManager sharedManager] sendData:socketMessage.data];
                NSLog(@"发送数据");
            }
        }
    };
    
    switch (action_type) {
        case SCWhiteBoardDataActionTypeDraw: {
            if (point.type == SCWhiteBoardPointTypeEnded) {
                task(SCWhiteBoardDataActionTypeDraw);
            }
            
            [self.points addObject:point];
            switch (point.type) {
                case SCWhiteBoardPointTypeBegan:
                    task(SCWhiteBoardDataActionTypeDraw);
                    break;
                case SCWhiteBoardPointTypeMoved:
                    if (self.points.count >= kTransformTiggerNum) {
                        //                        NSLog(@"已达到发送量，准备发送数据");
                        task(SCWhiteBoardDataActionTypeDraw);
                    }
                    
                    //                    if (point.timestamp - self.points.firstObject.timestamp > 200.0) {
                    //                        NSLog(@"已达到发送量，准备发送数据");
                    //                        task(SCWhiteBoardDataActionTypeDraw);
                    //                    }
                    
                    break;
                case SCWhiteBoardPointTypeEnded:
                    task(SCWhiteBoardDataActionTypeDraw);
                    break;
            }
            
        }
            
            break;
        case SCWhiteBoardDataActionTypeUndo: {
            if (self.points.count > 0) {
                task(SCWhiteBoardDataActionTypeDraw);
            }
            
            task(SCWhiteBoardDataActionTypeUndo);
        }
            
            break;
        case SCWhiteBoardDataActionTypeClean: {
            if (self.points.count > 0) {
                task(SCWhiteBoardDataActionTypeDraw);
            }
            
            task(SCWhiteBoardDataActionTypeClean);
        }
            
            break;
            
        default:
            break;
    }
}

- (void)sendDataWithWhiteBoardBackImageUrl:(NSString *)imageUrl
                               action_type:(SCWhiteBoardDataActionType)action_type{
    SCSocketMessage *socketMessage = [[SCSocketMessage alloc] init];
    socketMessage.type = SCScoketMessageType_Image;
    
    SCSocketContentMessage *contentMessage = [[SCSocketContentMessage alloc] init];
    [contentMessage.contentArray addObject:[NSString stringWithFormat:@"{\"image_url\":\"%@\",\"userid\":\"%@\"}",imageUrl,self.uid]];
    
    [socketMessage.bodyArray addObject:contentMessage];
    [[SCWhiteBoardSocketManager sharedManager] sendData:socketMessage.data];
}

- (void)sendStartDataMessageWithType:(NSString *)interactType {
    SCSocketMessage *socketMessage = [[SCSocketMessage alloc] init];
    socketMessage.type = SCScoketMessageType_Start;
    
    SCSocketContentMessage *contentMessage = [[SCSocketContentMessage alloc]init];
    [contentMessage.contentArray addObject:[NSString stringWithFormat:@"{\"interact\":\"%@\"}",interactType]];
    
    [socketMessage.bodyArray addObject:contentMessage];
    [[SCWhiteBoardSocketManager sharedManager] sendData:socketMessage.data];
}

- (void)sendEndDataMessage {
    SCSocketMessage *socketMessage = [[SCSocketMessage alloc] init];
    socketMessage.type = SCScoketMessageType_End;
    [[SCWhiteBoardSocketManager sharedManager] sendData:socketMessage.data];
}

- (void)sendCleanScreenMessage{
    SCSocketMessage *socketMessage = [[SCSocketMessage alloc] init];
    socketMessage.type = SCScoketMessageType_Cleanup;
    [[SCWhiteBoardSocketManager sharedManager] sendData:socketMessage.data];
}

- (void)closeDrawing {
    [[SCWhiteBoardSocketManager sharedManager] close];
}

#pragma mark - Private Methods
- (void)parseWithJson:(NSString *)jsonStr
           completion:(void (^)(NSString *, NSInteger, NSArray<SCWhiteBoardPoint *> *, NSDictionary *, NSError *))completion {
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *jsonError = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                         options:NSJSONReadingAllowFragments
                                                           error:NULL];
    NSInteger action_type = -1;
    NSMutableArray<SCWhiteBoardPoint *> *points = nil;
    NSDictionary *info = nil;
    
    if (jsonError) {
        if (completion) {
            completion(nil, action_type, nil,nil, jsonError);
        }
    } else {
        NSString *uid = nil;
        if (dict[@"uid"] && [dict[@"uid"] isKindOfClass:NSString.class]) {
            uid = dict[@"uid"];
        }
        
        if (uid.length == 0 || !uid) {
            NSError *error = [NSError errorWithDomain:@"uid为空"
                                                 code:-1
                                             userInfo:nil];
            if (completion) {
                completion(nil, action_type, nil,nil, error);
            }
            
            return;
        }
        
        if (dict[@"content"][@"action_type"] && [dict[@"content"][@"action_type"] isKindOfClass:NSNumber.class]) {
            action_type = ((NSNumber *)dict[@"content"][@"action_type"]).integerValue;
        }
        
        if (dict[@"content"][@"info"] &&  [dict[@"content"][@"action_type"] isKindOfClass:NSDictionary.class]) {
            info = dict[@"content"][@"info"];
        }
        
        if (action_type < 0) {
            NSError *error = [NSError errorWithDomain:@"action_type错误"
                                                 code:-2
                                             userInfo:nil];
            if (completion) {
                completion(nil, action_type, nil,nil, error);
            }
        } else {
            if (dict[@"content"][@"points"] && [dict[@"content"][@"points"] isKindOfClass:NSArray.class]) {
                NSArray *pointsData = (NSArray *)dict[@"content"][@"points"];
                points = [NSMutableArray arrayWithCapacity:points.count];
                [pointsData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    SCWhiteBoardPoint *point = [[SCWhiteBoardPoint alloc] init];
                    point.type = [[obj valueForKey:@"t"] integerValue];
                    point.x = 0;
                    point.y = 0;
                    point.proportion_x = [[obj valueForKey:@"pro_x"] floatValue] ? [[obj valueForKey:@"pro_x"] floatValue]  : 0;
                    point.proportion_y = [[obj valueForKey:@"pro_y"] floatValue] ? [[obj valueForKey:@"pro_y"] floatValue]  : 0;
                    point.width = [[obj valueForKey:@"w"] floatValue];
                    point.color = [UIColor colorWithHexString:[NSString stringWithFormat:@"#%@",[obj valueForKey:@"c"]]];
                    [points addObject:point];
                }];
            }
            
            if (completion) {
                completion(uid, action_type, points,info, nil);
            }
        }
    }
}

//json格式字符串转字典：
- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    
    return dic;
}

- (NSArray<NSString *> *)parseHistoryWithJsons:(NSArray<NSString *> *)jsons {
    NSMutableArray<NSValue *> *ranges = [NSMutableArray array];
    NSMutableArray<NSString *> *handleJsons = [NSMutableArray array];
    __block NSUInteger location = NSNotFound;
    __block NSUInteger length = 0;
    
    [jsons enumerateObjectsUsingBlock:^(NSString * _Nonnull json, NSUInteger idx, BOOL * _Nonnull stop) {
        @autoreleasepool {
            [self parseWithJson:json completion:^(NSString *uid, NSInteger action_type, NSArray<SCWhiteBoardPoint *> *points, NSDictionary *info, NSError *error) {
                // 绘制
                if (action_type == 0) {
                    // 找到开始点和结束点 为一条完整的路径
                    if (points.count > 0) {
                        if (points.firstObject.type == SCWhiteBoardPointTypeBegan) {
                            location = idx;
                        } else if (points.firstObject.type == SCWhiteBoardPointTypeMoved) {
                            if (location == NSNotFound) {
                                location = idx;
                            }
                        } else if (points.firstObject.type == SCWhiteBoardPointTypeEnded) {
                            length = idx - location + 1;
                            
                            if (location != NSNotFound) {
                                NSRange range = NSMakeRange(location, length);
                                NSValue *value = [NSValue valueWithRange:range];
                                [ranges addObject:value];
                                //                                NSLog(@"一条完整的路径");
                            }
                            
                            location = NSNotFound;
                            length = 0;
                        }
                    }
                } else if (action_type == 1) { // 撤销
                    [ranges removeLastObject];
                    //                    NSLog(@"撤销上条路径");
                } else if (action_type == 2) { // 清屏
                    [ranges removeAllObjects];
                    //                    NSLog(@"清空所有路径");
                }
            }];
        }
    }];
    
    // 筛选有效的路径
    [ranges enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange range = obj.rangeValue;
        if (range.location >= 0 && range.location + range.length <= jsons.count) {
            NSArray<NSString *> *subJsons = [jsons subarrayWithRange:range];
            [handleJsons addObjectsFromArray:subJsons];
        }
    }];
    
    return handleJsons.copy;
}

@end
