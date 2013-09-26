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
    [[CXAlertView appearance] setButtonColor:[UIColor colorWithRed:0.039 green:0.380 blue:0.992 alpha:1.000]];
    [[CXAlertView appearance] setCancelButtonColor:[UIColor colorWithRed:0.047 green:0.337 blue:1.000 alpha:1.000]];
    [[CXAlertView appearance] setCustomButtonColor:[UIColor colorWithRed:0.039 green:0.380 blue:0.992 alpha:1.000]];
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
                             type:CXAlertViewButtonTypeCustom
                          handler:^(CXAlertView *alertView, CXAlertButtonItem *button) {
                              alertView.contentView = nil;
                              alertView.title = @"This \n is \n a \n multiline \n title demo without content.";
                          }];
    
    [alertView addButtonWithTitle:@"Another"
                             type:CXAlertViewButtonTypeDefault
                          handler:^(CXAlertView *alertView, CXAlertButtonItem *button) {
                              alertView.title = @"Red custom view";
                              UIView *view = [[UIView alloc] initWithFrame:CGRectMake( 0, 0, 200, 200)];
                              view.backgroundColor = [UIColor redColor];
                              alertView.contentView = view;
                          }];
    
//    alertView.willShowHandler = ^(CXAlertView *alertView) {
//        NSLog(@"%@, willShowHandler", alertView);
//    };
//    alertView.didShowHandler = ^(CXAlertView *alertView) {
//        NSLog(@"%@, didShowHandler", alertView);
//    };
//    alertView.willDismissHandler = ^(CXAlertView *alertView) {
//        NSLog(@"%@, willDismissHandler", alertView);
//    };
//    alertView.didDismissHandler = ^(CXAlertView *alertView) {
//        NSLog(@"%@, didDismissHandler", alertView);
//    };
    
    [alertView show];
}

- (IBAction)showSquenceAlertView:(id)sender
{    
    CXAlertView *alertViewMe = [[CXAlertView alloc] initWithTitle:@"Chris Xu" contentView:self.myInfoView];
    alertViewMe.shouldDrawButtonLine = NO;
    
    [alertViewMe addButtonWithTitle:@"OK"
                             type:CXAlertViewButtonTypeCancel
                          handler:^(CXAlertView *alertView, CXAlertButtonItem *button) {
                              
                              [alertView dismiss];
                          }];
    
    [alertViewMe show];
    
    CXAlertView *alertView2 = [[CXAlertView alloc] initWithTitle:@"MIT License" message:@"Copyright (c) 2013 Chris Xu, Licensed under the MIT license (http://www.opensource.org/licenses/mit-license.php) \n\nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the ‘Software’), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED ‘AS IS’, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."];
    
    [alertView2 addButtonWithTitle:@"Confirm"
                             type:CXAlertViewButtonTypeDefault
                          handler:^(CXAlertView *alertView, CXAlertButtonItem *button) {
                              button.enabled = NO;
                              [button setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
                              [alertView addButtonWithTitle:@"OK"
                                                        type:CXAlertViewButtonTypeDefault
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
