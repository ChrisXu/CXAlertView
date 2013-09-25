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

@property (nonatomic, strong) IBOutlet UIView *myInfoView;

- (IBAction)showSquenceAlertView:(id)sender;

- (IBAction)infoButtonAction:(UIButton *)button;

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
//    [[CXAlertView appearance] setViewBackgroundColor:[UIColor colorWithRed:0.922 green:0.925 blue:0.949 alpha:1.000]];
    [[CXAlertView appearance] setButtonColor:[UIColor colorWithRed:0.039 green:0.380 blue:0.992 alpha:1.000]];
    [[CXAlertView appearance] setCancelButtonColor:[UIColor colorWithRed:0.047 green:0.337 blue:1.000 alpha:1.000]];
    [[CXAlertView appearance] setDestructiveButtonColor:[UIColor colorWithRed:0.039 green:0.380 blue:0.992 alpha:1.000]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    CXAlertView *alertView = [[CXAlertView alloc] initWithTitle:@"Steven Jobs" message:@"\"Steven Paul Jobs, the co-founder, two-time CEO, and chairman of Apple Inc., died October 5, 2011, after a long battle with cancer. He was 56. He was is survived by his wife and four children.The achievements in Jobs' career included helping to popularize the personal computer, leading the development of groundbreaking technology products including the Macintosh, iPod, and iPhone, and driving Pixar Animation Studios to prominence. Jobs’ charisma, drive for success and control, and vision contributed to revolutionary changes in the way technology integrates into and affects the daily life of most people in the world.\" - Wikipedia"];
    [alertView addButtonWithTitle:@"Dismiss"
                             type:CXAlertViewButtonTypeCancel
                          handler:^(CXAlertView *alertView, CXAlertButtonItem *button) {
                              [alertView dismiss];
                          }];
    
    [alertView addButtonWithTitle:@"Taipei 101"
                             type:CXAlertViewButtonTypeDefault
                          handler:^(CXAlertView *alertView, CXAlertButtonItem *button) {
                              alertView.title = @"Taipei 101";
                              UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"taipei101.jpg"]];
                              alertView.contentView = imageView;
                          }];
    
    [alertView addButtonWithTitle:@"Multititle"
                             type:CXAlertViewButtonTypeDestructive
                          handler:^(CXAlertView *alertView, CXAlertButtonItem *button) {
                              alertView.title = @"Line1 \n Line2 \n Line3";
                          }];
    
    [alertView addButtonWithTitle:@"Another"
                             type:CXAlertViewButtonTypeDefault
                          handler:^(CXAlertView *alertView, CXAlertButtonItem *button) {
                              alertView.title = @"Red custom view";
                              UIView *view = [[UIView alloc] initWithFrame:CGRectMake( 0, 0, 200, 200)];
                              view.backgroundColor = [UIColor redColor];
                              alertView.contentView = view;
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
    CXAlertView *alertView1 = [[CXAlertView alloc] initWithTitle:@"Chris Xu" contentView:self.myInfoView];
    alertView1.drawButtonLine = NO;
    [alertView1 addButtonWithTitle:@"OK"
                             type:CXAlertViewButtonTypeCancel
                          handler:^(CXAlertView *alertView, CXAlertButtonItem *button) {
                              
                              [alertView dismiss];
                          }];
    
    [alertView1 show];
    
    CXAlertView *alertView2 = [[CXAlertView alloc] initWithTitle:@"Agreement" message:@"UINavigationController style in SingleViewApplication project bundle:nil]; [navigationController pushViewController:self.viewController"];
    
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

- (IBAction)infoButtonAction:(UIButton *)button
{
    NSString *urlString = nil;
    switch (button.tag) {
        case 0:
            urlString = @"https://github.com/ChrisXu1221";
            break;
        case 1:
            urlString = @"http://www.linkedin.com/profile/view?id=143284727";
            break;
        case 2:
            urlString = @"https://twitter.com/taterctl";
            break;
        default:
            break;
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}
@end
