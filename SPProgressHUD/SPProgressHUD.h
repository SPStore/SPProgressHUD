//
//  SPProgressHUD.h
//  SPProgressHUD
//
//  Created by 乐升平 on 2019/8/23.
//  Copyright © 2019 乐升平. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,SPProgressHUDLabelPosition) {
    SPProgressHUDLabelPositionBottom = 0,    // Label在下
    SPProgressHUDLabelPositionRight,         // Label在右
    SPProgressHUDLabelPositionLeft,          // Label在左
    SPProgressHUDLabelPositionTop,           // Label在上
};

typedef NS_ENUM(NSInteger,SPProgressHUDProgressViewStyle) {
    SPProgressHUDProgressViewStyleAnnular = 0,   // 环状
    SPProgressHUDProgressViewStylePie,           // 饼状
    SPProgressHUDProgressViewStyleInnerRing,     // 内环
    SPProgressHUDProgressViewStyleBar,           // 柱状
};

typedef void(^SPProgressHUDHideCompletion)(void);

@interface SPProgressHUD : UIView

// ------------------------------------------ 显示 ------------------------------------------
// 注:(没有指定父view或者view为nil,默认显示在window上).

// 显示指示器
+ (instancetype)showActivity;
+ (instancetype)showActivityWithMessage:(nullable NSString *)message;
+ (instancetype)showActivityWithMessage:(nullable NSString *)message toView:(nullable UIView *)view;

// 显示纯文本
+ (instancetype)showWithMessage:(NSString *)message;
+ (instancetype)showWithMessage:(NSString *)message toView:(nullable UIView *)view;

// 显示成功
+ (instancetype)showSuccessWithMessage:(nullable NSString *)message;
+ (instancetype)showSuccessWithMessage:(nullable NSString *)message toView:(nullable UIView *)view;

// 显示失败
+ (instancetype)showErrorWithMessage:(nullable NSString *)message;
+ (instancetype)showErrorWithMessage:(nullable NSString *)message toView:(nullable UIView *)view;

// 显示详情
+ (instancetype)showInfoWithMessage:(nullable NSString *)message;
+ (instancetype)showInfoWithMessage:(nullable NSString *)message toView:(nullable UIView *)view;

// 显示自定义图片+文本
+ (instancetype)showWithImage:(UIImage *)image message:(NSString *)message;
+ (instancetype)showWithImage:(UIImage *)image
                      message:(NSString *)message
                       toView:(nullable UIView *)view;

// 显示进度条
+ (instancetype)showProgress;
+ (instancetype)showProgressWithMessage:(nullable NSString *)message;
+ (instancetype)showProgressWithMessage:(nullable NSString *)message toView:(nullable UIView *)view;

// 显示HUD,如果上一次使用类方法显示后再隐藏,想要通过该方法恢复显示,需要将removeFromSuperViewOnHide属性设置为NO;恢复显示的样式和上一次的样式一致.
- (void)show;

// ------------------------------------------ 隐藏 ------------------------------------------

// 类方法和实例方法隐藏的区别是:类方法隐藏的是父视图上最顶层的HUD,实例方法隐藏的是调用该方法的实例对象(SPProgressHUD对象),如果视图上只有一个HUD,类方法和实例方法等效.

// 隐藏window上最顶层的HUD.
+ (BOOL)hide;
+ (BOOL)hideAfterDelay:(NSTimeInterval)delay;

// 隐藏指定父视图上最顶层的HUD.
+ (BOOL)hideForView:(nullable UIView *)view;
+ (BOOL)hideForView:(nullable UIView *)view afterDelay:(NSTimeInterval)delay;

- (void)hide;
- (void)hideAfterDelay:(NSTimeInterval)delay;
- (void)hideAfterDelay:(NSTimeInterval)delay completion:(nullable SPProgressHUDHideCompletion)completion;

// 隐藏父视图上所有的HUD.
+ (NSUInteger)hideAllHUDsForView:(nullable UIView *)view;

// ------------------------------------------ 设置 ------------------------------------------

+ (SPProgressHUD *)HUDForView:(nullable UIView *)view; // 获取父视图上最顶层的HUD.
+ (NSArray *)allHUDsForView:(nullable UIView *)view; // 获取父视图上所有的HUD.

