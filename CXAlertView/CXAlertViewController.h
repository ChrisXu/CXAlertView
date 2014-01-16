//
//  CXAlertViewController.h
//  CXAlertViewDemo
//
//  Created by ChrisXu on 13/9/12.
//  Copyright (c) 2013年 ChrisXu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CXAlertView.h"

@interface CXAlertViewController : UIViewController

@property (nonatomic, strong) CXAlertView *alertView;

@property (nonatomic, assign) BOOL rootViewControllerPrefersStatusBarHidden;

@end
