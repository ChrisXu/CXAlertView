//
//  CXBlurView.h
//  CXAlertViewDemo
//
//  Created by Chris Xu on 2014/2/7.
//  Copyright (c) 2014年 ChrisXu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CXBlurView : UIView

@property (nonatomic, strong) UIView *backgroundView;

- (void)blur;

@end
