//
//  SPBarProgressView.h
//  SPProgressView
//
//  Created by 乐升平 on 2018/8/15.
//  Copyright © 2018 乐升平. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPBarProgressView : UIView

/**
 * 进度(0~1)
 */
@property (nonatomic, assign) float progress;

/**
 * 边框宽度. 最大为 progressViewSize/2-1
 */
@property (nonatomic, assign) float lineWidth;

/**
 * 边框颜色,默认whiteColor
 */
@property (nonatomic, strong) UIColor *lineColor;

/**
 * 进度剩余颜色，默认clearColor
 */
@property (nonatomic, strong) UIColor *progressRemainingColor;

/**
 *  进度颜色，默认whiteColor
 */
@property (nonatomic, strong) UIColor *progressColor;

/**
 * intrinsicContentSize.
 */
@property (nonatomic, assign) CGSize intrinsicContentSize;


@end
