//
//  SCWhiteBoardView.m
//  WhiteBoard
//
//  Created by 胡浩 on 2019/8/22.
//  Copyright © 2019 胡浩. All rights reserved.
//

#import "SCWhiteBoardView.h"
#import "SCWhiteBoardPoint.h"
#import "SCWhiteBoardPath.h"
#import "SCWhiteBoardBrush.h"
#import "UIImageView+WebCache.h"

static inline CGPoint sc_midPoint(CGPoint p1, CGPoint p2) {
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}

@interface SCWhiteBoardView () <CAAnimationDelegate> {
    dispatch_queue_t _saveQueue;
}

@property (nonatomic, weak)     CAShapeLayer *slayer; ///< 画板
@property (nonatomic, strong)   UIImageView *backImgView; ///< 背景板

@property (nonatomic, strong)   SCWhiteBoardBrush *brush; ///< 笔刷
@property (nonatomic, strong)   NSMutableArray<SCWhiteBoardPath *> *paths; ///< 轨迹

/**
 *  线条数组
 */
@property (nonatomic, strong)   NSMutableArray * lines;
@end

@implementation SCWhiteBoardView

- (instancetype)initWithDelegate:(id<SCWhiteBoardViewDelegate>)delegate {
    _delegate = delegate;
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.clearColor;
        [self addSubview:self.backImgView];
        
        _brush = [[SCWhiteBoardBrush alloc] init];
        _paths = [NSMutableArray array];
        
        _saveQueue = dispatch_queue_create("com.SCWhiteBoardView.saveQueue", DISPATCH_QUEUE_SERIAL);
        
        self.canPainting = NO;
        
        NSString *libraryCachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *dirPath = [libraryCachePath stringByAppendingPathComponent:@"drawImageCache"];
        NSArray<NSString *> *paths = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:dirPath error:NULL];
        [paths enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *path = [NSString stringWithFormat:@"%@/%@", dirPath, obj];
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
            if (error) {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
    
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches
           withEvent:(UIEvent *)event {
    CGPoint location = [self touchLocation:touches];
    if (!CGRectContainsPoint(self.layer.bounds, location)) {
        return;
    }
    
    SCWhiteBoardPoint *point = [self createPointModelWithLocation:location];
    point.type = SCWhiteBoardPointTypeBegan;
    
    SCWhiteBoardPath *path = [[SCWhiteBoardPath alloc] initWithStartingPoint:location];
    point.index = path.points.count;
    [path.points addObject:point];
    path.index = self.paths.count;
    [self.paths addObject:path];
    path.bezierPath.lineWidth = self.brush.lineWidth;
    
    CAShapeLayer *slayer = [CAShapeLayer layer];
    slayer.path = path.bezierPath.CGPath;
    slayer.strokeColor = self.brush.color.CGColor;
    slayer.fillColor = [UIColor clearColor].CGColor;
    slayer.lineJoin = kCALineJoinRound;
    slayer.lineCap = kCALineCapRound;
    slayer.lineWidth = self.brush.lineWidth;
    _slayer = slayer;
    [self.layer addSublayer:_slayer];
    [self.lines addObject:_slayer];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(whiteBoardView:point:)]) {
        [self.delegate whiteBoardView:self
                                point:point];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches
           withEvent:(UIEvent *)event {
    CGPoint location = [self touchLocation:touches];
    if (!CGRectContainsPoint(self.layer.bounds, location)) {
        return;
    }
    
    SCWhiteBoardPath *path = self.paths.lastObject;
    if (ABS(path.points.lastObject.x - location.x) < 0.5f && ABS(path.points.lastObject.y - location.y) < 0.5f) {
        return;
    }
    
    SCWhiteBoardPoint *point = [self createPointModelWithLocation:location];
    point.type = SCWhiteBoardPointTypeMoved;
    point.index = path.points.count;
    [path.points addObject:point];
    
    //    CGPoint previousPoint = [self touchPreLocation:touches];
    //    CGPoint currentPoint = location;
    //    CGPoint mid = sc_midPoint(previousPoint, currentPoint);
    //    [path.bezierPath addQuadCurveToPoint:mid
    //                            controlPoint:previousPoint];
    
    [path.bezierPath addLineToPoint:location];
    self.slayer.path = path.bezierPath.CGPath;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(whiteBoardView:point:)]) {
        [self.delegate whiteBoardView:self
                                point:point];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches
           withEvent:(UIEvent *)event {
    CGPoint location = [self touchLocation:touches];
    
    if (location.x < 0.f) {
        location.x = 0.f;
    }
    
    if (location.x > CGRectGetWidth(self.layer.bounds)) {
        location.x = CGRectGetWidth(self.layer.bounds);
    }
    
    if (location.y < 0.f) {
        location.y = 0.f;
    }
    
    if (location.y > CGRectGetHeight(self.layer.bounds)) {
        location.y = CGRectGetHeight(self.layer.bounds);
    }
    
    SCWhiteBoardPoint *point = [self createPointModelWithLocation:location];
    point.type = SCWhiteBoardPointTypeEnded;
    
    SCWhiteBoardPath *path = self.paths.lastObject;
    point.index = path.points.count;
    [path.points addObject:point];
    
    //    CGPoint previousPoint = [self touchPreLocation:touches];
    //    CGPoint currentPoint = location;
    //    CGPoint mid = sc_midPoint(previousPoint, currentPoint);
    //    [path.bezierPath addQuadCurveToPoint:mid
    //                            controlPoint:previousPoint];
    //    path.bezierPath.lineWidth = self.brush.lineWidth;
    //    self.slayer.path = path.bezierPath.CGPath;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(whiteBoardView:point:)]) {
        [self.delegate whiteBoardView:self
                                point:point];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches
               withEvent:(UIEvent *)event {
    [self touchesEnded:touches
             withEvent:event];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.backImgView.frame = self.bounds;
}

#pragma mark - private method
- (void)addBackImageWithUrl:(NSURL *)imageUrl{
    
    if (imageUrl.absoluteString.length > 0) {
        self.backImgView.hidden = NO;
        [self.backImgView sd_setImageWithURL:imageUrl];
    }
    else {
        self.backImgView.hidden = YES;
    }
}

/**
 获取白板当前的快照信息
 
 @return 快照图片
 */
- (UIImage *)getWhiteBoardSnapshoot {
    //先截取整个涂鸦区域的图片
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 1.0);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];
    UIImage *viewimage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return viewimage;
}

/**
 添加背景
 
 @param image 背景图片
 */
- (void)addBackImageWithImage:(UIImage *)image {
    if (image) {
        self.backImgView.hidden = NO;
        self.backImgView.image = image;
    }
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [CATransaction begin];
    [CATransaction setDisableActions:NO];
    self.slayer.strokeEnd = 1.f;
    [CATransaction commit];
}

#pragma mark - Public Methods

- (void)drawPathWithPoints:(NSArray<SCWhiteBoardPoint *> *)points {
    //    if (points.firstObject.type == SCWhiteBoardPointTypeMoved) {
    //        SCWhiteBoardPath *lastPath = self.paths.lastObject;
    //        [points enumerateObjectsUsingBlock:^(SCWhiteBoardPoint * _Nonnull point, NSUInteger idx, BOOL * _Nonnull stop) {
    //            point.x = self.sketchpad.frame.size.width * point.proportion_x;
    //            point.y = self.sketchpad.frame.size.height * point.proportion_y;
    //
    //            CGPoint previousPoint1 = CGPointMake(lastPath.points.lastObject.x, lastPath.points.lastObject.y);
    //            CGPoint currentPoint = CGPointMake(point.x, point.y);
    //            CGPoint mid1 = sc_midPoint(previousPoint1, currentPoint);
    //            [lastPath.bezierPath addQuadCurveToPoint:mid1 controlPoint:previousPoint1];
    //            [lastPath.points addObject:point];
    //        }];
    //
    //        NSUInteger index = [lastPath.points indexOfObject:points.firstObject];
    //        CGFloat strokeEnd = (CGFloat)index / (CGFloat)lastPath.points.count;
    //
    //        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    //        animation.fromValue = @(strokeEnd);
    //        animation.toValue = @(1.f);
    //        animation.duration = 0.17;
    //        animation.removedOnCompletion = NO;
    //        animation.fillMode = kCAFillModeForwards;
    //        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    //        animation.delegate = self;
    //        [self.sketchpad addAnimation:animation forKey:@"animation"];
    //
    //        return;
    //    }
    
    [points enumerateObjectsUsingBlock:^(SCWhiteBoardPoint * _Nonnull point, NSUInteger idx, BOOL * _Nonnull stop) {
        point.x = self.layer.frame.size.width * point.proportion_x;
        point.y = self.layer.frame.size.height * point.proportion_y;
        
        // 配置点信息
        [self configWhiteBoaderViewBrushWithPoint:point];
        
        switch (point.type) {
            case SCWhiteBoardPointTypeBegan: {
                SCWhiteBoardPath *path = [[SCWhiteBoardPath alloc] initWithStartingPoint:CGPointMake(point.x, point.y)];
                
                [path.points addObject:point];
                [self.paths addObject:path];
                CAShapeLayer *slayer = [CAShapeLayer layer];
                slayer.strokeColor = self.brush.color.CGColor;
                slayer.fillColor = [UIColor clearColor].CGColor;
                slayer.lineJoin = kCALineJoinRound;
                slayer.lineCap = kCALineCapRound;
                slayer.lineWidth = self.brush.lineWidth;
                
                self.slayer = slayer;
                [self.layer addSublayer:self.slayer];
                [self.lines addObject:self.slayer];
            }
                
                break;
            case SCWhiteBoardPointTypeMoved: {
                SCWhiteBoardPath *lastPath = self.paths.lastObject;
                CGPoint previousPoint1 = CGPointMake(lastPath.points.lastObject.x, lastPath.points.lastObject.y);
                CGPoint currentPoint = CGPointMake(point.x, point.y);
                CGPoint mid1 = sc_midPoint(previousPoint1, currentPoint);
                [lastPath.bezierPath addQuadCurveToPoint:mid1 controlPoint:previousPoint1];
                [lastPath.points addObject:point];
                lastPath.bezierPath.lineWidth = self.brush.lineWidth;
                self.slayer.path = lastPath.bezierPath.CGPath;
            }
                
                break;
            case SCWhiteBoardPointTypeEnded: {
                //                SCWhiteBoardPath *lastPath = self.paths.lastObject;
                //                CGPoint previousPoint1 = CGPointMake(lastPath.points.lastObject.x, lastPath.points.lastObject.y);
                //                CGPoint currentPoint = CGPointMake(point.x, point.y);
                //                CGPoint mid1 = sc_midPoint(previousPoint1, currentPoint);
                //                [lastPath.bezierPath addQuadCurveToPoint:mid1 controlPoint:previousPoint1];
                //
                //                [lastPath.points addObject:point];
                //                lastPath.bezierPath.lineWidth = self.brush.lineWidth;
                //                self.slayer.path = lastPath.bezierPath.CGPath;
                
            }
                
                break;
            case SCWhiteBoardPointTypeSuspend: {
                // ...
                break;
            }
        }
    }];
}

// set boader view path brush color
- (void)configWhiteBoaderViewBrushWithPoint:(SCWhiteBoardPoint *)point {
    
    self.brush.color = point.color;
    self.brush.lineWidth = point.width ? point.width : 1.0f;
}

- (void)undo {
    //当前屏幕已经清空，就不能撤销了
    if (self.lines.count == 0) return;
    [self.lines.lastObject removeFromSuperlayer];
    [self.lines removeLastObject];
}

- (void)clean {
    if (self.lines.count == 0) return ;
    [self.lines makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [self.lines removeAllObjects];
    [self.paths removeAllObjects];
    
    if ([self.delegate respondsToSelector:@selector(clean)]) {
        [self.delegate clean];
    }
}

#pragma mark - Setter Methods

- (void)setCanPainting:(BOOL)canPainting {
    _canPainting = canPainting;
    self.userInteractionEnabled = canPainting;
}

- (void)setBrushColor:(UIColor *)brushColor {
    _brushColor = brushColor;
    self.brush.color = brushColor;
}

- (void)setBrushWidth:(CGFloat)brushWidth {
    _brushWidth = brushWidth;
    self.brush.lineWidth = brushWidth;
}

#pragma mark - Private Methods

- (CGPoint)touchLocation:(NSSet<UITouch *> *)touches {
    UITouch *validTouch = nil;
    for (UITouch *touch in touches) {
        if ([touch.view isEqual:self]) {
            validTouch = touch;
            break;
        }
    }
    
    if (validTouch) {
        return [validTouch locationInView:self];
    }
    else {
        return CGPointMake(-1, -1);
    }
}

- (CGPoint)touchPreLocation:(NSSet<UITouch *> *)touches {
    UITouch *validTouch = nil;
    for (UITouch *touch in touches) {
        if ([touch.view isEqual:self]) {
            validTouch = touch;
            break;
        }
    }
    
    if (validTouch) {
        return [validTouch previousLocationInView:self];
    }
    else {
        return CGPointMake(-1, -1);
    }
}

- (SCWhiteBoardPoint *)createPointModelWithLocation:(CGPoint)location {
    SCWhiteBoardPoint *point = [[SCWhiteBoardPoint alloc] init];
    point.timestamp = [NSDate date].timeIntervalSince1970 * 1000.0;
    point.x = location.x;
    point.y = location.y;
    point.proportion_x = location.x / self.layer.frame.size.width;
    point.proportion_y = location.y / self.layer.frame.size.height;
    point.color = self.brush.color;
    point.width = self.brush.lineWidth;
    return point;
}

#pragma mark - getter
- (NSMutableArray *)lines{
    if (!_lines) {
        _lines = [NSMutableArray array];
    }
    return _lines;
}

- (UIImageView *)backImgView{
    if (!_backImgView) {
        _backImgView = [[UIImageView alloc] init];
        _backImgView.backgroundColor = [UIColor clearColor];
        _backImgView.hidden = YES;
    }
    return _backImgView;
}

@end
