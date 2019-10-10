//
//  SCWhiteBoardSocketManager.h
//  WhiteBoard
//
//  Created by 胡浩 on 2019/9/2.
//  Copyright © 2019 胡浩. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SocketRocket/SocketRocket.h>

FOUNDATION_EXPORT NSString * const SCWhiteBoardSocketManagerEnterNotification; ///< 进入房间
FOUNDATION_EXPORT NSString * const SCWhiteBoardSocketManagerDataNotification; ///< 收到数据
FOUNDATION_EXPORT NSString * const SCWhiteBoardSocketManagerHistoryNotification; ///< 收到历史数据
FOUNDATION_EXPORT NSString * const SCWhiteBoardSocketManagerStartNotification; ///< 开始涂鸦
FOUNDATION_EXPORT NSString * const SCWhiteBoardSocketManagerEndNotification; ///< 关闭涂鸦
FOUNDATION_EXPORT NSString * const SCWhiteBoardSocketManagerFailedNotification; ///< 链接失败或出错

@interface SCWhiteBoardSocketManager : NSObject

@property (nonatomic, assign, readonly) SRReadyState readyState;

+ (instancetype)sharedManager;

/**
 开启链接

 @param url 链接地址
 */
- (void)openWithURL:(NSURL *)url;

/**
 关闭链接
 */
- (void)close;

/**
 发送数据

 @param data 需要发送的数据
 */
- (void)sendData:(id)data;

@end
