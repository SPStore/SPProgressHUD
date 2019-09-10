//
//  SPTableViewController.m
//  SPProgressHUD
//
//  Created by 乐升平 on 2019/8/26.
//  Copyright © 2019 乐升平. All rights reserved.
//

#import "SPTableViewController.h"
#import "SPProgressHUD.h"
#import "SPIndefiniteAnimatedView.h"

@interface SPExample : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) SEL selector;

@end


@implementation SPExample

+ (instancetype)exampleWithTitle:(NSString *)title selector:(SEL)selector {
    SPExample *example = [[self class] new];
    example.title = title;
    example.selector = selector;
    return example;
}

@end

static NSString * SPExampleCellID     = @"SPExampleCellID";

@interface SPTableViewController ()
@property (nonatomic, strong) NSArray *examples;
@property (nonatomic, strong) UIView *progressView;
@end

@implementation SPTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:SPExampleCellID];
    
    self.examples =
    @[@[[SPExample exampleWithTitle:@"显示指示器" selector:@selector(activityExample)],
        [SPExample exampleWithTitle:@"显示指示器+文本" selector:@selector(activityWithLabelExample)],
        [SPExample exampleWithTitle:@"显示指示器+文本（文本在右）" selector:@selector(activityWithRightLabelExample)]],
      @[[SPExample exampleWithTitle:@"显示纯文本" selector:@selector(labelExample)],
        [SPExample exampleWithTitle:@"显示成功" selector:@selector(successsExample)],
        [SPExample exampleWithTitle:@"显示失败" selector:@selector(failureExample)],
        [SPExample exampleWithTitle:@"显示详情" selector:@selector(infoExample)],
        [SPExample exampleWithTitle:@"显示自定义图片+文本" selector:@selector(imageLabelExample)]],
      @[[SPExample exampleWithTitle:@"显示环状进度条" selector:@selector(annularProgressBarExample)],
        [SPExample exampleWithTitle:@"显示饼状进度条" selector:@selector(pieProgressBarExample)],
        [SPExample exampleWithTitle:@"显示环状进度条(内切)" selector:@selector(innerRingProgressBarExample)],
        [SPExample exampleWithTitle:@"显示柱状进度条" selector:@selector(barProgressBarExample)],],
      @[[SPExample exampleWithTitle:@"自定义指示器" selector:@selector(customizeActivityForTurnRoundExample)],
        [SPExample exampleWithTitle:@"自定义一张图片" selector:@selector(customizeImageExample)]]
      ];
}

#pragma mark - Examples

// 显示指示器
- (void)activityExample {
    // 模拟网络请求
    [SPProgressHUD showActivity];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        sleep(1.2);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SPProgressHUD hide];
        });
    });
}

// 显示指示器+文本
- (void)activityWithLabelExample {
    [SPProgressHUD showActivityWithMessage:@"正在加载..." toView:self.view];
    __weak typeof(self) weakSelf = self;
    // 模拟网络请求
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        sleep(1.2);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SPProgressHUD hideForView:weakSelf.view]; // 如果显示的时候指定了父视图，隐藏时也必须指定且跟显示时一致.
        });
    });
}

// 显示指示器+文本(文本在右)
- (void)activityWithRightLabelExample {
    SPProgressHUD *hud = [SPProgressHUD showActivityWithMessage:@"正在加载..."];
    hud.labelPosition = SPProgressHUDLabelPositionRight; // 文本的位置
    hud.minSize = CGSizeMake(180, 40); // 最小size
    hud.margin = 10; // 内容与四周的间距
    hud.cornerRadius = 10000; // 半径设置足够大，就是全圆角.
    hud.supportedBlur = NO; // 去除毛玻璃效果
    hud.color = [UIColor orangeColor]; // HUD的背景色
    hud.contentColor = [UIColor whiteColor]; // 内容颜色
    hud.messageLabel.font = [UIFont systemFontOfSize:14];
    // 模拟网络请求
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        sleep(1.2);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SPProgressHUD hide];
        });
    });
}

// 显示纯文本
- (void)labelExample {
    SPProgressHUD *hud = [SPProgressHUD showWithMessage:@"登录成功\n经验值+2" toView:nil];
    hud.offset = CGPointMake(0, [UIScreen mainScreen].bounds.size.height * 3 / 8);
    hud.margin = 10;
    hud.minSize = CGSizeMake(150, 30);
    [SPProgressHUD hideAfterDelay:1.2];
}

// 显示成功
- (void)successsExample {
    [SPProgressHUD showSuccessWithMessage:@"添加成功"];
    [SPProgressHUD hideAfterDelay:1.2];
}

// 显示失败
- (void)failureExample {
    [SPProgressHUD showErrorWithMessage:@"添加失败"];
    [SPProgressHUD hideAfterDelay:1.2];
}

// 显示详情
- (void)infoExample {
    [SPProgressHUD showInfoWithMessage:@"详细信息"];
    [SPProgressHUD hideAfterDelay:1.2];
}

