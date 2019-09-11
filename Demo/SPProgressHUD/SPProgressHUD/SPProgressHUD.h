//
//  SPProgressHUD.h
//  Version 1.0.0
//
//  Created by 乐升平 on 2019/8/23.
//  Copyright © 2019 乐升平. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat const SPProgressMaxOffset;

NS_ASSUME_NONNULL_BEGIN

/// messageLabel的位置.
typedef NS_ENUM(NSInteger,SPProgressHUDLabelPosition) {
    /// messageLabel在下.
    SPProgressHUDLabelPositionBottom = 0,
    /// messageLabel在右.
    SPProgressHUDLabelPositionRight,
    /// messageLabel在左.
    SPProgressHUDLabelPositionLeft,
    /// messageLabel在上.
    SPProgressHUDLabelPositionTop,
};

/// 进度条的样式.
typedef NS_ENUM(NSInteger,SPProgressHUDProgressViewStyle) {
    /// 环状.
    SPProgressHUDProgressViewStyleAnnular = 0,
    /// 饼状.
    SPProgressHUDProgressViewStylePie,
    /// 内环.
    SPProgressHUDProgressViewStyleInnerRing,
    /// 柱状.
    SPProgressHUDProgressViewStyleBar,
};

/// 隐藏完成的block重命名.
typedef void(^SPProgressHUDHideCompletion)(void);

/**
 展示一个简单的显示器窗口,包含了指示器,可选的文本消息,进度条,成功、失败等图片.
 
 @note 如果在显示的HUD的时候,需要在你的视图上进行交互,可以设置hud.userInteractionEnabled = NO.
 */
@interface SPProgressHUD : UIView

///-----------------------------------
/// @name Show
///-----------------------------------

/**
 创建一个HUD,添加到view上,并在view的中心显示不带文本的指示器(UIActivityIndicatorView).

 @param view 父视图,如果想添加在window上,你可以使用`SPProgressHUD.defaultWindow`.
 @return SPProgressHUD对象.
  */
+ (instancetype)showActivityToView:(UIView *)view;

/**
 创建一个HUD,添加到view上,并在view的中心显示带文本的指示器(UIActivityIndicatorView).

 @param message 文本消息.
 @param view 父视图,你可以使用`defaultWindow`,例如:SPProgressHUD.defaultWindow.
 @return SPProgressHUD对象.
 */
+ (instancetype)showActivityWithMessage:(nullable NSString *)message toView:(UIView *)view;

/**
 创建一个HUD,添加到view上,并在view的中心显示纯文本.

 @param message 文本消息.
 @param view 父视图.你可以使用`defaultWindow`,例如:SPProgressHUD.defaultWindow.
 @return SPProgressHUD对象.
 */
+ (instancetype)showWithMessage:(nullable NSString *)message toView:(UIView *)view;

/**
 创建一个HUD,添加到view上,并view的某个位置显示纯文本.

 @param message 文本消息.
 @param offset 相对中心点的偏移,默认CGPointZero(居中).你可以使用SPProgressMaxOffset和 -SPProgressMaxOffset移动HUD到屏幕边缘.距离屏幕边缘的距离为margin.例如,CGPointMake(0.f, SPProgressMaxOffset)处于距离屏幕底部为margin的位置.
 @param view 父视图,你可以使用`defaultWindow`,例如:SPProgressHUD.defaultWindow.
 @return SPProgressHUD对象.
 */
+ (instancetype)showWithMessage:(nullable NSString *)message
                         offset:(CGPoint)offset
                         toView:(UIView *)view;

/**
 创建一个HUD,添加到view上,并在view的中心显示成功.

 @param message 文本消息.
 @param view 父视图,你可以使用`defaultWindow`,例如:SPProgressHUD.defaultWindow.
 @return SPProgressHUD对象.
 */
+ (instancetype)showSuccessWithMessage:(nullable NSString *)message toView:(UIView *)view;

/**
 创建一个HUD,添加到view上,并在view的中心显示失败.
 
 @param message 文本消息.
 @param view 父视图,你可以使用`defaultWindow`,例如:SPProgressHUD.defaultWindow.
 @return SPProgressHUD对象.
 */
+ (instancetype)showErrorWithMessage:(nullable NSString *)message toView:(UIView *)view;

