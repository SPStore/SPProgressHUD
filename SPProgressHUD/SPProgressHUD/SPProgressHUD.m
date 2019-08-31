//
//  SPProgressHUD.m
//  SPProgressHUD
//
//  Created by 乐升平 on 2019/8/23.
//  Copyright © 2019 乐升平. All rights reserved.
//

#import "SPProgressHUD.h"

#define SPMainThreadAssert() NSAssert([NSThread isMainThread], @"SPProgressHUD需要在主线程被访问.");
#define SPDefaultDuration 1.2f
#define SPIndicatorTag 20180829

@interface SPBezelView : UIView

@property (nonatomic, assign) CGFloat cornerRadius;
// HUD的填充样式，分为纯颜色和毛玻璃 (默认是毛玻璃)
@property (nonatomic, assign) BOOL supportedBlur;
@end

@interface SPProgressHUD()
// 背景view,大小和HUD的父视图一样大
@property (nonatomic, strong) UIView *backgroundView;
// 这个view包含了labels，imageView，activity，customView等
@property (nonatomic, strong) SPBezelView *bezelView;
// 文本消息Label
@property (nonatomic, strong) UILabel *messageLabel;
// 加载指示器
@property (nonatomic, strong) UIView *indicator;
// 图片view,如显示成功、失败等图片
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *topLeftSpacer;
@property (nonatomic, strong) UIView *bottomRightSpacer;
@property (nonatomic, strong) NSArray *bezelConstraints;
@property (nonatomic, strong) NSDate *showStarted;
@property (nonatomic, assign, getter=hasFinished) BOOL finished;
@property (nonatomic, assign) CGFloat opacity;
@end

@implementation SPProgressHUD

#pragma mark - Public

+ (instancetype)showActivity {
    return [self showActivityWithMessage:nil];
}

+ (instancetype)showActivityWithMessage:(NSString *)message {
    return [self showActivityWithMessage:message offset:CGPointZero toView:nil];
}

+ (instancetype)showActivityWithMessage:(NSString *)message
                                 offset:(CGPoint)offset
                                 toView:(UIView *)view {
    if (view == nil) {
        view = [self frontWindow];
    }
    SPProgressHUD *hud = [[SPProgressHUD alloc] initWithView:view];
    hud.offset = offset;
    [hud.bezelView addSubview:hud.indicator];
    if (![self isEmptyString:message]) { // 如果message不为空
        hud.messageLabel.text = message;
        [hud.bezelView addSubview:hud.messageLabel];
    }
    [view addSubview:hud];
    [hud showAnimated:YES];
    return hud;
}

+ (instancetype)showWithMessage:(NSString *)message {
    return [self showWithMessage:message duration:SPDefaultDuration offset:CGPointZero toView:nil];
}

+ (instancetype)showWithMessage:(NSString *)message
                       duration:(NSTimeInterval)duration
                         offset:(CGPoint)offset
                         toView:(UIView *)view {
    
    return [self showImage:nil message:message duration:duration offset:offset toView:nil];
}

+ (instancetype)showInfoWithMessage:(NSString *)message {
    return [self showInfoWithMessage:message duration:SPDefaultDuration offset:CGPointZero toView:nil];
}

+ (instancetype)showInfoWithMessage:(NSString *)message
                           duration:(NSTimeInterval)duration
                             offset:(CGPoint)offset
                             toView:(UIView *)view {
    
    UIImage *infoImage = [self imageFromBundleWithNamed:@"info"];

    return [self showImage:[infoImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] message:message duration:duration offset:offset toView:view];
}

+ (instancetype)showSuccessWithMessage:(NSString *)message {
    return [self showSuccessWithMessage:message duration:SPDefaultDuration offset:CGPointZero toView:nil];
}

+ (instancetype)showSuccessWithMessage:(NSString *)message
                              duration:(NSTimeInterval)duration
                                offset:(CGPoint)offset
                                toView:(UIView *)view {
    
    UIImage *successImage = [self imageFromBundleWithNamed:@"success"];
    
    return [self showImage:[successImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] message:message duration:duration offset:offset toView:view];
}

+ (instancetype)showErrorWithMessage:(NSString *)message {
    return [self showErrorWithMessage:message duration:SPDefaultDuration offset:CGPointZero toView:nil];
}

