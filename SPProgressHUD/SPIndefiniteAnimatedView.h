//
//  SPIndefiniteAnimatedView.h
//  SPIndefiniteAnimatedView
//
//  Copyright (c) 2014-2019 Guillaume Campagna. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPIndefiniteAnimatedView : UIView

@property (nonatomic, assign) CGFloat strokeThickness;  // default is 2.0
@property (nonatomic, assign) CGFloat radius; // default is 25.0
@property (nonatomic, strong) UIColor *strokeColor; // default is whiteColor
@property (nonatomic, assign) CGFloat strokeStart;  // 0.0 ~ 1.0, default is 0.4
@property (nonatomic, assign) CGFloat strokeEnd;  // 0.0 ~ 1.0, default is 1.0
@end

