
//  SPIndefiniteAnimatedView.m
//  SPIndefiniteAnimatedView
//
//  Created by 乐升平 on 2018/8/15.
//  Copyright © 2018 乐升平. All rights reserved.
//


#import "SPIndefiniteAnimatedView.h"

@interface SPIndefiniteAnimatedView ()

@property (nonatomic, strong) CAGradientLayer *indefiniteAnimatedGradientLayer;

@end

@implementation SPIndefiniteAnimatedView

- (void)willMoveToSuperview:(UIView*)newSuperview {
    if (newSuperview) {
        [self layoutAnimatedLayer];
    } else {
        [_indefiniteAnimatedGradientLayer removeFromSuperlayer];
        _indefiniteAnimatedGradientLayer = nil;
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _strokeThickness = 2.0f;
        _radius = 25.0f;
        _strokeColor = [UIColor whiteColor];
        _strokeStart = 0.4f;
        _strokeEnd = 1.0f;
    }
    return self;
}

- (void)layoutAnimatedLayer {
    CALayer *layer = self.indefiniteAnimatedGradientLayer;
    [self.layer addSublayer:layer];

    CGFloat widthDiff = CGRectGetWidth(self.bounds) - CGRectGetWidth(layer.bounds);
    CGFloat heightDiff = CGRectGetHeight(self.bounds) - CGRectGetHeight(layer.bounds);
    layer.position = CGPointMake(CGRectGetWidth(self.bounds) - CGRectGetWidth(layer.bounds) / 2 - widthDiff / 2, CGRectGetHeight(self.bounds) - CGRectGetHeight(layer.bounds) / 2 - heightDiff / 2);
}

- (CAGradientLayer *)indefiniteAnimatedGradientLayer {
    if (!_indefiniteAnimatedGradientLayer) {
        CGPoint arcCenter = CGPointMake(self.radius+self.strokeThickness/2+5, self.radius+self.strokeThickness/2+5);
        UIBezierPath* smoothedPath = [UIBezierPath bezierPathWithArcCenter:arcCenter radius:self.radius startAngle:(CGFloat) (M_PI*3/2) endAngle:(CGFloat) (-0.5 * M_PI) clockwise:NO];

        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.contentsScale = [[UIScreen mainScreen] scale];
        shapeLayer.frame = CGRectMake(0.0f, 0.0f, arcCenter.x*2, arcCenter.y*2);
        shapeLayer.fillColor = [UIColor clearColor].CGColor;
        shapeLayer.strokeColor = self.strokeColor.CGColor;
        shapeLayer.lineWidth = self.strokeThickness;
        shapeLayer.lineCap = kCALineCapRound;
        shapeLayer.lineJoin = kCALineJoinRound;
        shapeLayer.path = smoothedPath.CGPath;
        shapeLayer.strokeStart = _strokeStart;
        shapeLayer.strokeEnd = _strokeEnd;

        _indefiniteAnimatedGradientLayer = [CAGradientLayer layer];
        _indefiniteAnimatedGradientLayer.startPoint = CGPointMake(0.5f, 0.0f);
        _indefiniteAnimatedGradientLayer.endPoint = CGPointMake(0.5f, 1.0f);
        _indefiniteAnimatedGradientLayer.frame = shapeLayer.bounds;
        _indefiniteAnimatedGradientLayer.colors = [NSArray arrayWithObjects:
                                                   (id)[self.strokeColor colorWithAlphaComponent:0.0f].CGColor,
                                                   (id)[self.strokeColor colorWithAlphaComponent:0.5f].CGColor,
                                                   (id)self.strokeColor.CGColor,
                                                   nil];
        _indefiniteAnimatedGradientLayer.locations = [NSArray arrayWithObjects:
                                                      @(0.25f),
                                                      @(0.5f),
                                                      @(1.0f),
                                                      nil];
        _indefiniteAnimatedGradientLayer.mask = shapeLayer;

        NSTimeInterval animationDuration = 1;
        CAMediaTimingFunction *linearCurve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];

        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        animation.fromValue = (id) 0;
        animation.toValue = @(M_PI*2);
        animation.duration = animationDuration;
        animation.timingFunction = linearCurve;
        animation.removedOnCompletion = NO;
        animation.repeatCount = INFINITY;
        animation.fillMode = kCAFillModeForwards;
        animation.autoreverses = NO;
        [_indefiniteAnimatedGradientLayer addAnimation:animation forKey:@"rotate"];
    }
    return _indefiniteAnimatedGradientLayer;
}

- (void)setFrame:(CGRect)frame {
    CGFloat fitSize = (_radius+_strokeThickness/2+5)*2;
    if (frame.size.width < fitSize) {
        frame.size.width = fitSize;
    }
    if (frame.size.height < fitSize) {
        frame.size.height = fitSize;
    }
    if (!CGRectEqualToRect(frame, super.frame)) {
        [super setFrame:frame];

        if (self.superview) {
            [self layoutAnimatedLayer];
        }
    }

}
- (void)setRadius:(CGFloat)radius {
    if(radius != _radius) {
        _radius = radius;

        [_indefiniteAnimatedGradientLayer removeFromSuperlayer];
        _indefiniteAnimatedGradientLayer = nil;

        if (self.superview) {
            [self layoutAnimatedLayer];
        }
    }
}

- (void)setStrokeColor:(UIColor*)strokeColor {
    _strokeColor = strokeColor;

    [_indefiniteAnimatedGradientLayer removeFromSuperlayer];
    _indefiniteAnimatedGradientLayer = nil;

    if (self.superview) {
        [self layoutAnimatedLayer];
    }
}

- (void)setStrokeThickness:(CGFloat)strokeThickness {
    _strokeThickness = strokeThickness;

    [_indefiniteAnimatedGradientLayer removeFromSuperlayer];
    _indefiniteAnimatedGradientLayer = nil;

    if (self.superview) {
        [self layoutAnimatedLayer];
    }
}

- (void)setStrokeStart:(CGFloat)strokeStart {
    _strokeStart = strokeStart;
    
    [_indefiniteAnimatedGradientLayer removeFromSuperlayer];
    _indefiniteAnimatedGradientLayer = nil;
    
    if (self.superview) {
        [self layoutAnimatedLayer];
    }
}

- (void)setStrokeEnd:(CGFloat)strokeEnd {
    _strokeEnd = strokeEnd;
    
    [_indefiniteAnimatedGradientLayer removeFromSuperlayer];
    _indefiniteAnimatedGradientLayer = nil;
    
    if (self.superview) {
        [self layoutAnimatedLayer];
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, size.width, size.height)];
    return CGSizeMake((self.radius+self.strokeThickness/2+5)*2, (self.radius+self.strokeThickness/2+5)*2);
}

@end
