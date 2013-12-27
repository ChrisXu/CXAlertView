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
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.alertView resetTransition];
    [self.alertView invalidateLayout];
}

- (NSUInteger)supportedInterfaceOrientations
{
	if(self.alertView.supportedOrientation!=NSNotFound)
	{
		return self.alertView.supportedOrientation;
	}
	
	return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	if(self.alertView.supportedOrientation!=NSNotFound)
	{
		BOOL retVal=(toInterfaceOrientation==self.alertView.supportedOrientation);
		NSLog(@"returning %@",(retVal)?@"YES":@"NO");
		return retVal;
	}
    return YES;
}

- (BOOL)shouldAutorotate
{
	if(self.alertView.supportedOrientation!=NSNotFound)
	{
		UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
		// Return yes to allow the device to load initially.
		if (orientation == UIDeviceOrientationUnknown)
		{
			return YES;
		}
		
		// Pass iOS 6 Request for orientation on to iOS 5 code. (backwards compatible)
		BOOL result = [self shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation];
		return result;
	}
	
	return YES;
}

@end