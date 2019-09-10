//
//  SPProgressHUD.m
//  SPProgressHUD
//
//  Created by 乐升平 on 2019/8/23.
//  Copyright © 2019 乐升平. All rights reserved.
//

#import "SPProgressHUD.h"

#define SPIndicatorTag 20180829

@interface SPBezelView : UIView
@property (nonatomic, assign) BOOL supportedBlur;
@property UIVisualEffectView *effectView;
@end

@interface SPHUDBarProgressView : UIView
@property (nonatomic, assign) float progress;
@property (nonatomic, assign) float lineWidth;
@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, strong) UIColor *progressRemainingTintColor;
@property (nonatomic, strong) UIColor *progressTintColor;
@property (nonatomic, assign) CGSize intrinsicContentSize;
@end

@interface SPHUDRoundProgressView : UIView
@property (nonatomic, assign) float progress;
@property (nonatomic, assign) float lineWidth;
@property (nonatomic, strong) UIColor *progressTintColor;
@property (nonatomic, strong) UIColor *backgroundTintColor;
@property (nonatomic, assign, getter = isAnnular) BOOL annular;
@property (nonatomic, assign) CGSize intrinsicContentSize;
@end

@interface SPProgressHUD()
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) SPBezelView *bezelView;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIView *indicator;
@property (nonatomic, strong) UIView *topLeftSpacer; // 充当顶部(左边)间距
@property (nonatomic, strong) UIView *bottomRightSpacer; // 充当底部(右边)间距
@property (nonatomic, strong) NSArray *bezelConstraints;
@property (nonatomic, strong) NSArray *paddingConstraints;
@property (nonatomic, strong) NSDate *showStarted;
@property (nonatomic, weak) NSTimer *hideDelayTimer;
@property (nonatomic, assign, getter=hasFinished) BOOL finished;
@property (nonatomic, assign) CGFloat opacity;
@end

UIImage *displaySuccessImage(CGSize size, CGFloat inset);
UIImage *displayErrorImage(CGSize size, CGFloat inset);
UIImage *displayInfoImage(CGSize size, CGFloat inset);

@implementation SPProgressHUD

#pragma mark - Public

+ (instancetype)showActivity {
    return [self showActivityWithMessage:nil];
}

+ (instancetype)showActivityWithMessage:(NSString *)message {
    return [self showActivityWithMessage:message toView:nil];
}

+ (instancetype)showActivityWithMessage:(NSString *)message toView:(UIView *)view {
    if (view == nil)  view = [self frontWindow];
    SPProgressHUD *hud = [[self alloc] initWithView:view]; // 用self调用alloc,不要用SPProgressHUD调用alloc,self调用的好处是子类继承时,创建的是子类对象.
    hud.removeFromSuperViewOnHide = YES;
    if (![self isEmptyString:message]) { // 如果message不为空
        hud.messageLabel.text = message;
        [hud.bezelView addSubview:hud.messageLabel];
    }
    [view addSubview:hud];
    [hud show];
    return hud;
}

+ (instancetype)showWithMessage:(NSString *)message {
    return [self showWithMessage:message toView:nil];
}

+ (instancetype)showWithMessage:(NSString *)message toView:(UIView *)view {
    UIImage *image = nil; // 因为下面这个方法image参数默认不要为空,如果直接传nil会报警告
    return [self showWithImage:image message:message toView:view];
}

+ (instancetype)showSuccessWithMessage:(NSString *)message {
    return [self showSuccessWithMessage:message toView:nil];
}

+ (instancetype)showSuccessWithMessage:(NSString *)message toView:(UIView *)view {
    UIImage *successImage = displaySuccessImage(CGSizeMake(28, 28),0);
    
    return [self showWithImage:[successImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] message:message toView:view];
}

+ (instancetype)showErrorWithMessage:(NSString *)message {
    return [self showErrorWithMessage:message toView:nil];
}

+ (instancetype)showErrorWithMessage:(NSString *)message toView:(UIView *)view {
    UIImage *errorImage = displayErrorImage(CGSizeMake(28, 28),2);

    return [self showWithImage:[errorImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] message:message toView:view];
}

+ (instancetype)showInfoWithMessage:(NSString *)message {
    return [self showInfoWithMessage:message toView:nil];
}

+ (instancetype)showInfoWithMessage:(NSString *)message toView:(UIView *)view {
    UIImage *infoImage = displayInfoImage(CGSizeMake(28, 28), 2);

    return [self showWithImage:[infoImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] message:message toView:view];
}