+ (instancetype)showErrorWithMessage:(NSString *)message
                            duration:(NSTimeInterval)duration
                              offset:(CGPoint)offset
                              toView:(UIView *)view {
   
    UIImage *errorImage = [self imageFromBundleWithNamed:@"error"];

    return [self showImage:[errorImage imageWithRenderingMode:(UIImageRenderingModeAlwaysTemplate)] message:message duration:duration offset:offset toView:view];
}

+ (BOOL)dismiss {
    return [self dismissAfterDelay:0.0f forView:nil successHandle:nil];
}

+ (BOOL)dismissForView:(UIView *)view afterDelay:(NSTimeInterval)delay {
    return [self dismissAfterDelay:0.0f forView:nil successHandle:nil];
}

+ (BOOL)dismissAfterDelay:(NSTimeInterval)delay forView:(UIView *)view {
    return [self dismissAfterDelay:delay forView:view successHandle:nil];
}

+ (BOOL)dismissSuccessHandle:(SPProgressHUDDismissSuccessHandle)successHandle {
    return [self dismissAfterDelay:0.0f forView:nil successHandle:successHandle];
}

+ (BOOL)dismissAfterDelay:(NSTimeInterval)delay forView:(UIView *)view successHandle:(SPProgressHUDDismissSuccessHandle)successHandle {
    SPProgressHUD *hud = [self HUDForView:view];
    hud.dismissSuccessHandle = successHandle;
    if (hud != nil) {
        [hud dismissAfterDelay:delay successHandle:successHandle];
        return YES;
    }
    return NO;
}

+ (NSUInteger)dismissAllHUDsForView:(UIView *)view {
    NSArray *huds = [SPProgressHUD allHUDsForView:view];
    for (SPProgressHUD *hud in huds) {
        [hud dismissAnimated:YES];
    }
    return [huds count];
}

- (void)dismiss {
    [self dismissAfterDelay:0.0f successHandle:nil];
}

- (void)dismissAfterDelay:(NSTimeInterval)delay {
    [self dismissAfterDelay:delay successHandle:nil];
}

- (void)dismissSuccessHandle:(SPProgressHUDDismissSuccessHandle)successHandle {
    [self dismissAfterDelay:0.0f successHandle:successHandle];
}

- (void)dismissAfterDelay:(NSTimeInterval)delay successHandle:(SPProgressHUDDismissSuccessHandle)successHandle {
    _dismissSuccessHandle = successHandle;
    if (delay <= 0.0) {
        [self dismissAnimated:YES];
    } else {
        NSTimer *timer = [NSTimer timerWithTimeInterval:delay target:self selector:@selector(handleHideTimer:) userInfo:@(YES) repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }
}

+ (SPProgressHUD *)HUDForView:(UIView *)view {
    if (view == nil) {
        view = [self frontWindow];
    }
    // 逆序枚举
    NSEnumerator *subviewsEnum = [view.subviews reverseObjectEnumerator];
    for (UIView *subview in subviewsEnum) {
        if ([subview isKindOfClass:self]) {
            return (SPProgressHUD *)subview;
        }
    }
    return nil;
}

+ (NSArray *)allHUDsForView:(UIView *)view {
    if (view == nil) {
        view = [self frontWindow];
    }
    NSMutableArray *huds = [NSMutableArray array];
    NSArray *subviews = view.subviews;
    for (UIView *aView in subviews) {
        if ([aView isKindOfClass:self]) {
            [huds addObject:aView];
        }
    }
    return [NSArray arrayWithArray:huds];
}

- (void)replaceActivityWithCustomView:(UIView *)customView {
    if (_indicator && _indicator.superview && customView != nil) {
        [_indicator removeFromSuperview];
        _indicator = nil;
        self.indicator = customView;
        [self.bezelView addSubview:self.indicator];
        [self setNeedsUpdateConstraints];
    }
}

#pragma mark - Private

+ (instancetype)showImage:(UIImage *)image message:(NSString *)message duration:(NSTimeInterval)duration offset:(CGPoint)offset toView:(UIView *)view {
    if (view == nil) {
        view = [self frontWindow];
    }
    SPProgressHUD *hud = [[SPProgressHUD alloc] initWithView:view];
    hud.offset = offset;
    if (image) {
        hud.imageView.image = image;
        [hud.bezelView addSubview:hud.imageView];
    }
    if (![self isEmptyString:message]) { // 如果message不为空
        hud.messageLabel.text = message;
        [hud.bezelView addSubview:hud.messageLabel];
    }
    [view addSubview:hud];
    [hud showAnimated:YES];
    [hud dismissAfterDelay:duration];
    return hud;
}

- (void)showAnimated:(BOOL)animated {
    // 需要在主线程
    SPMainThreadAssert();
    
    [self.bezelView.layer removeAllAnimations];
    [self.backgroundView.layer removeAllAnimations];
    
    self.finished = NO;
    self.showStarted = [NSDate date];
    self.alpha = 1.f;
    
    if (animated) {
        [self animateIn:YES completion:NULL];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        self.bezelView.alpha = self.opacity;
#pragma clang diagnostic pop
        self.backgroundView.alpha = 1.f;
    }
}

- (void)dismissAnimated:(BOOL)animated {
    // 需要在主线程
    SPMainThreadAssert()
    
    if (self.hasFinished == YES) return; // 防止多次隐藏多次回调dismissSuccessHandle
    
    self.finished = YES;
    
    if (animated && self.showStarted) {
        self.showStarted = nil;
        [self animateIn:NO completion:^(BOOL finished) {
            [self done];
        }];
    } else {
        self.showStarted = nil;
        self.bezelView.alpha = 0.f;
        self.backgroundView.alpha = 1.f;
        [self done];
    }
}

- (void)animateIn:(BOOL)animatingIn completion:(void(^)(BOOL finished))completion {
    UIView *bezelView = self.bezelView;
    // Perform animations
    dispatch_block_t animations = ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        bezelView.alpha = animatingIn ? self.opacity : 0.f;
#pragma clang diagnostic pop
        self.backgroundView.alpha = animatingIn ? 1.f : 0.f;
    };
    [UIView animateWithDuration:0.3 delay:0. usingSpringWithDamping:1.f initialSpringVelocity:0.f options:UIViewAnimationOptionBeginFromCurrentState animations:animations completion:completion];
}

