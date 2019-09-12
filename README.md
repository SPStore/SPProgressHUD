# SPProgressHUD
[![Build Status](http://img.shields.io/travis/SPStore/SPProgressHUD.svg?style=flat)](https://travis-ci.org/SPStore/SPAlertController)
[![Pod Version](http://img.shields.io/cocoapods/v/SPProgressHUD.svg?style=flat)](http://cocoadocs.org/docsets/SPAlertController/)
[![Pod Platform](http://img.shields.io/cocoapods/p/SPProgressHUD.svg?style=flat)](http://cocoadocs.org/docsets/SPAlertController/)
![Language](https://img.shields.io/badge/language-Object--C-ff69b4.svg)
[![Pod License](http://img.shields.io/cocoapods/l/SPProgressHUD.svg?style=flat)](https://www.apache.org/licenses/LICENSE-2.0.html)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/SPStore/SPProgressHUD)

这是一款拥有指示器加载、toast、进度条等功能的组件.

[![](https://raw.githubusercontent.com/wiki/SPStore/SPProgressHUD/Screetshots/1-small.png)](https://raw.githubusercontent.com/wiki/SPStore/SPProgressHUD/Screetshots/1.png)
[![](https://raw.githubusercontent.com/wiki/SPStore/SPProgressHUD/Screetshots/2-small.png)](https://raw.githubusercontent.com/wiki/SPStore/SPProgressHUD/Screetshots/2.png)
[![](https://raw.githubusercontent.com/wiki/SPStore/SPProgressHUD/Screetshots/3-small.png)](https://raw.githubusercontent.com/wiki/SPStore/SPProgressHUD/Screetshots/3.png)
[![](https://raw.githubusercontent.com/wiki/SPStore/SPProgressHUD/Screetshots/4-small.png)](https://raw.githubusercontent.com/wiki/SPStore/SPProgressHUD/Screetshots/4.png)
[![](https://raw.githubusercontent.com/wiki/SPStore/SPProgressHUD/Screetshots/5-small.png)](https://raw.githubusercontent.com/wiki/SPStore/SPProgressHUD/Screetshots/5.png)
[![](https://raw.githubusercontent.com/wiki/SPStore/SPProgressHUD/Screetshots/6-small.png)](https://raw.githubusercontent.com/wiki/SPStore/SPProgressHUD/Screetshots/6.png)
[![](https://raw.githubusercontent.com/wiki/SPStore/SPProgressHUD/Screetshots/7-small.png)](https://raw.githubusercontent.com/wiki/SPStore/SPProgressHUD/Screetshots/7.png)
[![](https://raw.githubusercontent.com/wiki/SPStore/SPProgressHUD/Screetshots/8-small.png)](https://raw.githubusercontent.com/wiki/SPStore/SPProgressHUD/Screetshots/8.png)
[![](https://raw.githubusercontent.com/wiki/SPStore/SPProgressHUD/Screetshots/9-small.png)](https://raw.githubusercontent.com/wiki/SPStore/SPProgressHUD/Screetshots/9.png)
[![](https://raw.githubusercontent.com/wiki/SPStore/SPProgressHUD/Screetshots/10-small.png)](https://raw.githubusercontent.com/wiki/SPStore/SPProgressHUD/Screetshots/10.png)
[![](https://raw.githubusercontent.com/wiki/SPStore/SPProgressHUD/Screetshots/11-small.png)](https://raw.githubusercontent.com/wiki/SPStore/SPProgressHUD/Screetshots/11.png)
[![](https://raw.githubusercontent.com/wiki/SPStore/SPProgressHUD/Screetshots/12-small.png)](https://raw.githubusercontent.com/wiki/SPStore/SPProgressHUD/Screetshots/12.png)
[![](https://raw.githubusercontent.com/wiki/SPStore/SPProgressHUD/Screetshots/13-small.png)](https://raw.githubusercontent.com/wiki/SPStore/SPProgressHUD/Screetshots/13.png)
[![](https://raw.githubusercontent.com/wiki/SPStore/SPProgressHUD/Screetshots/14-small.png)](https://raw.githubusercontent.com/wiki/SPStore/SPProgressHUD/Screetshots/14.png)

## CocoaPods
##### 版本0.0.1
```
platform:ios,'8.0'
target 'MyApp' do
  pod 'SPAlertController', '~> 0.0.1'
end
```
## 使用示例
```
    [SPProgressHUD showActivityWithMessage:@"正在加载..." toView:self.view];
    __weak typeof(self) weakSelf = self;
    // 模拟网络请求
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        sleep(1.2);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SPProgressHUD hideForView:weakSelf.view]; // 如果显示的时候指定了父视图，隐藏时也必须指定且跟显示时一致.
        });
    });
```
更多示例，可查看工程中的Demo

## 显示HUD
显示指示器,默认为UIActivityIndicatorView
```objective-c
+ (instancetype)showActivityToView:(UIView *)view;
+ (instancetype)showActivityWithMessage:(nullable NSString *)message toView:(UIView *)view;
```
显示纯文本
```objective-c
+ (instancetype)showWithMessage:(nullable NSString *)message toView:(UIView *)view;
+ (instancetype)showWithMessage:(nullable NSString *)message
                         offset:(CGPoint)offset
                         toView:(UIView *)view;
```
显示成功
```objective-c
+ (instancetype)showSuccessWithMessage:(nullable NSString *)message toView:(UIView *)view;
```
显示失败
```objective-c
+ (instancetype)showErrorWithMessage:(nullable NSString *)message toView:(UIView *)view;
```
显示详情
```objective-c
+ (instancetype)showInfoWithMessage:(nullable NSString *)message toView:(UIView *)view;
```
显示自定义图片+文本
```objective-c
+ (instancetype)showWithImage:(nullable UIImage *)image
                      message:(nullable NSString *)message
                       offset:(CGPoint)offset
                       toView:(UIView *)view;
```
显示进度条
```objective-c
+ (instancetype)showProgressToView:(UIView *)view;
+ (instancetype)showProgressWithMessage:(nullable NSString *)message toView:(UIView *)view;
```
## 隐藏HUD (如果视图上只有一个HUD，类方法隐藏和实例方法隐藏等效)
类方法隐藏父视图上最顶层的HUD.
```objective-c
+ (BOOL)hideForView:(UIView *)view;
+ (BOOL)hideForView:(UIView *)view afterDelay:(NSTimeInterval)delay;
```
实例方法隐藏的是指定的HUD.
```objective-c
- (void)hide;
- (void)hideAfterDelay:(NSTimeInterval)delay;
- (void)hideAfterDelay:(NSTimeInterval)delay completion:(nullable SPProgressHUDHideCompletion)completion;
```
隐藏所有HUD.
```objective-c
+ (NSUInteger)hideAllHUDsForView:(UIView *)view;
```
## 查找
查找HUD
```objective-c
+ (nullable SPProgressHUD *)HUDForView:(UIView *)view; // 查找视图上最顶层的HUD.
+ (NSArray *)allHUDsForView:(UIView *)view; // 查找视图上所有的HUD.
```
获取window，当你想要让HUD显示在window上的时候，可以调用此方法，如:[SPProgressHUD showActivityToView:SPProgressHUD.defaultWindow]
```objective-c
+ (nullable UIWindow *)defaultWindow;
```
## 设置
```objective-c
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
```
```objective-c
@property (nonatomic, strong, readonly) UILabel *messageLabel;                                         // 展示文本消息的Label.
@property (nonatomic, assign) SPProgressHUDLabelPosition labelPosition UI_APPEARANCE_SELECTOR;         // messageLabel的位置,默认在下.
@property (nonatomic, assign) float progress; // 进度值(0.0 to 1.0).
@property (nonatomic, assign) SPProgressHUDProgressViewStyle progressViewStyle UI_APPEARANCE_SELECTOR; // 进度条样式.
@property (nonatomic, strong, nullable) UIColor *contentColor UI_APPEARANCE_SELECTOR;                  // 内容颜色,比如UILabel的textColor,自带UIActivityIndicatorView的color,UIImage的tintColor等. 默认[UIColor colorWithWhite:0.f alpha:0.7f].
@property (nonatomic, assign) BOOL supportedBlur UI_APPEARANCE_SELECTOR;                               // 是否支持模糊效果,默认YES.
@property (nonatomic, strong, nullable) UIColor *color UI_APPEARANCE_SELECTOR;                         // 内容所在容器的背景色. 如果想要使用实体颜色,需要将supportedBlur置为NO.否则color会有模糊效果.
@property (nonatomic, assign) CGFloat cornerRadius UI_APPEARANCE_SELECTOR;                             // 圆角半径. 如果想要设置圆角半径为宽/高的一半,设置该值为足够大就可以.
@property (nonatomic, strong, nullable) UIColor *maskColor UI_APPEARANCE_SELECTOR;                     // 蒙层背景颜色(如果直接设置HUD的backgroundColor没有alpha渐变动画).
@property (nonatomic, assign) CGFloat margin UI_APPEARANCE_SELECTOR;                                   // 内容的四周边距,同时也是HUD相对屏幕边缘的最小边距.
@property (nonatomic, assign) CGPoint offset UI_APPEARANCE_SELECTOR;                                   // 相对中心点的偏移,默认CGPointZero(居中).你可以使用SPProgressMaxOffset和 -SPProgressMaxOffset移动HUD到屏幕边缘.距离屏幕边缘的距离为margin.例如,CGPointMake(0.f, SPProgressMaxOffset)处于距离屏幕底部为margin的位置.
@property (nonatomic, assign) CGFloat spacing UI_APPEARANCE_SELECTOR;                                  // 子控件之间的间距.
@property (nonatomic, assign) CGSize minSize UI_APPEARANCE_SELECTOR;                                   // 最小size.默认CGSizeZero. 如果设置了该值,则HUD的实际显示大小 >= minSize.
@property (nonatomic, assign, getter=isSquare) BOOL square UI_APPEARANCE_SELECTOR;                     // 是否强制宽高相等.
@property (assign, nonatomic) BOOL removeFromSuperViewOnHide;                                          // 隐藏时是否从父视图上移除,当采用类方法显示时,默认YES.
@property (assign, nonatomic, getter=areDefaultMotionEffectsEnabled) BOOL defaultMotionEffectsEnabled UI_APPEARANCE_SELECTOR;// 是否拥有视觉差效果,默认YES.
@property (nonatomic, assign, getter=isUseHideAnimation) BOOL useHideAnimation UI_APPEARANCE_SELECTOR; // 是否使用隐藏动画,默认YES.
@property (copy, nullable) SPProgressHUDHideCompletion hideCompletion;                                 // 隐藏完成时的回调.隐藏动画执行完成才开始回调,如果想要隐藏时立即回调,可设置`useHideAnimation`为NO.

```

## FAQ
Q1、当HUD显示的时候，如何跟界面进行交互?<br>
A1、你可以关闭HUD的交互，如 `hud.userInteractionEnabled = NO`<br><br>

Q2、如何快速的让HUD显示在window上?<br>
A2、你可以使用SPProgressHUD提供的默认window，如 `[SPProgressHUD showActivityToView:SPProgressHUD.defaultWindow]`<br><br>

Q3、如何全局定制HUD的样式?<br>
A3、你可以通过appearance方法对HUD全局定制，如:
```objective-c
[SPProgressHUD appearance].contentColor = [UIColor blackColor];
[SPProgressHUD appearance].color = [[UIColor whiteColor] colorWithAlphaComponent:0.75];
[SPProgressHUD appearance].maskColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
[SPProgressHUD appearance].offset = CGPointMake(0, SPProgressMaxOffset);
[SPProgressHUD appearance].spacing = 10;
```



