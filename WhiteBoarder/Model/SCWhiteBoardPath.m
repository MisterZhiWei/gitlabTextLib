//
//  SCWhiteBoardPath.m
//  WhiteBoard
//
//  Created by 胡浩 on 2019/8/22.
//  Copyright © 2019 胡浩. All rights reserved.
//

#import "SCWhiteBoardPath.h"

@interface SCWhiteBoardPath ()

@end

@implementation SCWhiteBoardPath

- (instancetype)initWithStartingPoint:(CGPoint)startingPoint {
    if (self = [super init]) {
        _startingPoint = startingPoint;
        
        _points = [NSMutableArray array];
        
        UIBezierPath *bezierPath = [UIBezierPath bezierPath];
        bezierPath.lineCapStyle = kCGLineCapRound;
        bezierPath.lineJoinStyle = kCGLineJoinRound;
        [bezierPath moveToPoint:startingPoint];
        _bezierPath = bezierPath;
    }
    
    return self;
}

@end