- (void)handleHideTimer:(NSTimer *)timer {
    [self dismissAnimated:[timer.userInfo boolValue]];
}

- (void)done {
    
    if (self.hasFinished) {
        self.alpha = 0.0f;
        [self removeFromSuperview];
    }
    SPProgressHUDDismissSuccessHandle dismissSuccessHandle = self.dismissSuccessHandle;
    if (dismissSuccessHandle) {
        dismissSuccessHandle();
    }
}

+ (BOOL)isEmptyString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) {
        return YES;
    }
    return NO;
}

+ (UIImage *)imageFromBundleWithNamed:(NSString *)name {
    NSBundle *bundle = [NSBundle bundleForClass:[SPProgressHUD class]];
    NSString *path = [bundle pathForResource:@"SPProgressHUD" ofType:@"bundle"];
    NSBundle *imageBundle = [NSBundle bundleWithPath:path];
    UIImage *image = [UIImage imageWithContentsOfFile:[imageBundle pathForResource:name ofType:@"png"]];
    return image;
}

+ (UIWindow *)frontWindow {
    NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
    for (UIWindow *window in frontToBackWindows) {
        BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
        BOOL windowIsVisible = !window.hidden && window.alpha > 0;
        BOOL windowLevelSupported = (window.windowLevel >= UIWindowLevelNormal);
        BOOL windowKeyWindow = window.isKeyWindow;
        
        if(windowOnMainScreen && windowIsVisible && windowLevelSupported && windowKeyWindow) {
            return window;
        }
    }
    return nil;
}

#pragma mark - Init

- (instancetype)initWithView:(UIView *)view {
    NSAssert(view, @"View must not be nil.");
    // 给self(self就是hud)设置尺寸
    return [self initWithFrame:view.bounds];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    
    _labelPosition = SPProgressHUDLabelPositionBottom;
    _supportedBlur = YES;
    _contentColor = [UIColor colorWithWhite:1.f alpha:0.7f];
    _spacing = 5.0f;
    _margin = 20.f;
    _defaultMotionEffectsEnabled = YES;
    
    _opacity = 1.f;
    
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
    self.alpha = 0.0f;

    _contentColor = [UIColor colorWithWhite:1.f alpha:0.7f];
    
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.layer.allowsGroupOpacity = NO;

    [self addCommonViews];
}

