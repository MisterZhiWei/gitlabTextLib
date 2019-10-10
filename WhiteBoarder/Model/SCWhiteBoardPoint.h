//
//  SCWhiteBoardPoint.h
//  WhiteBoard
//
//  Created by 胡浩 on 2019/8/22.
//  Copyright © 2019 胡浩. All rights reserved.
//

@import UIKit;

@interface SCWhiteBoardPoint : NSObject

typedef NS_ENUM(NSInteger, SCWhiteBoardPointType) {
    SCWhiteBoardPointTypeBegan   = 0, ///< 开始绘制点
    SCWhiteBoardPointTypeMoved   = 1, ///< 处于绘制中的点
    SCWhiteBoardPointTypeEnded   = 2, ///< 绘制结束点
    SCWhiteBoardPointTypeSuspend = 3, ///< 悬浮点
};

@property (nonatomic, assign) CGFloat x; ///< 当前设备x轴坐标
@property (nonatomic, assign) CGFloat y; ///< 当前设备y轴坐标

@property (nonatomic, assign) CGFloat proportion_x; ///< x轴相对于画板比例
@property (nonatomic, assign) CGFloat proportion_y; ///< y轴相对于画板比例
@property (nonatomic, assign) CGFloat width; ///< 宽度
@property (nonatomic, strong) UIColor *color; ///< 颜色
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) NSTimeInterval timestamp;

@property (nonatomic, assign) SCWhiteBoardPointType type;

- (instancetype)initWithPointX:(CGFloat)x
                        pointY:(CGFloat)y
                         state:(SCWhiteBoardPointType)type;

@end

