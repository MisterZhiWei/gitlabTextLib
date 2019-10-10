//
//  SCWhiteBoardView.h
//  WhiteBoard
//
//  Created by 胡浩 on 2019/8/22.
//  Copyright © 2019 胡浩. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCWhiteBoardPoint.h"

@class SCWhiteBoardView, SCWhiteBoardPath;

@protocol SCWhiteBoardViewDelegate <NSObject>

/**
 绘制的点的回调方法
 
 @param whiteBoardView SCWhiteBoardView
 @param point 绘制的点
 */
- (void)whiteBoardView:(SCWhiteBoardView *)whiteBoardView
                 point:(SCWhiteBoardPoint *)point;

- (void)clean;

@end

@interface SCWhiteBoardView : UIView

@property (nonatomic, weak) id<SCWhiteBoardViewDelegate>delegate;

/**
 是否开启绘画，默认关闭
 */
@property (nonatomic, assign, getter=isCanPainting) BOOL canPainting;


/**
 笔刷颜色
 */
@property (nonatomic, strong) UIColor *brushColor;

/**
 笔画宽度
 */
@property (nonatomic, assign) CGFloat brushWidth;

/**
 初始化方法
 
 @param delegate 代理
 @return SCWhiteBoardView
 */
- (instancetype)initWithDelegate:(id<SCWhiteBoardViewDelegate>)delegate;

/**
 根据传入的点来进行绘制
 
 @param points 需要绘制的点
 */
- (void)drawPathWithPoints:(NSArray<SCWhiteBoardPoint *> *)points;

/**
 添加背景
 
 @param imageUrl 背景图片地址
 */
- (void)addBackImageWithUrl:(NSURL *)imageUrl;

/**
 添加背景
 
 @param image 背景图片
 */
- (void)addBackImageWithImage:(UIImage *)image;

/**
 获取白板当前的快照信息
 
 @return 快照图片
 */
- (UIImage *)getWhiteBoardSnapshoot;


/**
 撤销
 */
- (void)undo;

/**
 清屏
 */
- (void)clean;

@end