/**
 创建一个HUD,添加到view上,并在view的中心显示详情.
 
 @param message 文本消息.
 @param view 父视图,你可以使用`defaultWindow`,例如:SPProgressHUD.defaultWindow.
 @return SPProgressHUD对象.
 */
+ (instancetype)showInfoWithMessage:(nullable NSString *)message toView:(UIView *)view;

/**
 创建一个HUD,添加到view上,并在view的中心显示自定义图片+文本.
 
 @param image 自定义图片.
 @param message 文本消息.
 @param offset 相对中心点的偏移,默认CGPointZero(居中).你可以使用SPProgressMaxOffset和 -SPProgressMaxOffset移动HUD到屏幕边缘.距离屏幕边缘的距离为margin.例如,CGPointMake(0.f, SPProgressMaxOffset)处于距离屏幕底部为margin的位置.
 @param view 父视图,你可以使用`defaultWindow`,例如:SPProgressHUD.defaultWindow.
 @return SPProgressHUD对象.
 */
+ (instancetype)showWithImage:(nullable UIImage *)image
                      message:(nullable NSString *)message
                       offset:(CGPoint)offset
                       toView:(UIView *)view;

/**
 创建一个HUD,添加到view上,并在view的中心显示不带文本的进度条.

 @param view 父视图.
 @return SPProgressHUD对象.
 */
+ (instancetype)showProgressToView:(UIView *)view;

/**
 创建一个HUD,添加到view上,并在view的中心显示带文本的进度条.

 @param message 文本消息.
 @param view 父视图.
 @return SPProgressHUD对象.
 */
+ (instancetype)showProgressWithMessage:(nullable NSString *)message toView:(UIView *)view;

/**
 显示HUD,如果上一次使用类方法显示后再隐藏,想要通过该方法恢复显示,需要将removeFromSuperViewOnHide属性设置为NO;恢复显示的样式和上一次的样式一致.
 */
- (void)show;

///-----------------------------------
/// @name Hide
///-----------------------------------

/**
 隐藏父视图上最顶层的HUD.

 @param view 父视图,需要与显示时的`view`一致.
 @return 是否隐藏成功.
 */
+ (BOOL)hideForView:(UIView *)view;

/**
 延迟隐藏父视图上最顶层的HUD.

 @param view 父视图,需要与显示时的`view`一致.
 @param delay 延迟的时间.
 @return 是否隐藏成功.
 */
+ (BOOL)hideForView:(UIView *)view afterDelay:(NSTimeInterval)delay;

/**
 隐藏HUD.
 */
- (void)hide;

/**
 延迟隐藏HUD.

 @param delay 延迟隐藏的时间.
 */
- (void)hideAfterDelay:(NSTimeInterval)delay;

/**
 延迟隐藏HUD.

 @param delay 延迟隐藏的时间.
 @param completion 隐藏完成时的回调.隐藏动画执行完成才开始回调,如果想要隐藏时立即回调,可设置`useHideAnimation`为NO.
 */
- (void)hideAfterDelay:(NSTimeInterval)delay completion:(nullable SPProgressHUDHideCompletion)completion;

/**
 隐藏父视图上所有的HUD.

 @param view 父视图
 @return 隐藏成功的HUD的个数.
 */
+ (NSUInteger)hideAllHUDsForView:(UIView *)view;

///-----------------------------------
/// @name 查找.
///-----------------------------------

/**
 查找并返回view上最顶层的HUD.
 */
+ (nullable SPProgressHUD *)HUDForView:(UIView *)view;

/**
 查找并返回view上所有的HUD.
*/
+ (NSArray *)allHUDsForView:(UIView *)view;

/**
 SPProgressHUD提供的默认window.
 */
+ (nullable UIWindow *)defaultWindow;

///-----------------------------------
/// @name 设置.
///-----------------------------------

/**
 * 自定义view.
 
 * 如果customView的translatesAutoresizingMaskIntoConstraints为NO,
 * 需要保证customView的intrinsicContentSize有值,HUD会根据intrinsicContentSize自动适应其大小.
 
 * 如果customView的translatesAutoresizingMaskIntoConstraints为YES:
 
   1.自动布局:如果customView大小能被子控件撑起,那么不需要再给customView设置size,
      HUD会自动获取customView被子控件撑起的大小(记为fittingSize),
      如果又手动设置了siz(记为settingSize),HUD会取fittingSize和settingSize中较大的那一个.
 
   2.非自动布局:如果customView本身就有intrinsicContentSize
     (如`[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"xxx"]]`),
      那么可以不用手动设置size,HUD会根据intrinsicContentSize适应其大小;
      否则需要给customView手动设置一个size
 */