- (void)addCommonViews {
    [self addSubview:self.backgroundView];
    [self addSubview:self.bezelView];
    [self.bezelView addSubview:self.topLeftSpacer];
    [self.bezelView addSubview:self.bottomRightSpacer];
    
    [self updateBezelMotionEffects];
}

#pragma mark - Properties

- (void)setContentColor:(UIColor *)contentColor {
    if (contentColor != _contentColor && ![contentColor isEqual:_contentColor]) {
        _contentColor = contentColor;
        UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)self.indicator;
        if ([indicator isKindOfClass:[UIActivityIndicatorView class]]) {
            indicator.color = contentColor;
        }
        self.messageLabel.textColor = contentColor;
        self.imageView.tintColor = contentColor;
    }
}

- (void)setColor:(UIColor *)color {
    if (color != _color && ![color isEqual:_color]) {
        _color = color;
        self.bezelView.backgroundColor = color;
    }
}

- (void)setMaskColor:(UIColor *)maskColor {
    if (maskColor != _maskColor && ![maskColor isEqual:_maskColor]) {
        _maskColor = maskColor;
        self.backgroundView.backgroundColor = maskColor;
    }
}

- (void)setOffset:(CGPoint)offset {
    if (!CGPointEqualToPoint(offset, _offset)) {
        _offset = offset;
        [self setNeedsUpdateConstraints];
    }
}

- (void)setMargin:(CGFloat)margin {
    if (margin != _margin) {
        _margin = margin;
        [self setNeedsUpdateConstraints];
    }
}

- (void)setSpacing:(CGFloat)spacing {
    if (spacing != _spacing) {
        _spacing = spacing;
        [self setNeedsUpdateConstraints];
    }
}

- (void)setMinSize:(CGSize)minSize {
    if (!CGSizeEqualToSize(minSize, _minSize)) {
        _minSize = minSize;
        [self setNeedsUpdateConstraints];
    }
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    if (cornerRadius != _cornerRadius) {
        _cornerRadius = cornerRadius;
        self.bezelView.cornerRadius = cornerRadius;
    }
}

- (void)setSupportedBlur:(BOOL)supportBlur {
    if (supportBlur != _supportedBlur) {
        _supportedBlur = supportBlur;
        self.bezelView.supportedBlur = supportBlur;
    }
}

- (void)setDefaultMotionEffectsEnabled:(BOOL)defaultMotionEffectsEnabled {
    if (defaultMotionEffectsEnabled != _defaultMotionEffectsEnabled) {
        _defaultMotionEffectsEnabled = defaultMotionEffectsEnabled;
        [self updateBezelMotionEffects];
    }
}

