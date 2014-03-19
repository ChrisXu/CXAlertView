//
//  CXBlurView.m
//  CXAlertViewDemo
//
//  Created by Chris Xu on 2014/2/7.
//  Copyright (c) 2014年 ChrisXu. All rights reserved.
//

#import "CXBlurView.h"

@interface CXBlurView ()

@property (nonatomic, strong) UIToolbar *toolbar;

- (void)setup;

@end

@implementation CXBlurView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    _toolbar.frame = self.bounds;
}

- (void)setAlpha:(CGFloat)alpha
{
    alpha = MIN(0.9, alpha);
    
    [super setAlpha:alpha];
}

#pragma - PV
- (void)setup
{
    if (!_toolbar) {
        _toolbar = [[UIToolbar alloc] initWithFrame:self.bounds];
        //            _toolbar.barStyle = UIBarStyleBlack;
        [self.layer insertSublayer:_toolbar.layer atIndex:0];
    }
}

@end
