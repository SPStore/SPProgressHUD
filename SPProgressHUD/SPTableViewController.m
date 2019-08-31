//
//  SPTableViewController.m
//  SPProgressHUD
//
//  Created by 乐升平 on 2019/8/26.
//  Copyright © 2019 乐升平. All rights reserved.
//

#import "SPTableViewController.h"
#import "SPProgressHUD.h"
#import "SPBarProgressView.h"
#import "SPIndefiniteAnimatedView.h"

static NSString * SPDemoCellId     = @"SPDemoCellId";

@interface SPTableViewController ()
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) SPBarProgressView *progressView;
@end

@implementation SPTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:SPDemoCellId];
    
    self.dataSource = @[@[@"显示指示器",@"显示指示器+文本 (文本在下)",@"显示指示器+文本 (文本在右)",@" 显示指示器+文本 (文本在上)",@"显示指示器+文本 (文本在左)",@"自定义指示器(progress)",@"自定义指示器(饼状)",@"自定义指示器(一张图片)"],@[@"显示纯文本",@"显示提示",@"显示成功",@"显示失败"]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource[section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"指示器(需要手动隐藏)";
    } else {
        return @"其余内容(自动隐藏)";
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SPDemoCellId forIndexPath:indexPath];
    cell.textLabel.text = self.dataSource[indexPath.section][indexPath.row];
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.font = [UIFont systemFontOfSize:16.0];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) { // 显示指示器
            [SPProgressHUD showActivity];
            // 模拟网络请求
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [SPProgressHUD dismiss];
            });
        } else if (indexPath.row == 1) { // 显示指示器+文本(默认文本在下)
            [SPProgressHUD showActivityWithMessage:@"正在加载..."];
            // 模拟网络请求
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [SPProgressHUD dismiss];
            });
        } else if (indexPath.row == 2) { // 显示指示器+文本(文本在右)
            SPProgressHUD *hud = [SPProgressHUD showActivityWithMessage:@"正在加载..." offset:CGPointZero toView:nil];
            hud.labelPosition = SPProgressHUDLabelPositionRight;
            hud.messageLabel.font = [UIFont systemFontOfSize:14];
            hud.margin = 10;
            hud.cornerRadius = 50; // 半径实际上是作用在bezelView上，如果想设置全圆角样式，半径只要给适当大(大于或等于bezelView的高度)的值即可
            hud.minSize = CGSizeMake(180, 30);
            // 模拟网络请求
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // 类方法和实例方法隐藏的区别是：类方法隐藏的是当前视图上最顶层的HUD，实例方法隐藏的是指定的SPProgressHUD，如果视图上只有一个SPProgressHUD，那么类方法和实例方法是等效的
                [hud dismiss]; // [SPProgressHUD dismiss]
            });
        } else if (indexPath.row == 3) { // 显示指示器+文本(文本在上)
            SPProgressHUD *hud = [SPProgressHUD showActivityWithMessage:@"正在加载..." offset:CGPointZero toView:nil];
            hud.labelPosition = SPProgressHUDLabelPositionTop;
            // 模拟网络请求
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [SPProgressHUD dismiss];
            });
        } else if (indexPath.row == 4) { // 显示指示器+文本(文本在左)
            SPProgressHUD *hud = [SPProgressHUD showActivityWithMessage:@"正在加载..." offset:CGPointZero toView:nil];
            hud.labelPosition = SPProgressHUDLabelPositionLeft;
            hud.messageLabel.font = [UIFont systemFontOfSize:14];
            hud.margin = 10;
            hud.supportedBlur = NO;
            hud.color = [UIColor orangeColor];
            hud.contentColor = [UIColor whiteColor];
            hud.cornerRadius = 50; // 半径实际上是作用在bezelView上，如果想设置全圆角样式，半径只要给适当大(大于或等于bezelView的高度)的值即可
            hud.minSize = CGSizeMake(180, 30);
            // 模拟网络请求
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // 类方法和实例方法隐藏的区别是：类方法隐藏的是当前视图上所有SPProgressHUD中最后显示的那一个，实例方法隐藏的是指定的SPProgressHUD，如果视图上只有一个SPProgressHUD，那么类方法和实例方法是等效的
                [hud dismiss]; // [SPProgressHUD dismiss]
            });
        } else if (indexPath.row == 5) { // 自定义指示器(progress)
            
            SPBarProgressView *progressView = [[SPBarProgressView alloc] init]; // SPBarProgressView自带frame
            _progressView = progressView;
            SPProgressHUD *hud = [SPProgressHUD showActivityWithMessage:@"正在上传..."];
            [hud replaceActivityWithCustomView:progressView];
            // 模拟progress进度
            [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(progressSimulate:) userInfo:nil repeats:YES];
            
        } else if (indexPath.row == 6) { // 自定义指示器(饼状)
            SPIndefiniteAnimatedView *animationView = [[SPIndefiniteAnimatedView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
            animationView.strokeColor = [UIColor blackColor];
            animationView.strokeStart = 0.2;
            
            SPProgressHUD *hud = [SPProgressHUD showActivity];
            [hud replaceActivityWithCustomView:animationView];
            hud.color = [UIColor whiteColor];
            hud.maskColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
            hud.cornerRadius = 14.0f;
            [hud dismissAfterDelay:2.0];
        } else if (indexPath.row == 7) { // 自定义指示器(一张图片)
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.translatesAutoresizingMaskIntoConstraints = NO;
            imageView.image = [UIImage imageNamed:@"toast"];
            SPProgressHUD *hud = [SPProgressHUD showActivity];
            [hud replaceActivityWithCustomView:imageView];
            [hud dismissAfterDelay:2.0 successHandle:nil];
        }
    } else {
        if (indexPath.row == 0) {
           [SPProgressHUD showWithMessage:@"请稍后重试" duration:2.0 offset:CGPointMake(0, [UIScreen mainScreen].bounds.size.height * 3 / 8) toView:nil];
        } else if (indexPath.row == 1) {
           [SPProgressHUD showInfoWithMessage:@"详细信息"];
        } else if (indexPath.row == 2) {
           [SPProgressHUD showSuccessWithMessage:@"添加成功"];
        } else if (indexPath.row == 3) {
           [SPProgressHUD showErrorWithMessage:@"添加失败"];
        }
    }
}

- (void)progressSimulate:(NSTimer *)timer {
    static CGFloat progress = 0;
    if (progress < 1.0) {
        progress += 0.01;
        // 循环
        if (progress >= 1.0) {
            [timer invalidate];
            timer = nil;
            [SPProgressHUD dismissSuccessHandle:^{
                progress = 0;
            }];
        }
        _progressView.progress = progress; // 在MBProgressHUD里，进度值的赋值要保证在设置customView之后
    }
}

@end
