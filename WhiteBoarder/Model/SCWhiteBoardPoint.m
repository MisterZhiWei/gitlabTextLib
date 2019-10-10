//
//  SCWhiteBoardPoint.m
//  WhiteBoard
//
//  Created by 胡浩 on 2019/8/22.
//  Copyright © 2019 胡浩. All rights reserved.
//

#import "SCWhiteBoardPoint.h"

@implementation SCWhiteBoardPoint

- (instancetype)initWithPointX:(CGFloat)x
                        pointY:(CGFloat)y
                         state:(SCWhiteBoardPointType)type {
    if (self = [super init]) {
        _x = x;
        _y = y;
        _type = type;
    }
    
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

@end
