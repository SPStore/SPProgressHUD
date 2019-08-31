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

typedef void(^SPProgressHUDDismissSuccessHandle)(void);

@interface SPProgressHUD : UIView

// ------------------------------------------ 显示 ------------------------------------------

/**
 显示加载指示器,需要手动隐藏.
 
 @return SPProgressHUD对象.
 */
+ (instancetype)showActivity;

/**
 显示加载指示器,需要手动隐藏.
 
 @param message 文本消息.
 @return SPProgressHUD对象.
 */
+ (instancetype)showActivityWithMessage:(nullable NSString *)message;

/**
 显示加载指示器,需要手动隐藏.
 
 @param message 文本消息.
 @param offset 与中心点的偏移,默认CGPointZero(居中).
 @param view 父视图,nil默认为window.
 @return SPProgressHUD对象.
 */
+ (instancetype)showActivityWithMessage:(nullable NSString *)message
                                 offset:(CGPoint)offset
                                 toView:(nullable UIView *)view;

/**
 显示纯文本,自动隐藏.

 @param message 文本消息.
 @return SPProgressHUD对象.
 */
+ (instancetype)showWithMessage:(NSString *)message;

/**
 显示纯文本,自动隐藏.

 @param message 文本消息.
 @param duration 显示时长.
 @param offset 与中心点的偏移,默认CGPointZero(居中).
 @param view 父视图,nil默认为window.
 @return SPProgressHUD对象.
 */
+ (instancetype)showWithMessage:(NSString *)message
                       duration:(NSTimeInterval)duration
                         offset:(CGPoint)offset
                         toView:(nullable UIView *)view;

/**
 显示提示消息(自带提示图片),自动隐藏.
 
 @param message 文本消息.
 @return SPProgressHUD对象.
 */
+ (instancetype)showInfoWithMessage:(nullable NSString *)message;

/**
 显示提示消息(自带提示图片),自动隐藏.
 
 @param message 文本消息.
 @param duration 显示时间.
 @param offset 与中心点的偏移,默认CGPointZero(居中).
 @param view 父视图,nil默认为window.
 @return SPProgressHUD对象.
 */
+ (instancetype)showInfoWithMessage:(nullable NSString *)message
                           duration:(NSTimeInterval)duration
                             offset:(CGPoint)offset
                             toView:(nullable UIView *)view;

/**
 显示成功消息(自带成功图片),自动隐藏.
 
 @param message 成功消息.
 @return SPOCRLoadingHUD对象.
 */
+ (instancetype)showSuccessWithMessage:(nullable NSString *)message;

/**
 显示成功消息(自带成功图片),自动隐藏.
 
 @param message 成功消息.
 @param duration 显示时间.
 @param offset 与中心点的偏移,默认CGPointZero(居中).
 @param view 父视图,nil默认为window.
 @return SPProgressHUD对象.
 */
+ (instancetype)showSuccessWithMessage:(nullable NSString *)message
                              duration:(NSTimeInterval)duration
                                offset:(CGPoint)offset
                                toView:(nullable UIView *)view;

/**
 显示错误消息(自带失败图片),自动隐藏.
 
 @param message 错误消息.
 @return SPProgressHUD对象.
 */
+ (instancetype)showErrorWithMessage:(nullable NSString *)message;

/**
 显示错误消息(自带失败图片),自动隐藏.
 
 @param message 错误消息.
 @param duration 显示时间.
 @param offset 与中心点的偏移,默认CGPointZero(居中).
 @param view 父视图,nil默认为window.
 @return SPProgressHUD对象.
 */
+ (instancetype)showErrorWithMessage:(nullable NSString *)message
                            duration:(NSTimeInterval)duration
                              offset:(CGPoint)offset
                              toView:(nullable UIView *)view;


// ------------------------------------------ 隐藏 ------------------------------------------

// 类方法和实例方法隐藏的区别是：类方法隐藏的是父视图上最顶层的HUD,实例方法隐藏的是调用该方法的实例对象(SPProgressHUD对象),如果视图上只有一个HUD,类方法和实例方法等效.

/**
 从window上隐藏.

 @return 是否隐藏成功.
 */
+ (BOOL)dismiss;

/**
 从父view上延迟多少秒隐藏.
 
 @param delay 延迟的时间.
 @param view 父视图,nil默认为window.
 @return 是否隐藏成功.
 */
+ (BOOL)dismissAfterDelay:(NSTimeInterval)delay forView:(nullable UIView *)view;

/**
 从window上隐藏,如果视图上弹了多个SPProgressHUD,优先隐藏最后一个显示出来的.

 @param successHandle 隐藏成功的回调.
 @return 是否隐藏成功.
 */
+ (BOOL)dismissSuccessHandle:(nullable SPProgressHUDDismissSuccessHandle)successHandle;

