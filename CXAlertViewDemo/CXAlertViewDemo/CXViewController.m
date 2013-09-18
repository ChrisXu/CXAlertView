//
//  CXViewController.m
//  CXAlertViewDemo
//
//  Created by ChrisXu on 13/9/12.
//  Copyright (c) 2013年 ChrisXu. All rights reserved.
//

#import "CXViewController.h"
#import "CXAlertView.h"

@interface CXViewController ()

- (IBAction)showSquenceAlertView:(id)sender;

@end

@implementation CXViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [[CXAlertView appearance] setTitleFont:[UIFont boldSystemFontOfSize:18.]];
    [[CXAlertView appearance] setTitleColor:[UIColor blackColor]];
    [[CXAlertView appearance] setCornerRadius:12];
    [[CXAlertView appearance] setShadowRadius:20];
    [[CXAlertView appearance] setViewBackgroundColor:[UIColor colorWithRed:0.891 green:0.936 blue:0.978 alpha:1.000]];
    [[CXAlertView appearance] setButtonColor:[UIColor colorWithRed:0.247 green:0.333 blue:0.439 alpha:1.000]];
    [[CXAlertView appearance] setCancelButtonColor:[UIColor redColor]];
    [[CXAlertView appearance] setDestructiveButtonColor:[UIColor blueColor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    CXAlertView *alertView = [[CXAlertView alloc] initWithTitle:@"Steven Jobs" message:@"Steven Paul Jobs, the co-founder, two-time CEO, and chairman of Apple Inc., died October 5, 2011, after a long battle with cancer. He was 56. He was is survived by his wife and four children.The achievements in Jobs' career included helping to popularize the personal computer, leading the development of groundbreaking technology products including the Macintosh, iPod, and iPhone, and driving Pixar Animation Studios to prominence. Jobs’ charisma, drive for success and control, and vision contributed to revolutionary changes in the way technology integrates into and affects the daily life of most people in the world."];
    [alertView addButtonWithTitle:@"Button1"
                             type:CXAlertViewButtonTypeDefault
                          handler:^(CXAlertView *alertView, CXAlertButtonItem *button) {
                              NSLog(@"Button1 Clicked");
                              alertView.title = @"Steven Jobs";
                          }];
    [alertView addButtonWithTitle:@"Button2"
                             type:CXAlertViewButtonTypeCancel
                          handler:^(CXAlertView *alertView, CXAlertButtonItem *button) {
                              NSLog(@"Button2 Clicked");
                              alertView.title = @"Steven Jobs \n Steven Jobs \n Steven Jobs";
                              UIView *view = [[UIView alloc] initWithFrame:CGRectMake( 0, 0, 500, 800)];
                              view.backgroundColor = [UIColor blueColor];
                              alertView.contentView = view;
                          }];
    [alertView addButtonWithTitle:@"Button3"
                             type:CXAlertViewButtonTypeDestructive
                          handler:^(CXAlertView *alertView, CXAlertButtonItem *button) {
                              NSLog(@"Button3 Clicked");
                              alertView.title = nil;
                              UIView *view = [[UIView alloc] initWithFrame:CGRectMake( 0, 0, 200, 200)];
                              view.backgroundColor = [UIColor redColor];
                              alertView.contentView = view;
                          }];
    
    [alertView addButtonWithTitle:@"Dismiss"
                             type:CXAlertViewButtonTypeDestructive
                          handler:^(CXAlertView *alertView, CXAlertButtonItem *button) {
                              NSLog(@"Dismiss");
                              [alertView dismiss];
                          }];
    
    alertView.willShowHandler = ^(CXAlertView *alertView) {
        NSLog(@"%@, willShowHandler", alertView);
    };
    alertView.didShowHandler = ^(CXAlertView *alertView) {
        NSLog(@"%@, didShowHandler", alertView);
    };
    alertView.willDismissHandler = ^(CXAlertView *alertView) {
        NSLog(@"%@, willDismissHandler", alertView);
    };
    alertView.didDismissHandler = ^(CXAlertView *alertView) {
        NSLog(@"%@, didDismissHandler", alertView);
    };
    
    [alertView show];
}

- (IBAction)showSquenceAlertView:(id)sender
{    
    CXAlertView *alertView1 = [[CXAlertView alloc] initWithTitle:@"Steven Jobs" message:@"Steven Paul Jobs, the co-founder, two-time CEO, and chairman of Apple Inc., died October 5, 2011, after a long battle with cancer. He was 56. He was is survived by his wife and four children.The achievements in Jobs' career included helping to popularize the personal computer, leading the development of groundbreaking technology products including the Macintosh, iPod, and iPhone, and driving Pixar Animation Studios to prominence. Jobs’ charisma, drive for success and control, and vision contributed to revolutionary changes in the way technology integrates into and affects the daily life of most people in the world."];
    
    [alertView1 addButtonWithTitle:@"OK"
                             type:CXAlertViewButtonTypeCancel
                          handler:^(CXAlertView *alertView, CXAlertButtonItem *button) {
                              
                              [alertView dismiss];
                          }];
    
    [alertView1 show];
    
    CXAlertView *alertView2 = [[CXAlertView alloc] initWithTitle:@"pushviewcontroller style uiwindow" message:@"UINavigationController style in SingleViewApplication project ... bundle:nil]; [navigationController pushViewController:self.viewController ..."];
    
    [alertView2 addButtonWithTitle:@"Confirm"
                             type:CXAlertViewButtonTypeDestructive
                          handler:^(CXAlertView *alertView, CXAlertButtonItem *button) {
                              button.enabled = NO;
                              [button setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
                              [alertView addButtonWithTitle:@"OK"
                                                        type:CXAlertViewButtonTypeDestructive
                                                     handler:^(CXAlertView *alertView, CXAlertButtonItem *button) {
                                                         [alertView dismiss];
                                                     }];
                          }];
    
    [alertView2 show];
}
@end