+ (instancetype)showWithImage:(UIImage *)image message:(NSString *)message {
    return [self showWithImage:image message:message toView:nil];
}

+ (instancetype)showWithImage:(UIImage *)image
                      message:(NSString *)message
                       toView:(UIView *)view {
    
    if (view == nil)  view = [self frontWindow];
    SPProgressHUD *hud = [[self alloc] initWithView:view];
    hud.removeFromSuperViewOnHide = YES;
    if (image) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.tintColor = hud.contentColor;
        [hud updateIndicatorWithView:imageView];
    } else {
        [hud.indicator removeFromSuperview];
        hud.indicator = nil;
    }
    if (![self isEmptyString:message]) { // 如果message不为空
        hud.messageLabel.text = message;
        [hud.bezelView addSubview:hud.messageLabel];
    }
    [view addSubview:hud];
    [hud show];
    return hud;
}

+ (instancetype)showProgress {
    return [self showProgressWithMessage:nil toView:nil];
}

+ (instancetype)showProgressWithMessage:(NSString *)message {
    return [self showProgressWithMessage:message toView:nil];
}

+ (instancetype)showProgressWithMessage:(NSString *)message toView:(UIView *)view {
    
    if (view == nil)  view = [self frontWindow];
    SPProgressHUD *hud = [[self alloc] initWithView:view];
    hud.removeFromSuperViewOnHide = YES;
    SPHUDRoundProgressView *progressView = [[SPHUDRoundProgressView alloc] init];
    progressView.translatesAutoresizingMaskIntoConstraints = NO;
    progressView.progressTintColor = hud.contentColor;
    [hud updateIndicatorWithView:progressView];
    if (![self isEmptyString:message]) { // 如果message不为空
        hud.messageLabel.text = message;
        [hud.bezelView addSubview:hud.messageLabel];
    }
    [view addSubview:hud];
    [hud show];
    return hud;
}

- (void)show {
    if (![NSThread isMainThread]) {
#ifdef DEBUG
        NSLog(@"Warning:请在主线程显示HUD.");
#endif
    }
    [self.bezelView.layer removeAllAnimations];
    [self.backgroundView.layer removeAllAnimations];
    
    self.finished = NO;
    [self.hideDelayTimer invalidate];
    self.showStarted = [NSDate date];
    self.alpha = 1.f;
    
    [self animateIn:YES completion:NULL];
}

+ (BOOL)hide {
    return [self hideForView:nil afterDelay:0.0];
}

+ (BOOL)hideAfterDelay:(NSTimeInterval)delay {
    return [self hideForView:nil afterDelay:delay];
}

+ (BOOL)hideForView:(UIView *)view {
    return [self hideForView:view afterDelay:0.0];
}

+ (BOOL)hideForView:(UIView *)view afterDelay:(NSTimeInterval)delay {
    SPProgressHUD *hud = [self HUDForView:view];
    if (hud != nil) {
        [hud hideAfterDelay:delay completion:nil];
        return YES;
    }
#ifdef DEBUG
    NSLog(@"Error:在'%@(%p)'上没有找到任何HUD,请检查隐藏时与显示时所指定的父视图是否一致.",[view class],view);
#endif
    return NO;
}

+ (NSUInteger)hideAllHUDsForView:(UIView *)view {
    NSArray *huds = [self allHUDsForView:view];
    for (SPProgressHUD *hud in huds) {
        hud.removeFromSuperViewOnHide = YES;
        [hud hide];
    }
    return [huds count];
}

- (void)hideAfterDelay:(NSTimeInterval)delay {
    [self hideAfterDelay:delay completion:nil];
}

