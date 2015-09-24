//
//  CXAlertViewController.m
//  CXAlertViewDemo
//
//  Created by ChrisXu on 13/9/12.
//  Copyright (c) 2013年 ChrisXu. All rights reserved.
//

#import "CXAlertViewController.h"

@interface CXAlertView ()

- (void)setup;
- (void)resetTransition;
- (void)invalidateLayout;

@end

@interface CXAlertViewController ()

@end

@implementation CXAlertViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View life cycle

- (void)loadView
{
    self.view = self.alertView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.alertView setup];
    
    [UIApplication sharedApplication].statusBarHidden = _rootViewControllerPrefersStatusBarHidden;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [UIApplication sharedApplication].statusBarHidden = _rootViewControllerPrefersStatusBarHidden;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [UIApplication sharedApplication].statusBarHidden = _rootViewControllerPrefersStatusBarHidden;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.alertView resetTransition];
    [self.alertView invalidateLayout];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}
- (BOOL)prefersStatusBarHidden
{
    return _rootViewControllerPrefersStatusBarHidden;
}
@end
