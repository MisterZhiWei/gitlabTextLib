//
//  SCWhiteBoardBrush.m
//  WhiteBoard
//
//  Created by 胡浩 on 2019/8/24.
//  Copyright © 2019 胡浩. All rights reserved.
//

#import "SCWhiteBoardBrush.h"

@implementation SCWhiteBoardBrush

- (instancetype)init {
    if (self = [super init]) {
        _color = UIColor.redColor;
        _lineWidth = 3.f;
    }
    
    return self;
}

@end