- (void)setLabelPosition:(SPProgressHUDLabelPosition)labelPosition {
    if (labelPosition != _labelPosition && ![[self class] isEmptyString:self.messageLabel.text]) {
        _labelPosition = labelPosition;
        
        UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)self.indicator;

        if (labelPosition == SPProgressHUDLabelPositionBottom || labelPosition == SPProgressHUDLabelPositionTop) {
            if ([indicator isKindOfClass:[UIActivityIndicatorView class]] && indicator.superview && indicator.tag == SPIndicatorTag) {
                [indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
                // 如果先设置了_contentColor,再设置labelPosition,上一行代码会使指示器会变为白色,所以这里要还原_contentColor
                indicator.color = _contentColor;
            }
        } else {
            if ([indicator isKindOfClass:[UIActivityIndicatorView class]] && indicator.superview && indicator.tag == SPIndicatorTag) {
                [indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
                // 如果先设置了_contentColor,再设置labelPosition,上一行代码会使指示器会变为白色,所以这里要还原_contentColor
                indicator.color = _contentColor;
            }
        }
        [self setNeedsUpdateConstraints];
    }
}

#pragma mark - UI   (VFL语言布局)

- (void)updateConstraints {
    
    UIView *bezel = self.bezelView;
    UIView *topLeftSpacer = self.topLeftSpacer;
    UIView *bottomRightSpacer = self.bottomRightSpacer;
    CGFloat margin = self.margin;
    NSMutableArray *bezelConstraints = [NSMutableArray array];
    NSDictionary *metrics = @{@"margin": @(margin)};
    
    // 移除存在的约束
    [self removeConstraints:self.constraints];
    [topLeftSpacer removeConstraints:topLeftSpacer.constraints];
    [bottomRightSpacer removeConstraints:bottomRightSpacer.constraints];
    if (self.bezelConstraints) {
        [bezel removeConstraints:self.bezelConstraints];
        self.bezelConstraints = nil;
    }
    
    CGPoint offset = self.offset;
    NSMutableArray *centeringConstraints = [NSMutableArray array];
    // bezel水平居中
    [centeringConstraints addObject:[NSLayoutConstraint constraintWithItem:bezel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.f constant:offset.x]];
    // bezel垂直居中
    [centeringConstraints addObject:[NSLayoutConstraint constraintWithItem:bezel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.f constant:offset.y]];
    [self applyPriority:998.f toConstraints:centeringConstraints];
    [self addConstraints:centeringConstraints];
    
    NSMutableArray *sideConstraints = [NSMutableArray array];
    // bezel上下左右间距大于等于20
    [sideConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=margin)-[bezel]-(>=margin)-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(bezel)]];
    [sideConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=margin)-[bezel]-(>=margin)-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(bezel)]];
    [self applyPriority:999.f toConstraints:sideConstraints];
    [self addConstraints:sideConstraints];
    
    CGSize minimumSize = self.minSize;
    if (!CGSizeEqualToSize(minimumSize, CGSizeZero)) {
        NSMutableArray *minSizeConstraints = [NSMutableArray array];
        [minSizeConstraints addObject:[NSLayoutConstraint constraintWithItem:bezel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:minimumSize.width]];
        [minSizeConstraints addObject:[NSLayoutConstraint constraintWithItem:bezel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:minimumSize.height]];
        [self applyPriority:997.f toConstraints:minSizeConstraints];
        [bezelConstraints addObjectsFromArray:minSizeConstraints];
    }
    
    if (self.square) {
        NSLayoutConstraint *square = [NSLayoutConstraint constraintWithItem:bezel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:bezel attribute:NSLayoutAttributeWidth multiplier:1.f constant:0];
        square.priority = 997.f;
        [bezelConstraints addObject:square];
    }
    
    NSLayoutAttribute layoutAttributeCenterXY;
    NSString *ruleString;
    NSLayoutAttribute layoutAttributeTopLeft;
    NSLayoutAttribute layoutAttributeBottomRight;
    NSLayoutAttribute layoutAttributeWidthHeight;
    
    if (self.labelPosition == SPProgressHUDLabelPositionBottom || self.labelPosition == SPProgressHUDLabelPositionTop) {
        layoutAttributeCenterXY = NSLayoutAttributeCenterX;
        ruleString = @"H:";
        layoutAttributeTopLeft = NSLayoutAttributeTop;
        layoutAttributeBottomRight = NSLayoutAttributeBottom;
        layoutAttributeWidthHeight = NSLayoutAttributeHeight;
    } else {
        layoutAttributeCenterXY = NSLayoutAttributeCenterY;
        ruleString = @"V:";
        layoutAttributeTopLeft = NSLayoutAttributeLeft;
        layoutAttributeBottomRight = NSLayoutAttributeRight;
        layoutAttributeWidthHeight = NSLayoutAttributeWidth;
    }
    
    // 高度(宽度)大于或等于margin
    [topLeftSpacer addConstraint:[NSLayoutConstraint constraintWithItem:topLeftSpacer attribute:layoutAttributeWidthHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:margin]];
    // 高度(宽度)大于或等于margin
    [bottomRightSpacer addConstraint:[NSLayoutConstraint constraintWithItem:bottomRightSpacer attribute:layoutAttributeWidthHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:margin]];
    // 顶部(左边)间距和底部(右边)间距相等
    [bezelConstraints addObject:[NSLayoutConstraint constraintWithItem:topLeftSpacer attribute:layoutAttributeWidthHeight relatedBy:NSLayoutRelationEqual toItem:bottomRightSpacer attribute:layoutAttributeWidthHeight multiplier:1.f constant:0.f]];

    NSMutableArray *subviews = [NSMutableArray arrayWithObjects:self.topLeftSpacer,self.imageView,self.indicator,self.messageLabel ,self.bottomRightSpacer, nil];

    // 根据labelPosition改变label的位置
    subviews = [self changeLabelPositionInSubviews:subviews];
    
    // 移除子控件(先添加到subviews里然后再从subviews里移除是为了方便指定子控件的排序)
    subviews = [self removeObjectFromSubviews:subviews];
    
    if (self.indicator.translatesAutoresizingMaskIntoConstraints == YES) {
        self.indicator.translatesAutoresizingMaskIntoConstraints = NO;
        [self.indicator addConstraint:[NSLayoutConstraint constraintWithItem:self.indicator attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:self.indicator.frame.size.height]];
        [self.indicator addConstraint:[NSLayoutConstraint constraintWithItem:self.indicator attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:self.indicator.frame.size.width]];
    }

    NSMutableArray *paddingConstraints = [NSMutableArray new];
    [subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        // bezel内部的每个子控件都水平(垂直)居中
        [bezelConstraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:layoutAttributeCenterXY relatedBy:NSLayoutRelationEqual toItem:bezel attribute:layoutAttributeCenterXY multiplier:1.f constant:0.f]];
        // bezel内部的每个子控件的左右(上下)间距大于等于margin
        [bezelConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"%@|-(>=margin)-[view]-(>=margin)-|",ruleString] options:0 metrics:metrics views:NSDictionaryOfVariableBindings(view)]];
        // 元素间距
        if (idx == 0) {
            // 第一个子控件顶部(左边)间距为0
            [bezelConstraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:layoutAttributeTopLeft relatedBy:NSLayoutRelationEqual toItem:bezel attribute:layoutAttributeTopLeft multiplier:1.f constant:0.f]];
        } else if (idx == subviews.count - 1) {
            // 最后一个子控件底部(右边)间距为0
            [bezelConstraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:layoutAttributeBottomRight relatedBy:NSLayoutRelationEqual toItem:bezel attribute:layoutAttributeBottomRight multiplier:1.f constant:-0.f]];
        }
        if (idx > 0) {
            // 子控件之间的垂直(水平)间距
            NSLayoutConstraint *padding = [NSLayoutConstraint constraintWithItem:view attribute:layoutAttributeTopLeft relatedBy:NSLayoutRelationEqual toItem:subviews[idx - 1] attribute:layoutAttributeBottomRight multiplier:1.f constant:(idx > 1 && idx < subviews.count - 1) ? self->_spacing : 0.f]; // 3目运算条件的意思是：除了上下间距view之外的其余子控件的垂直(水平)间距为_spacing
            [bezelConstraints addObject:padding];
            [paddingConstraints addObject:padding];
        }
    }];
    [bezel addConstraints:bezelConstraints];
    self.bezelConstraints = [bezelConstraints copy];
    
    [super updateConstraints];
}

