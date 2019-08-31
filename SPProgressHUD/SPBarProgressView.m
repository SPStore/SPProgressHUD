//
//  SPBarProgressView.m
//  SPProgressView
//
//  Created by 乐升平 on 2018/8/15.
//  Copyright © 2018 乐升平. All rights reserved.
//

#import "SPBarProgressView.h"

@implementation SPBarProgressView

#pragma mark - Lifecycle

- (id)init {
    return [self initWithFrame:CGRectMake(.0f, .0f, 120.0f, 10.0f)];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _lineWidth = 2.f;
        _progress = 0.f;
        _lineColor = [UIColor whiteColor];
        _progressColor = [UIColor whiteColor];
        _progressRemainingColor = [UIColor clearColor];
        _intrinsicContentSize = CGRectEqualToRect(frame, CGRectZero) ? CGSizeMake(120, 10) : frame.size;
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
    }
    return self;
}

#pragma mark - Layout

- (CGSize)intrinsicContentSize {
    return _intrinsicContentSize;
}

#pragma mark - Properties

- (void)setProgress:(float)progress {
    if (progress != _progress) {
        _progress = progress;
        [self setNeedsDisplay];
    }
}

- (void)setProgressColor:(UIColor *)progressColor {
    NSAssert(progressColor, @"The color should not be nil.");
    if (progressColor != _progressColor && ![progressColor isEqual:_progressColor]) {
        _progressColor = progressColor;
        [self setNeedsDisplay];
    }
}

- (void)setProgressRemainingColor:(UIColor *)progressRemainingColor {
    NSAssert(progressRemainingColor, @"The color should not be nil.");
    if (progressRemainingColor != _progressRemainingColor && ![progressRemainingColor isEqual:_progressRemainingColor]) {
        _progressRemainingColor = progressRemainingColor;
        [self setNeedsDisplay];
    }
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    float lineWidth = _lineWidth > rect.size.height/2-1 ? 2 : _lineWidth;
    float lineHalfWidth = lineWidth/2;
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetStrokeColorWithColor(context,[_lineColor CGColor]);
    CGContextSetFillColorWithColor(context, [_progressRemainingColor CGColor]);

    // 绘制边框
    CGFloat radius = (rect.size.height / 2) - lineHalfWidth;
    CGContextMoveToPoint(context, lineHalfWidth, rect.size.height/2);
    CGContextAddArcToPoint(context, lineHalfWidth, lineHalfWidth, radius + lineHalfWidth, lineHalfWidth, radius);
    CGContextAddArcToPoint(context, rect.size.width - lineHalfWidth, lineHalfWidth, rect.size.width - lineHalfWidth, rect.size.height / 2, radius);
    CGContextAddArcToPoint(context, rect.size.width - lineHalfWidth, rect.size.height - lineHalfWidth, rect.size.width - radius - lineHalfWidth, rect.size.height - lineHalfWidth, radius);
    CGContextAddArcToPoint(context, lineHalfWidth, rect.size.height - lineHalfWidth, lineHalfWidth, rect.size.height/2, radius);
    CGContextDrawPath(context, kCGPathFillStroke);

    CGContextSetFillColorWithColor(context, [_progressColor CGColor]);
    radius = radius - lineHalfWidth;
    CGFloat amount = self.progress * rect.size.width;
    CGContextSetLineWidth(context, 1);

    // Progress in the middle area
    if (amount >= radius + lineWidth && amount <= (rect.size.width - radius - lineWidth)) {
        CGContextMoveToPoint(context, lineWidth, rect.size.height/2);
        CGContextAddArcToPoint(context, lineWidth, lineWidth, radius + lineWidth, lineWidth, radius);
        CGContextAddLineToPoint(context, amount, lineWidth);
        CGContextAddLineToPoint(context, amount, radius + lineWidth);

        CGContextMoveToPoint(context, lineWidth, rect.size.height/2);
        CGContextAddArcToPoint(context, lineWidth, rect.size.height - lineWidth, radius + lineWidth, rect.size.height - lineWidth, radius);
        CGContextAddLineToPoint(context, amount, rect.size.height - lineWidth);
        CGContextAddLineToPoint(context, amount, radius + lineWidth);

        CGContextFillPath(context);
    }

    // Progress in the right arc
    else if (amount > radius + lineWidth) {
        CGFloat x = amount - (rect.size.width - radius - lineWidth);

        CGContextMoveToPoint(context, lineWidth, rect.size.height/2);
        CGContextAddArcToPoint(context, lineWidth, lineWidth, radius + lineWidth, lineWidth, radius);
        CGContextAddLineToPoint(context, rect.size.width - radius - lineWidth, lineWidth);
        CGFloat angle = -acos(x/radius);
        if (isnan(angle)) angle = 0;
        CGContextAddArc(context, rect.size.width - radius - lineWidth, rect.size.height/2, radius, M_PI, angle, 0);
        CGContextAddLineToPoint(context, amount, rect.size.height/2);

        CGContextMoveToPoint(context, lineWidth, rect.size.height/2);
        CGContextAddArcToPoint(context, lineWidth, rect.size.height - lineWidth, radius + lineWidth, rect.size.height - lineWidth, radius);
        CGContextAddLineToPoint(context, rect.size.width - radius - lineWidth, rect.size.height - lineWidth);
        angle = acos(x/radius);
        if (isnan(angle)) angle = 0;
        CGContextAddArc(context, rect.size.width - radius - lineWidth, rect.size.height/2, radius, -M_PI, angle, 1);
        CGContextAddLineToPoint(context, amount, rect.size.height/2);

        CGContextFillPath(context);
    }

    // Progress is in the left arc
    else if (amount < radius + lineWidth && amount > 0) {
        CGContextMoveToPoint(context, lineWidth, rect.size.height/2);
        CGContextAddArcToPoint(context, lineWidth, lineWidth, radius + lineWidth, lineWidth, radius);
        CGContextAddLineToPoint(context, radius + lineWidth, rect.size.height/2);

        CGContextMoveToPoint(context, lineWidth, rect.size.height/2);
        CGContextAddArcToPoint(context, lineWidth, rect.size.height - lineWidth, radius + lineWidth, rect.size.height - lineWidth, radius);
        CGContextAddLineToPoint(context, radius + lineWidth, rect.size.height/2);

        CGContextFillPath(context);
    }
}


@end
