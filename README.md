# SPProgressHUD
这是一款拥有指示器加载、toast、进度条等功能的组件.

[![](https://raw.githubusercontent.com/wiki/SPStore/SPProgressHUD/Screenshots/1-small.png)](https://raw.githubusercontent.com/wiki/SPStore/SPProgressHUD/Screetshots/1.png)
[![](https://raw.githubusercontent.com/wiki/SPStore/SPProgressHUD/Screenshots/2-small.png)](https://raw.githubusercontent.com/wiki/SPStore/SPProgressHUD/Screetshots/2.png)
[![](https://raw.githubusercontent.com/wiki/SPStore/SPProgressHUD/Screenshots/3-small.png)](https://raw.githubusercontent.com/wiki/SPStore/SPProgressHUD/Screetshots/3.png)
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