/**
 从父view上延迟多少秒隐藏.

 @param view 父视图.
 @param delay 延迟的时间.
 @param successHandle 隐藏成功的回调.
 @return 是否隐藏成功.
 */
+ (BOOL)dismissAfterDelay:(NSTimeInterval)delay forView:(nullable UIView *)view successHandle:(nullable SPProgressHUDDismissSuccessHandle)successHandle;

/**
 从window上隐藏.
 */
- (void)dismiss;

/**
 从父view上延迟多少秒隐藏.

 @param delay 延迟的时间.
 */
- (void)dismissAfterDelay:(NSTimeInterval)delay;

/**
 从window上隐藏,实例方法隐藏指定的SPProgressHUD.

 @param successHandle 隐藏成功的回调.
 */
- (void)dismissSuccessHandle:(nullable SPProgressHUDDismissSuccessHandle)successHandle;

/**
 从父view上延迟多少秒隐藏.

 @param delay 延迟的时间.
 @param successHandle 隐藏成功的回调.
 */
- (void)dismissAfterDelay:(NSTimeInterval)delay successHandle:(nullable SPProgressHUDDismissSuccessHandle)successHandle;

/**
 隐藏父视图上所有的HUD.

 @param view 父视图,nil默认为window.
 @return 隐藏成功的个数.
 */
+ (NSUInteger)dismissAllHUDsForView:(nullable UIView *)view;

// ------------------------------------------ 设置 ------------------------------------------

+ (SPProgressHUD *)HUDForView:(nullable UIView *)view; // 获取父视图上最顶层的HUD.
+ (NSArray *)allHUDsForView:(nullable UIView *)view; // 获取父视图上所有的HUD.

/* 用一个自定义的view,代替默认的指示器(相当于自定义指示器).
  如果customView采用的是自动布局且大小能够被子控件撑起,或者本身就能被内容撑起(如设置了图片的UIImageView,设置了文字或图片的UIButton,重写了intrinsicContentSize等),需要设置customView的translatesAutoresizingMaskIntoConstraints为NO;
      如果是非自动布局,你只需要保证customView的宽高有值.
 */
- (void)replaceActivityWithCustomView:(UIView *)customView;

// 显示success/error/info图片的imageView. 如果想自定义success/error/info图片,直接设置该imageView的image即可.
@property (nonatomic, strong, readonly) UIImageView *imageView;
// 文本消息Label. 定制messageLabel的外观,文本等
@property (nonatomic, strong, readonly) UILabel *messageLabel;

// label相对其他子控件的位置,分上、左、下、右,默认在下.
@property (nonatomic, assign) SPProgressHUDLabelPosition labelPosition UI_APPEARANCE_SELECTOR;
// 内容颜色,比如UILabel的textColor,自带UIActivityIndicatorView的color,自带图片的tintColor等.
@property (nonatomic, strong, nullable) UIColor *contentColor UI_APPEARANCE_SELECTOR;
// 内容所在容器的颜色.
@property (nonatomic, strong, nullable) UIColor *color UI_APPEARANCE_SELECTOR;
// 蒙层背景颜色(如果直接设置HUD的backgroundColor没有alpha渐变动画).
@property (nonatomic, strong, nullable) UIColor *maskColor UI_APPEARANCE_SELECTOR;
// 内容的四周边距.
@property (nonatomic, assign) CGFloat margin UI_APPEARANCE_SELECTOR;
// 子控件之间的间距.
@property (nonatomic, assign) CGFloat spacing UI_APPEARANCE_SELECTOR;
// 相对中心点的偏移,无论offset.x/offset.y设置多大,都会保证HUD跟屏幕边缘至少有margin的距离. 即,如果想要使得HUD向某个方向移动到距离屏幕边缘margin的距离处,只要offset.x/offset.y的绝对值足够大就可以.
@property (nonatomic, assign) CGPoint offset UI_APPEARANCE_SELECTOR;
// 最小size,如果HUD的实际大小比minSize小,则最终大小会扩大到minSize.默认CGSizeZero
@property (nonatomic, assign) CGSize minSize UI_APPEARANCE_SELECTOR;
// 是否强制宽高相等.
@property (nonatomic, assign, getter=isSquare) BOOL square UI_APPEARANCE_SELECTOR;
// 圆角半径.
@property (nonatomic, assign) CGFloat cornerRadius UI_APPEARANCE_SELECTOR;
// 是否支持毛玻璃效果,默认YES.
@property (nonatomic, assign) BOOL supportedBlur UI_APPEARANCE_SELECTOR;
// 是否拥有视觉差效果,默认YES.
@property (assign, nonatomic, getter=areDefaultMotionEffectsEnabled) BOOL defaultMotionEffectsEnabled UI_APPEARANCE_SELECTOR;
// 隐藏成功时的回调.
@property (copy, nullable) SPProgressHUDDismissSuccessHandle dismissSuccessHandle;

@end

NS_ASSUME_NONNULL_END