// 显示自定义图片+文本
- (void)imageLabelExample {
    // 方式一:
    UIImage *image = [UIImage imageNamed:@"fingerprint"];
    // 调用imageWithRenderingMode:,图片的颜色才会跟contentColor一致.
    SPProgressHUD *hud = [SPProgressHUD showWithImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] message:@"建议使用指纹支付"];
    hud.spacing = 10;
    [SPProgressHUD hideAfterDelay:2.0];
}

// 显示环状进度条(默认)
- (void)annularProgressBarExample {
    SPProgressHUD *hud = [SPProgressHUD showProgressWithMessage:@"" toView:nil];
    hud.progressViewStyle = SPProgressHUDProgressViewStyleAnnular;
    [self simulateProgressHaveText:YES];
}

// 显示饼状进度条
- (void)pieProgressBarExample {
    SPProgressHUD *hud = [SPProgressHUD showProgressWithMessage:@"" toView:nil];
    hud.progressViewStyle = SPProgressHUDProgressViewStylePie;
    [self simulateProgressHaveText:NO];
    
    
    // kvc方式去除饼状进度条的背景色
    /*
    UIView *indicator = [hud valueForKeyPath:@"indicator"];
    if ([indicator respondsToSelector:@selector(setBackgroundTintColor:)]) {
        [indicator setValue:[UIColor clearColor] forKeyPath:@"backgroundTintColor"];
    }
     */
    
    // kvc方式去除饼状进度条的背景色（这种方式如果找不到backgroundTintColor属性会崩溃）
    // [hud setValue:[UIColor clearColor] forKeyPath:@"indicator.backgroundTintColor"];
}

// 显示环状进度条(内切)
- (void)innerRingProgressBarExample {
    SPProgressHUD *hud = [SPProgressHUD showProgressWithMessage:@"" toView:nil];
    hud.progressViewStyle = SPProgressHUDProgressViewStyleInnerRing;
    [self simulateProgressHaveText:NO];
}

// 显示柱状进度条
- (void)barProgressBarExample {

    SPProgressHUD *hud = [SPProgressHUD showProgressWithMessage:@"正在上传..." toView:nil];
    hud.progressViewStyle = SPProgressHUDProgressViewStyleBar;
    hud.defaultMotionEffectsEnabled = NO; // 去除视觉差效果
    hud.messageLabel.font = [UIFont systemFontOfSize:14];
    [self simulateProgressHaveText:YES];
}

// 模拟进度
- (void)simulateProgressHaveText:(BOOL)haveText {
    SPProgressHUD *hud = [SPProgressHUD HUDForView:nil];
    // 模拟progress进度（耗时操作,放到异步线程中,否则HUD弹不出来,注意必须回到主线程渲染UI）
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        __block float progress = 0.0f;
        while (progress < 1.0f) {
            progress += 0.01f;
            dispatch_async(dispatch_get_main_queue(), ^{
                // 循环
                if (progress >= 1.0) {
                    progress = 1.0;
                    [hud hide];
                }
                hud.progress = progress;
                if (haveText) {
                    // 由子线程回到主线程渲染UI，HUD不会重新布局，这就会导致，如果创建出来的HUD比显示文本内容时小，HUD的大小会不准确，所以需要保证HUD在设置文本内容之前，有足够的大小显示全文本，如果不足够，可以通过设置HUD的minSize属性修改其大小.
                    hud.messageLabel.text = [NSString stringWithFormat:@"当前进度：%.0f%%",progress*100];
                }
            });
            usleep(30000);
        }
    });
}

// 显示自定义指示器
- (void)customizeActivityForTurnRoundExample {
    SPIndefiniteAnimatedView *animationView = [[SPIndefiniteAnimatedView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    animationView.strokeColor = [UIColor blackColor];
    animationView.strokeStart = 0.2;
    
    SPProgressHUD *hud = [SPProgressHUD showActivityWithMessage:@""];
    hud.customView = animationView;
    hud.color = [UIColor whiteColor];
    hud.maskColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    hud.cornerRadius = 14.0f;
    // 模拟网络请求
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        sleep(2.0);
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hide];
        });
    });
}

// 自定义一张图片
- (void)customizeImageExample {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"toast"]];
    
    SPProgressHUD *hud = [SPProgressHUD showActivityWithMessage:@""];
    hud.customView = imageView;
    hud.color = [UIColor whiteColor];
    hud.maskColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    hud.cornerRadius = 14.0f;
    // 模拟网络请求
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        sleep(2.0);
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hide];
        });
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.examples.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.examples[section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"指示器";
    } else if (section == 1) {
        return @"toast";
    } else if (section == 2) {
        return @"进度条";
    } else {
        return @"自定义";
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SPExampleCellID forIndexPath:indexPath];
    SPExample *example = self.examples[indexPath.section][indexPath.row];
    cell.textLabel.text = example.title;
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.font = [UIFont systemFontOfSize:16.0];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SPExample *example = self.examples[indexPath.section][indexPath.row];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self performSelector:example.selector];
#pragma clang diagnostic pop
}

@end