/**
 - 如果customView的translatesAutoresizingMaskIntoConstraints为NO,需要保证customView的intrinsicContentSize有值,HUD会根据intrinsicContentSize自动适应其大小.
 - 如果customView的translatesAutoresizingMaskIntoConstraints为YES:
 * 自动布局:如果customView大小能被子控件撑起,那么不需要再给customView设置size,HUD会自动获取customView被子控件撑起的大小(记为fittingSize),如果又手动设置了siz(记为settingSize),HUD会取fittingSize和settingSize中较大的那一个.
 * 非自动布局:如果customView本身就有intrinsicContentSize(如[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"xxx"]]),那么可以不用手动设置size,HUD会根据intrinsicContentSize适应其大小;否则需要给customView手动设置一个size.
 */
@property (nonatomic, strong) UIView *customView;

// 文本消息Label. 定制messageLabel的外观,设置文本内容等.
@property (nonatomic, strong, readonly) UILabel *messageLabel;
// label相对其他子控件的位置,分上、左、下、右,默认在下.
@property (nonatomic, assign) SPProgressHUDLabelPosition labelPosition UI_APPEARANCE_SELECTOR;

// 进度值(0.0 to 1.0).
@property (nonatomic, assign) float progress;
// 进度条样式.
@property (nonatomic, assign) SPProgressHUDProgressViewStyle progressViewStyle UI_APPEARANCE_SELECTOR;

// 内容颜色,比如UILabel的textColor,自带UIActivityIndicatorView的color,UIImage的tintColor等. 默认[UIColor colorWithWhite:0.f alpha:0.7f].
@property (nonatomic, strong, nullable) UIColor *contentColor UI_APPEARANCE_SELECTOR;

// 是否支持模糊效果,默认YES.
@property (nonatomic, assign) BOOL supportedBlur UI_APPEARANCE_SELECTOR;
// 内容所在容器的背景色. 如果想要使用实体颜色,需要将supportedBlur置为NO.否则color会有模糊效果.
@property (nonatomic, strong, nullable) UIColor *color UI_APPEARANCE_SELECTOR;
// 圆角半径. 设置足够大,就是全圆角.
@property (nonatomic, assign) CGFloat cornerRadius UI_APPEARANCE_SELECTOR;

// 蒙层背景颜色(如果直接设置HUD的backgroundColor没有alpha渐变动画).
@property (nonatomic, strong, nullable) UIColor *maskColor UI_APPEARANCE_SELECTOR;

// 相对中心点的偏移,默认CGPointZero(居中),无论offset.x/offset.y设置多大,都会保证HUD跟屏幕边缘至少有margin的距离. 即,如果想要使得HUD向某个方向移动到离屏幕边缘margin的距离处,只要offset.x/offset.y的绝对值足够大.
@property (nonatomic, assign) CGPoint offset UI_APPEARANCE_SELECTOR;
// 内容的四周边距.
@property (nonatomic, assign) CGFloat margin UI_APPEARANCE_SELECTOR;
// 子控件之间的间距.
@property (nonatomic, assign) CGFloat spacing UI_APPEARANCE_SELECTOR;
// 最小size,如果HUD的实际大小比minSize小,则最终大小会扩大到minSize.默认CGSizeZero.
@property (nonatomic, assign) CGSize minSize UI_APPEARANCE_SELECTOR;
// 是否强制宽高相等.
@property (nonatomic, assign, getter=isSquare) BOOL square UI_APPEARANCE_SELECTOR;

// 隐藏时是否从父视图上移除,当采用类方法显示时,默认YES.
@property (assign, nonatomic) BOOL removeFromSuperViewOnHide;

// 是否拥有视觉差效果,默认YES.
@property (assign, nonatomic, getter=areDefaultMotionEffectsEnabled) BOOL defaultMotionEffectsEnabled UI_APPEARANCE_SELECTOR;

// 是否使用隐藏动画,默认YES. 如果想要'hideCompletion'立刻回调,可以将该属性置为NO.
@property (nonatomic, assign, getter=isUseHideAnimation) BOOL useHideAnimation UI_APPEARANCE_SELECTOR;

// 隐藏完成时的回调. 用类方法隐藏时,只有隐藏成功才会回调. 回调的时间,跟'useHideAnimation'有关.
@property (copy, nullable) SPProgressHUDHideCompletion hideCompletion;

@end

NS_ASSUME_NONNULL_END
