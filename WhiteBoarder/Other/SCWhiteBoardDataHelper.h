//
//  SCWhiteBoardDataHelper.h
//  WhiteBoard
//
//  Created by 胡浩 on 2019/8/26.
//  Copyright © 2019 胡浩. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCWhiteBoardPoint, SCWhiteBoardDataHelper;

typedef NS_ENUM(NSInteger, SCWhiteBoardDataActionType) {
    SCWhiteBoardDataActionTypeDraw  = 0,     ///< 绘制
    SCWhiteBoardDataActionTypeUndo  = 1,     ///< 撤销
    SCWhiteBoardDataActionTypeClean = 2,    ///< 清屏
    SCWhiteBoardDataActionTypeImage = 3,    ///< 背景图片修改
};

@protocol SCWhiteBoardDataHelperDelegate <NSObject>

/**
 进入房间后的回调
 
 @param dataHelper SCWhiteBoardDataHelper
 @param index 第几次涂鸦互动
 @param isOpen 涂鸦互动状态（开启 关闭）
 @param userinfo 附带信息
 */
- (void)whiteBoardDataHelper:(SCWhiteBoardDataHelper *)dataHelper
                       index:(NSInteger)index
                      status:(BOOL)isOpen
                    userinfo:(NSDictionary *)userinfo;

/**
 开始涂鸦回调
 
 @param dataHelper SCWhiteBoardDataHelper
 */
- (void)whiteBoardDidStart:(SCWhiteBoardDataHelper *)dataHelper;

/**
 关闭涂鸦回调
 
 @param dataHelper SCWhiteBoardDataHelper
 */
- (void)whiteBoardDidEnd:(SCWhiteBoardDataHelper *)dataHelper;

/**
 收到涂鸦数据回调
 
 @param dataHelper SCWhiteBoardDataHelper
 @param uid 用户ID
 @param action_type 操作类型
 @param points 绘制用的点
 @param isHistoryData 是否为历史数据
 @param error 错误
 */
- (void)whiteBoardDataHelper:(SCWhiteBoardDataHelper *)dataHelper
                         uid:(NSString *)uid
                 action_type:(NSInteger)action_type
                      points:(NSArray<SCWhiteBoardPoint *> *)points
               isHistoryData:(BOOL)isHistoryData
                       error:(NSError *)error;

/**
 涂鸦功能断开或链接失败
 
 @param dataHelper SCWhiteBoardDataHelper
 @param error NSError
 */
- (void)whiteBoardDataHelper:(SCWhiteBoardDataHelper *)dataHelper
                   didFailed:(NSError *)error;

/**
 涂鸦板添加背景板
 
 @param imageUrlStr 背景图片地址
 */
- (void)whiteBoardAddBackImage:(NSString *)imageUrlStr;

@end

@interface SCWhiteBoardDataHelper : NSObject

@property (nonatomic, weak) id<SCWhiteBoardDataHelperDelegate> delegate;

/**
 初始化方法
 
 @param classID 课程id
 @param uid 用户ID
 @param lessonNum 课次id
 @param wsUrl ws地址
 @return SCWhiteBoardDataHelper
 */
- (instancetype)initWithClassID:(NSString *)classID
                            uid:(NSString *)uid
                      lessonNum:(NSString *)lessonNum
                     gatewayUrl:(NSString *)wsUrl;

/**
 发送涂鸦数据
 
 @param point 点信息
 @param action_type 操作类型
 */
- (void)sendDataWithWhiteBoardPointData:(SCWhiteBoardPoint *)point
                            action_type:(SCWhiteBoardDataActionType)action_type;

/**
 设置涂鸦背景
 
 @param imageUrl 图片信息
 @param action_type 操作类型
 */
- (void)sendDataWithWhiteBoardBackImageUrl:(NSString *)imageUrl
                               action_type:(SCWhiteBoardDataActionType)action_type;

/**
 发送开始涂鸦消息
 
 @param interactType 涂鸦互动类型：1000:表示主讲区域涂鸦,2000:课件授课涂鸦
 */
- (void)sendStartDataMessageWithType:(NSString *)interactType;

/**
 发送关闭涂鸦消息
 */
- (void)sendEndDataMessage;

/**
 发送涂鸦清屏消息
 */
- (void)sendCleanScreenMessage;

/**
 关闭绘制
 */
- (void)closeDrawing;

@end