// 设置优先级
- (void)applyPriority:(UILayoutPriority)priority toConstraints:(NSArray *)constraints {
    for (NSLayoutConstraint *constraint in constraints) {
        constraint.priority = priority;
    }
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (NSMutableArray *)changeLabelPositionInSubviews:(NSMutableArray *)subviews {
    if (![[self class] isEmptyString:self.messageLabel.text]) {
        if (self.labelPosition == SPProgressHUDLabelPositionTop ||
            self.labelPosition == SPProgressHUDLabelPositionLeft) {
            if (self.imageView.superview) {
                NSInteger index1 = [subviews indexOfObject:self.imageView];
                NSInteger index2 = [subviews indexOfObject:self.messageLabel];
                [subviews exchangeObjectAtIndex:index1 withObjectAtIndex:index2];
            } else if (self.indicator.superview) {
                NSInteger index1 = [subviews indexOfObject:self.indicator];
                NSInteger index2 = [subviews indexOfObject:self.messageLabel];
                [subviews exchangeObjectAtIndex:index1 withObjectAtIndex:index2];
            }
        }
    }
    return subviews;
}

- (NSMutableArray *)removeObjectFromSubviews:(NSMutableArray *)subviews {
    if (!self.imageView.superview || !self.imageView.image) {
        [subviews removeObject:self.imageView];
    }
    if (!self.messageLabel.superview || [[self class] isEmptyString:self.messageLabel.text]) {
        [subviews removeObject:self.messageLabel];
    }
    if (!self.indicator.superview){
        [subviews removeObject:self.indicator];
    }
    return subviews;
}

- (void)updateBezelMotionEffects {
    UIView *bezelView = self.bezelView;
    if (self.defaultMotionEffectsEnabled) {
        CGFloat effectOffset = 10.f;
        UIInterpolatingMotionEffect *effectX = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
        effectX.maximumRelativeValue = @(effectOffset);
        effectX.minimumRelativeValue = @(-effectOffset);
        
        UIInterpolatingMotionEffect *effectY = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
        effectY.maximumRelativeValue = @(effectOffset);
        effectY.minimumRelativeValue = @(-effectOffset);
        
        UIMotionEffectGroup *group = [[UIMotionEffectGroup alloc] init];
        group.motionEffects = @[effectX, effectY];
        
        [bezelView addMotionEffect:group];
    } else {
        NSArray *effects = [bezelView motionEffects];
        for (UIMotionEffect *effect in effects) {
            [bezelView removeMotionEffect:effect];
        }
    }
}

#pragma - Lazy

- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        _backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _backgroundView.backgroundColor = [UIColor clearColor];
    }
    return _backgroundView;
}