- (void)hideAfterDelay:(NSTimeInterval)delay completion:(SPProgressHUDHideCompletion)completion {
    _hideCompletion = completion;
    if (delay <= 0.0) {
        [self hide];
    } else {
        [self.hideDelayTimer invalidate];
        NSTimer *timer = [NSTimer timerWithTimeInterval:delay target:self selector:@selector(handleHideTimer:) userInfo:@(YES) repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        self.hideDelayTimer = timer;
    }
}

- (void)hide {
    if (![NSThread isMainThread]) {
#ifdef DEBUG
        NSLog(@"Warning:请在主线程隐藏HUD.");
#endif
    }
    if (self.hasFinished == YES) return; // 防止多次隐藏多次回调hideSuccessHandle
    
    self.finished = YES;
    
    if (self.isUseHideAnimation && self.showStarted) {
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

#pragma mark - Private

- (void)animateIn:(BOOL)animatingIn completion:(void(^)(BOOL finished))completion {
    UIView *bezelView = self.bezelView;
    // 执行动画
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
    [self hide];
}

- (void)done {
    
    [self.hideDelayTimer invalidate];

    if (self.hasFinished) {
        self.alpha = 0.0f;
        if (self.removeFromSuperViewOnHide) {
            [self removeFromSuperview];
        }
    }
    SPProgressHUDHideCompletion hideCompletion = self.hideCompletion;
    if (hideCompletion) {
        hideCompletion();
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

- (void)updateIndicatorWithView:(UIView *)view {
    [self.indicator removeFromSuperview];
    [self.bezelView addSubview:view];
    self.indicator = view;
    
    [view setContentCompressionResistancePriority:998.f forAxis:UILayoutConstraintAxisHorizontal];
    [view setContentCompressionResistancePriority:998.f forAxis:UILayoutConstraintAxisVertical];
    [self setNeedsUpdateConstraints];
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
    _color = [UIColor blackColor];
    _supportedBlur = YES;
    _cornerRadius = 5.0f;
    _maskColor = [UIColor colorWithWhite:0.0 alpha:0];
    _spacing = 5.0f;
    _margin = 20.f;
    _defaultMotionEffectsEnabled = YES;
    _useHideAnimation = YES;
    
    _opacity = 1.f;
    
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
    self.alpha = 0.0f;
    
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.layer.allowsGroupOpacity = NO;

    [self setupViews];
    [self setNeedsUpdateConstraints];
    [self registerForNotifications];
}

- (void)dealloc {
    [self unregisterFromNotifications];
}

- (void)setupViews {

    UIView *backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    backgroundView.backgroundColor = _maskColor;
    [self addSubview:backgroundView];
    _backgroundView = backgroundView;
    
    SPBezelView *bezelView = [SPBezelView new];
    bezelView.translatesAutoresizingMaskIntoConstraints = NO;
    bezelView.layer.cornerRadius = _cornerRadius;
    [self addSubview:bezelView];
    _bezelView = bezelView;
    
    [self updateBezelMotionEffects];

    UIActivityIndicatorView *indicator = [UIActivityIndicatorView new];
    [indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.color = _contentColor;
    indicator.tag = SPIndicatorTag; // 用此tag区分是SPProgressHUD自带的indicator，还是外面传进来的indicator
    [indicator startAnimating];
    [bezelView addSubview:indicator];
    _indicator = indicator;
    
    UILabel *messageLabel = [UILabel new];
    messageLabel.adjustsFontSizeToFitWidth = NO;
    messageLabel.numberOfLines = 0;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.textColor = _contentColor;
    messageLabel.backgroundColor = [UIColor clearColor];
    messageLabel.font = [UIFont boldSystemFontOfSize:16];
    messageLabel.opaque = NO;
    _messageLabel = messageLabel;
    
    for (UIView *view in @[indicator,messageLabel]) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
        // 设置抗压缩优先级,优先级越高越不容易被压缩,默认的优先级是750
        [view setContentCompressionResistancePriority:998.f forAxis:UILayoutConstraintAxisHorizontal];
        [view setContentCompressionResistancePriority:998.f forAxis:UILayoutConstraintAxisVertical];
        [bezelView addSubview:view];
    }
    
    UIView *topLeftSpacer = [UIView new];
    topLeftSpacer.translatesAutoresizingMaskIntoConstraints = NO;
    topLeftSpacer.hidden = YES;
    [bezelView addSubview:topLeftSpacer];
    _topLeftSpacer = topLeftSpacer;
    
    UIView *bottomRightSpacer = [UIView new];
    bottomRightSpacer.translatesAutoresizingMaskIntoConstraints = NO;
    bottomRightSpacer.hidden = YES;
    [bezelView addSubview:bottomRightSpacer];
    _bottomRightSpacer = bottomRightSpacer;
}

#pragma mark - Notifications

- (void)registerForNotifications {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self selector:@selector(statusBarOrientationDidChange:)
               name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)unregisterFromNotifications {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)statusBarOrientationDidChange:(NSNotification *)notification {
    UIView *superview = self.superview;
    if (!superview) {
        return;
    } else {
        [self updateForCurrentOrientationAnimated:YES];
    }
}

- (void)didMoveToSuperview {
    [self updateForCurrentOrientationAnimated:NO];
}

- (void)updateForCurrentOrientationAnimated:(BOOL)animated {
    if (self.superview) {
        self.frame = self.superview.bounds;
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

    NSMutableArray *subviews = [NSMutableArray arrayWithObjects:self.topLeftSpacer,self.messageLabel,self.bottomRightSpacer, nil];
    if (self.indicator) [subviews insertObject:self.indicator atIndex:1];

    // 根据labelPosition改变label的位置
    subviews = [self changeLabelPositionInSubviews:subviews];
    
    if (self.indicator.translatesAutoresizingMaskIntoConstraints == YES) {
        self.indicator.translatesAutoresizingMaskIntoConstraints = NO;
        CGSize viewSize = [self sizeForCustomView:self.indicator];
        [self.indicator addConstraint:[NSLayoutConstraint constraintWithItem:self.indicator attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:viewSize.height]];
        [self.indicator addConstraint:[NSLayoutConstraint constraintWithItem:self.indicator attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:viewSize.width]];
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
            NSLayoutConstraint *padding = [NSLayoutConstraint constraintWithItem:view attribute:layoutAttributeTopLeft relatedBy:NSLayoutRelationEqual toItem:subviews[idx - 1] attribute:layoutAttributeBottomRight multiplier:1.f constant:0.f];
            [bezelConstraints addObject:padding];
            [paddingConstraints addObject:padding];
        }
    }];
    [bezel addConstraints:bezelConstraints];
    self.bezelConstraints = [bezelConstraints copy];
    
    self.paddingConstraints = [paddingConstraints copy];
    [self updatePaddingConstraints];
    
    [super updateConstraints];
}

- (void)layoutSubviews {
    if (!self.needsUpdateConstraints) {
        [self updatePaddingConstraints];
    }
    [super layoutSubviews];
}

- (void)updatePaddingConstraints {
    __block BOOL hasVisibleAncestors = NO;
    CGFloat spacing = self.spacing;
    [self.paddingConstraints enumerateObjectsUsingBlock:^(NSLayoutConstraint *padding, NSUInteger idx, BOOL *stop) {
        UIView *firstView = (UIView *)padding.firstItem;
        UIView *secondView = (UIView *)padding.secondItem;
        BOOL firstVisible = !firstView.hidden && !CGSizeEqualToSize(firstView.intrinsicContentSize, CGSizeZero);
        BOOL secondVisible = !secondView.hidden && !CGSizeEqualToSize(secondView.intrinsicContentSize, CGSizeZero);
        padding.constant = (firstVisible && (secondVisible || hasVisibleAncestors)) ? spacing : 0.f;
        hasVisibleAncestors |= secondVisible;
    }];
}

// 设置优先级
- (void)applyPriority:(UILayoutPriority)priority toConstraints:(NSArray *)constraints {
    for (NSLayoutConstraint *constraint in constraints) {
        constraint.priority = priority;
    }
}

// 获取自定义view的大小
- (CGSize)sizeForCustomView:(UIView *)customView {
    [customView layoutIfNeeded];
    CGSize settingSize = customView.frame.size;
    CGSize fittingSize = [customView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return CGSizeMake(MAX(settingSize.width, fittingSize.width), MAX(settingSize.height, fittingSize.height));
}

- (NSMutableArray *)changeLabelPositionInSubviews:(NSMutableArray *)subviews {
    if (![[self class] isEmptyString:self.messageLabel.text]) {
        if (self.labelPosition == SPProgressHUDLabelPositionTop ||
            self.labelPosition == SPProgressHUDLabelPositionLeft) {
            if (self.indicator.superview) {
                NSInteger index1 = [subviews indexOfObject:self.indicator];
                NSInteger index2 = [subviews indexOfObject:self.messageLabel];
                [subviews exchangeObjectAtIndex:index1 withObjectAtIndex:index2];
            }
        }
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

#pragma mark - Properties

- (void)setCustomView:(UIView *)customView {
    if (customView != _customView) {
        _customView = customView;
        [self updateIndicatorWithView:customView];
    }
}

- (void)setProgress:(float)progress {
    if (progress != _progress) {
        _progress = progress;
        UIView *indicator = self.indicator;
        if ([indicator respondsToSelector:@selector(setProgress:)]) {
            [(id)indicator setValue:@(progress) forKey:@"progress"];
        }
    }
}

- (void)setContentColor:(UIColor *)contentColor {
    if (contentColor != _contentColor && ![contentColor isEqual:_contentColor]) {
        _contentColor = contentColor;
        UIView *indicator = self.indicator;
        if ([indicator isKindOfClass:[UIActivityIndicatorView class]]) {
            ((UIActivityIndicatorView *)indicator).color = contentColor;
        } else if ([indicator isKindOfClass:[UIImageView class]]) {
            ((UIImageView *)indicator).tintColor = contentColor;
        } else if ([indicator isKindOfClass:[SPHUDBarProgressView class]]) {
            ((SPHUDBarProgressView *)indicator).progressTintColor = contentColor;
            ((SPHUDBarProgressView *)indicator).lineColor = contentColor;
        } else if ([indicator isKindOfClass:[SPHUDRoundProgressView class]]) {
            ((SPHUDRoundProgressView *)indicator).progressTintColor = contentColor;
        }
        self.messageLabel.textColor = contentColor;
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
        [self updatePaddingConstraints];
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
        self.bezelView.layer.cornerRadius = cornerRadius;
    }
}

- (void)setSupportedBlur:(BOOL)supportBlur {
    if (supportBlur != _supportedBlur) {
        _supportedBlur = supportBlur;
        self.bezelView.supportedBlur = supportBlur;
    }
}

- (void)setUseHideAnimation:(BOOL)useHideAnimation {
    if (useHideAnimation != _useHideAnimation) {
        _useHideAnimation = useHideAnimation;
    }
}

- (void)setDefaultMotionEffectsEnabled:(BOOL)defaultMotionEffectsEnabled {
    if (defaultMotionEffectsEnabled != _defaultMotionEffectsEnabled) {
        _defaultMotionEffectsEnabled = defaultMotionEffectsEnabled;
        [self updateBezelMotionEffects];
    }
}

- (void)setProgressViewStyle:(SPProgressHUDProgressViewStyle)progressViewStyle {
    if (progressViewStyle != _progressViewStyle) {
        _progressViewStyle = progressViewStyle;
        
        UIView *progressView = nil;
        if (progressViewStyle == SPProgressHUDProgressViewStyleAnnular) { // 环状
            SPHUDRoundProgressView *roundProgressView = [SPHUDRoundProgressView new];
            roundProgressView.progressTintColor = self.contentColor;
            progressView = roundProgressView;
        }
        else if (progressViewStyle == SPProgressHUDProgressViewStylePie) { // 饼状
            SPHUDRoundProgressView *roundProgressView = [SPHUDRoundProgressView new];
            roundProgressView.lineWidth = roundProgressView.intrinsicContentSize.width / 2.0;
            roundProgressView.progressTintColor = self.contentColor;
            progressView = roundProgressView;
        }
        else if (progressViewStyle == SPProgressHUDProgressViewStyleInnerRing) { // 内环
            SPHUDRoundProgressView *roundProgressView = [SPHUDRoundProgressView new];
            roundProgressView.annular = NO;
            roundProgressView.progressTintColor = self.contentColor;
            progressView = roundProgressView;
        }
        else if (progressViewStyle == SPProgressHUDProgressViewStyleBar) { // 柱状
            SPHUDBarProgressView *barProgressView = [SPHUDBarProgressView new];
            barProgressView.progressTintColor = self.contentColor;
            barProgressView.lineColor = self.contentColor;
            progressView = barProgressView;
        }
        progressView.translatesAutoresizingMaskIntoConstraints = NO;
        [self updateIndicatorWithView:progressView];
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

@end

@implementation SPHUDBarProgressView

#pragma mark - 初始化

- (id)init {
    return [self initWithFrame:CGRectMake(.0f, .0f, 120.0f, 10.0f)];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _lineWidth = 1.5f;
        _progress = 0.f;
        _lineColor = [UIColor whiteColor];
        _progressTintColor = [UIColor whiteColor];
        _progressRemainingTintColor = [UIColor clearColor];
        _intrinsicContentSize = CGRectEqualToRect(frame, CGRectZero) ? CGSizeMake(120, 10) : frame.size;
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
    }
    return self;
}

#pragma mark - 布局

- (CGSize)intrinsicContentSize {
    return _intrinsicContentSize;
}

#pragma mark - 属性

- (void)setProgress:(float)progress {
    if (progress != _progress) {
        _progress = progress;
        [self setNeedsDisplay];
    }
}

- (void)setProgressTintColor:(UIColor *)progressTintColor {
    if (progressTintColor != _progressTintColor && ![progressTintColor isEqual:_progressTintColor]) {
        _progressTintColor = progressTintColor;
        [self setNeedsDisplay];
    }
}

- (void)setProgressRemainingTintColor:(UIColor *)progressRemainingTintColor {
    if (progressRemainingTintColor != _progressRemainingTintColor && ![progressRemainingTintColor isEqual:_progressRemainingTintColor]) {
        _progressRemainingTintColor = progressRemainingTintColor;
        [self setNeedsDisplay];
    }
}

#pragma mark - 绘制

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 绘制边框
    float lineWidth = _lineWidth > rect.size.height/2-1 ? 2 : _lineWidth;
    float lineHalfWidth = lineWidth/2;
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetStrokeColorWithColor(context,[_lineColor CGColor]);
    CGContextSetFillColorWithColor(context, [_progressRemainingTintColor CGColor]);
    CGFloat radius = (rect.size.height / 2) - lineHalfWidth;
    CGContextMoveToPoint(context, lineHalfWidth, rect.size.height/2);
    CGContextAddArcToPoint(context, lineHalfWidth, lineHalfWidth, radius + lineHalfWidth, lineHalfWidth, radius);
    CGContextAddArcToPoint(context, rect.size.width - lineHalfWidth, lineHalfWidth, rect.size.width - lineHalfWidth, rect.size.height / 2, radius);
    CGContextAddArcToPoint(context, rect.size.width - lineHalfWidth, rect.size.height - lineHalfWidth, rect.size.width - radius - lineHalfWidth, rect.size.height - lineHalfWidth, radius);
    CGContextAddArcToPoint(context, lineHalfWidth, rect.size.height - lineHalfWidth, lineHalfWidth, rect.size.height/2, radius);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    // 绘制中间区域的中间矩形
    CGContextSetFillColorWithColor(context, [_progressTintColor CGColor]);
    radius = radius - lineHalfWidth;
    CGFloat amount = self.progress * rect.size.width;
    CGContextSetLineWidth(context, 1);
    
    // 圆弧跟边框总会有个微小的间隙,这个值是为了补充间隙
    CGFloat supplementSpacing = 0.2;
    
    if (amount >= radius + lineWidth && amount <= (rect.size.width - radius - lineWidth)) {
        CGContextMoveToPoint(context, lineWidth-supplementSpacing, rect.size.height/2);
        CGContextAddArcToPoint(context, lineWidth-supplementSpacing, lineWidth-supplementSpacing, radius + lineWidth, lineWidth-supplementSpacing, radius);
        CGContextAddLineToPoint(context, amount, lineWidth);
        CGContextAddLineToPoint(context, amount, radius + lineWidth);
        
        CGContextMoveToPoint(context, lineWidth-supplementSpacing, rect.size.height/2);
        CGContextAddArcToPoint(context, lineWidth-supplementSpacing, rect.size.height - lineWidth + supplementSpacing, radius + lineWidth, rect.size.height-lineWidth+supplementSpacing, radius);
        CGContextAddLineToPoint(context, amount, rect.size.height-lineWidth);
        CGContextAddLineToPoint(context, amount, radius + lineWidth);
        CGContextFillPath(context);
    }
    
    // 中间区域的右弧
    else if (amount > radius + lineWidth) {
        CGFloat x = amount - (rect.size.width - radius - lineWidth);
        
        CGContextMoveToPoint(context, lineWidth-supplementSpacing, rect.size.height/2);
        CGContextAddArcToPoint(context, lineWidth-supplementSpacing, lineWidth-supplementSpacing, radius + lineWidth, lineWidth-supplementSpacing, radius);
        CGContextAddLineToPoint(context, rect.size.width - radius - lineWidth, lineWidth-supplementSpacing);
        CGFloat angle = -acos(x/radius);
        if (isnan(angle)) angle = 0;
        CGContextAddArc(context, rect.size.width-radius-lineWidth, rect.size.height/2, radius+supplementSpacing, M_PI, angle, 0);
        CGContextAddLineToPoint(context, amount, rect.size.height/2);
        
        CGContextMoveToPoint(context, lineWidth-supplementSpacing, rect.size.height/2);
        CGContextAddArcToPoint(context, lineWidth-supplementSpacing, rect.size.height - lineWidth + supplementSpacing, radius + lineWidth, rect.size.height - lineWidth + supplementSpacing, radius);
        CGContextAddLineToPoint(context, rect.size.width - radius - lineWidth, rect.size.height - lineWidth);
        angle = acos(x/radius);
        if (isnan(angle)) angle = 0;
        CGContextAddArc(context, rect.size.width - radius - lineWidth, rect.size.height/2, radius+supplementSpacing, -M_PI, angle, 1);
        CGContextAddLineToPoint(context, amount, rect.size.height/2);
        
        CGContextFillPath(context);
    }
    
    // 中间区域的左弧
    else if (amount < radius + lineWidth && amount > 0) {
        CGContextMoveToPoint(context, lineWidth-supplementSpacing, rect.size.height/2);
        CGContextAddArcToPoint(context, lineWidth-supplementSpacing, lineWidth-supplementSpacing, radius + lineWidth, lineWidth-supplementSpacing, radius);
        CGContextAddLineToPoint(context, radius + lineWidth, rect.size.height/2);
        
        CGContextMoveToPoint(context, lineWidth-supplementSpacing, rect.size.height/2);
        CGContextAddArcToPoint(context, lineWidth-supplementSpacing, rect.size.height - lineWidth + supplementSpacing, radius + lineWidth, rect.size.height - lineWidth + supplementSpacing, radius);
        CGContextAddLineToPoint(context, radius + lineWidth, rect.size.height/2);
        
        CGContextFillPath(context);
    }
}

@end

@implementation SPHUDRoundProgressView

#pragma mark - 初始化

- (id)init {
    return [self initWithFrame:CGRectMake(0.f, 0.f, 37.f, 37.f)];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        _progress = 0.f;
        _lineWidth = 2.0;
        _annular = YES;
        _progressTintColor = [[UIColor alloc] initWithWhite:1.f alpha:1.f];
        _backgroundTintColor = [[UIColor alloc] initWithWhite:1.f alpha:.1f];
        _intrinsicContentSize = CGRectEqualToRect(frame, CGRectZero) ? CGSizeMake(37, 37) : frame.size;
    }
    return self;
}

#pragma mark - 布局

- (CGSize)intrinsicContentSize {
    return _intrinsicContentSize;
}

#pragma mark - 属性

- (void)setProgress:(float)progress {
    if (progress != _progress) {
        _progress = progress;
        [self setNeedsDisplay];
    }
}

- (void)setLineWidth:(float)lineWidth {
    if (lineWidth != _lineWidth) {
        _lineWidth = lineWidth;
        [self setNeedsDisplay];
    }
}

- (void)setProgressTintColor:(UIColor *)progressTintColor {
    if (progressTintColor != _progressTintColor && ![progressTintColor isEqual:_progressTintColor]) {
        _progressTintColor = progressTintColor;
        [self setNeedsDisplay];
    }
}

- (void)setBackgroundTintColor:(UIColor *)backgroundTintColor {
    if (backgroundTintColor != _backgroundTintColor && ![backgroundTintColor isEqual:_backgroundTintColor]) {
        _backgroundTintColor = backgroundTintColor;
        [self setNeedsDisplay];
    }
}

#pragma mark - 绘制

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (_annular) {
        CGFloat lineWidth = _lineWidth;
        UIBezierPath *processBackgroundPath = [UIBezierPath bezierPath];
        processBackgroundPath.lineWidth = lineWidth;
        processBackgroundPath.lineCapStyle = kCGLineCapButt;
        CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        CGFloat radius = (self.bounds.size.width - lineWidth)/2;
        CGFloat startAngle = - ((float)M_PI / 2); // 90 degrees
        CGFloat endAngle = (2 * (float)M_PI) + startAngle;
        [processBackgroundPath addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
        [_backgroundTintColor set];
        [processBackgroundPath stroke];
        
        UIBezierPath *processPath = [UIBezierPath bezierPath];
        processPath.lineCapStyle =  kCGLineCapButt;
        processPath.lineWidth = lineWidth;
        endAngle = (self.progress * 2 * (float)M_PI) + startAngle;
        [processPath addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
        [_progressTintColor set];
        [processPath stroke];
    } else {
        CGFloat lineWidth = _lineWidth;
        CGRect allRect = self.bounds;
        CGRect circleRect = CGRectInset(allRect, lineWidth/2.f, lineWidth/2.f);
        CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        [_progressTintColor setStroke];
        [_backgroundTintColor setFill];
        
        CGContextSetLineWidth(context, lineWidth);
        CGContextStrokeEllipseInRect(context, circleRect);
        CGFloat startAngle = - ((float)M_PI / 2.f);
        UIBezierPath *processPath = [UIBezierPath bezierPath];
        processPath.lineCapStyle = kCGLineCapButt;
        processPath.lineWidth = _lineWidth * 2;
        CGFloat radius = (CGRectGetWidth(self.bounds) / 2.f) - (processPath.lineWidth / 2.f);
        CGFloat endAngle = (self.progress * 2.f * (float)M_PI) + startAngle;
        [processPath addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
        // 确保在“ProgressTintColor Alpha<1.f”时不出现颜色重叠.
        CGContextSetBlendMode(context, kCGBlendModeCopy);
        [_progressTintColor set];
        [processPath stroke];
    }
}

@end

@implementation SPBezelView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        
        self.backgroundColor = [UIColor blackColor];
        self.clipsToBounds = YES;

        _supportedBlur = YES;
        [self updateForBackgroundStyle];
    }
    return self;
}

// 重写该方法极为重要,内容大小设置为zero,在对SPBezelView设置约束时便可以自适应内容大小
- (CGSize)intrinsicContentSize {
    return CGSizeZero;
}

- (void)setSupportedBlur:(BOOL)supportedBlur {
    if (_supportedBlur != supportedBlur) {
        _supportedBlur = supportedBlur;
        [self updateForBackgroundStyle];
    }
}

- (void)updateForBackgroundStyle {
    if (_supportedBlur) {
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        [self addSubview:effectView];
        effectView.frame = self.bounds;
        effectView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.layer.allowsGroupOpacity = NO;
        self.effectView = effectView;
    } else {
        [self.effectView removeFromSuperview];
        self.effectView = nil;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // 限制半径最大值,否则,半径设置过大,会导致控件不可见.
    CGFloat cornerRadius = self.layer.cornerRadius;
    CGFloat length = MIN(CGRectGetHeight(self.bounds), CGRectGetWidth(self.bounds));
    if (cornerRadius >= length / 2.0) {
        self.layer.cornerRadius = ceil(length / 2.f);
    }
}

@end

// 绘制成功图片
UIImage *displaySuccessImage(CGSize size, CGFloat inset) {
    CGRect imageRect = CGRectInset(CGRectMake(0, 0, size.width, size.height), inset, inset);
    CGFloat len = imageRect.size.width;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, inset, inset); // 整体矩阵偏移,目的是居中
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, 1.5);
    CGContextMoveToPoint(context, 0, len*1/2);
    CGContextAddLineToPoint(context, len*1/4, len*3/4); // 这个点的坐标,使得对勾图片的两条线段垂直.
    CGContextAddLineToPoint(context, len, 0);
    CGContextStrokePath(context);
    
    UIImage *successImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return successImage;
}

// 绘制失败图片
UIImage *displayErrorImage(CGSize size, CGFloat inset) {
    CGRect imageRect = CGRectInset(CGRectMake(0, 0, size.width, size.height), inset, inset);
    CGFloat len = imageRect.size.width;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, inset, inset); // 整体矩阵偏移,目的是居中
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, 1.5);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, len, len);
    CGContextMoveToPoint(context, len, 0);
    CGContextAddLineToPoint(context, 0, len);
    CGContextStrokePath(context);
    
    UIImage *successImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return successImage;
}

// 绘制详情图片
UIImage *displayInfoImage(CGSize size, CGFloat inset) {
    CGRect imageRect = CGRectInset(CGRectMake(0, 0, size.width, size.height), inset, inset);
    CGFloat len = imageRect.size.width;

    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1);
    CGContextAddEllipseInRect(context, imageRect);// 画外圆
    CGContextStrokePath(context);

    float lineWidth = 1.5;
    CGContextSetLineWidth(context, lineWidth);
    CGContextTranslateCTM(context, inset, inset); // 整体矩阵偏移,目的是居中
    float ox = len / 2.0;
    float oy = len / 4.5;
    float r = lineWidth / 2.0;
    CGContextAddArc(context, ox, oy, r, 0, M_PI * 2, 1); // 画小圆点
    CGContextFillPath(context); // 实心圆点
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextMoveToPoint(context, ox, oy + r + oy / 2.0);
    CGContextAddLineToPoint(context, ox, len - oy);
    CGContextStrokePath(context);
    
    UIImage *successImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return successImage;
}


