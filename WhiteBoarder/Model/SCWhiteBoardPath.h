//
//  SCWhiteBoardPath.h
//  WhiteBoard
//
//  Created by 胡浩 on 2019/8/22.
//  Copyright © 2019 胡浩. All rights reserved.
//

@import UIKit;
//#import ".h"

@class SCWhiteBoardPoint;

@interface SCWhiteBoardPath : NSObject

@property (nonatomic, assign) CGPoint startingPoint; ///< 起始点
@property (nonatomic, strong) NSMutableArray<SCWhiteBoardPoint *> *points; ///< 画直线时路径上包含的点
@property (nonatomic, strong) UIBezierPath *bezierPath;
@property (nonatomic, strong) UIImage *snapshot;
@property (nonatomic, assign) NSInteger index;

- (instancetype)initWithStartingPoint:(CGPoint)startingPoint;

@end