@property (nonatomic, strong) UIView *customView;

/**
 展示文本消息的Label.
 */
@property (nonatomic, strong, readonly) UILabel *messageLabel;

/**
 messageLabel的位置,默认在下.
 */
@property (nonatomic, assign) SPProgressHUDLabelPosition labelPosition UI_APPEARANCE_SELECTOR;

/**
 进度值(0.0 to 1.0).
 */
@property (nonatomic, assign) float progress;

/**
 进度条样式.
 */
@property (nonatomic, assign) SPProgressHUDProgressViewStyle progressViewStyle UI_APPEARANCE_SELECTOR;

/**
 内容颜色,比如UILabel的textColor,自带UIActivityIndicatorView的color,UIImage的tintColor等. 默认[UIColor colorWithWhite:0.f alpha:0.7f].
 */
@property (nonatomic, strong, nullable) UIColor *contentColor UI_APPEARANCE_SELECTOR;

/**
 是否支持模糊效果,默认YES.
 */
@property (nonatomic, assign) BOOL supportedBlur UI_APPEARANCE_SELECTOR;

/**
 内容所在容器的背景色. 如果想要使用实体颜色,需要将supportedBlur置为NO.否则color会有模糊效果.
 */
@property (nonatomic, strong, nullable) UIColor *color UI_APPEARANCE_SELECTOR;

/**
 圆角半径. 如果想要设置圆角半径为宽/高的一半,设置该值为足够大就可以.
 */
@property (nonatomic, assign) CGFloat cornerRadius UI_APPEARANCE_SELECTOR;

/**
 蒙层背景颜色(如果直接设置HUD的backgroundColor没有alpha渐变动画).
 */
@property (nonatomic, strong, nullable) UIColor *maskColor UI_APPEARANCE_SELECTOR;

/**
 内容的四周边距,同时也是HUD相对屏幕边缘的最小边距.
 */
@property (nonatomic, assign) CGFloat margin UI_APPEARANCE_SELECTOR;

/**
 * 相对中心点的偏移,默认CGPointZero(居中).你可以使用SPProgressMaxOffset
 * 和 -SPProgressMaxOffset移动HUD到屏幕边缘.距离屏幕边缘的距离为margin.
 * 例如,CGPointMake(0.f, SPProgressMaxOffset)处于距离屏幕底部为margin的位置.
 */
@property (nonatomic, assign) CGPoint offset UI_APPEARANCE_SELECTOR;

/**
 子控件之间的间距.
 */
@property (nonatomic, assign) CGFloat spacing UI_APPEARANCE_SELECTOR;

/**
 最小size.默认CGSizeZero. 如果设置了该值,则HUD的实际显示大小 >= minSize.
 */
@property (nonatomic, assign) CGSize minSize UI_APPEARANCE_SELECTOR;

/**
 是否强制宽高相等.
 */
@property (nonatomic, assign, getter=isSquare) BOOL square UI_APPEARANCE_SELECTOR;

/**
 隐藏时是否从父视图上移除,当采用类方法显示时,默认YES.
 */
@property (assign, nonatomic) BOOL removeFromSuperViewOnHide;

/**
 是否拥有视觉差效果,默认YES.
 */
@property (assign, nonatomic, getter=areDefaultMotionEffectsEnabled) BOOL defaultMotionEffectsEnabled UI_APPEARANCE_SELECTOR;

/**
 是否使用隐藏动画,默认YES.
 */
@property (nonatomic, assign, getter=isUseHideAnimation) BOOL useHideAnimation UI_APPEARANCE_SELECTOR;

/**
 隐藏完成时的回调.隐藏动画执行完成才开始回调,如果想要隐藏时立即回调,可设置`useHideAnimation`为NO.
 */
@property (copy, nullable) SPProgressHUDHideCompletion hideCompletion;

@end


NS_ASSUME_NONNULL_END