- (SPBezelView *)bezelView {
    if (!_bezelView) {
        _bezelView = [SPBezelView new];
        _bezelView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _bezelView;
}

- (UIView *)topLeftSpacer {
    if (!_topLeftSpacer) {
        _topLeftSpacer = [UIView new];
        _topLeftSpacer.translatesAutoresizingMaskIntoConstraints = NO;
        _topLeftSpacer.hidden = YES;
    }
    return _topLeftSpacer;
}

- (UIView *)bottomRightSpacer {
    if (!_bottomRightSpacer) {
        _bottomRightSpacer = [UIView new];
        _bottomRightSpacer.translatesAutoresizingMaskIntoConstraints = NO;
        _bottomRightSpacer.hidden = YES;
    }
    return _bottomRightSpacer;
}

- (UIView *)indicator {
    if (!_indicator) {
        UIActivityIndicatorView *indicator = [UIActivityIndicatorView new];
        indicator.translatesAutoresizingMaskIntoConstraints = NO;
        [indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicator.color = self.contentColor;
        indicator.tag = SPIndicatorTag; // 用此tag区分是SPProgressHUD自带的indicator，还是外面传进来的indicator
        [indicator startAnimating];
        _indicator = indicator;
    }
    return _indicator;
}

- (UILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [UILabel new];
        _messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
        // 设置抗压缩优先级,优先级越高越不容易被压缩,默认的优先级是750
        [_messageLabel setContentCompressionResistancePriority:998.f forAxis:UILayoutConstraintAxisHorizontal];
        [_messageLabel setContentCompressionResistancePriority:998.f forAxis:UILayoutConstraintAxisVertical];
        _messageLabel.adjustsFontSizeToFitWidth = NO;
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.textColor = self.contentColor;
        _messageLabel.font = [UIFont systemFontOfSize:16];
        _messageLabel.opaque = NO;
    }
    return _messageLabel;
}

- (UIImageView *)imageView {
    if (!_imageView) {;
        _imageView = [UIImageView new];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.tintColor = self.contentColor;
    }
    return _imageView;
}

@end

@interface SPBezelView()

@property UIVisualEffectView *effectView;

@end

@implementation SPBezelView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        
        self.backgroundColor = [UIColor blackColor];
        self.layer.cornerRadius = 5.0f;
        self.clipsToBounds = YES;

        _supportedBlur = YES;
        [self updateForBackgroundStyle];
    }
    return self;
}

#pragma mark - Layout

// 内容大小设置为0，在对SPBezelView设置约束时便可以自适应内容大小
- (CGSize)intrinsicContentSize {
    // Smallest size possible. Content pushes against this.
    return CGSizeZero;
}

#pragma mark - Appearance

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    [self setNeedsDisplay];
}

- (void)setSupportedBlur:(BOOL)supportedBlur {
    if (_supportedBlur != supportedBlur) {
        _supportedBlur = supportedBlur;
        [self updateForBackgroundStyle];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Views

- (void)updateForBackgroundStyle {
    if (_supportedBlur) {
        if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0) {
            UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
            [self addSubview:effectView];
            effectView.frame = self.bounds;
            effectView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            self.layer.allowsGroupOpacity = NO;
            self.effectView = effectView;
        }
    } else {
        if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0) {
            [self.effectView removeFromSuperview];
            self.effectView = nil;
        }
    }
}

- (void)drawRect:(CGRect)rect {
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:_cornerRadius];;
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
    shapeLayer.path = bezierPath.CGPath;
    self.layer.mask = shapeLayer;
}

@end
