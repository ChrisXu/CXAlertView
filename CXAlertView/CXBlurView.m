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

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    _toolbar.frame = self.bounds;
    _backgroundView.frame = self.bounds;
}

#pragma mark - PB
- (void)blur
{
    [UIView animateWithDuration:0.3 animations:^{
        _backgroundView.alpha = 0.7;
    }];
}

#pragma - PV
- (void)setup
{
    if (!_toolbar) {
        _toolbar = [[UIToolbar alloc] initWithFrame:self.bounds];
        _toolbar.translucent = YES;
        _toolbar.barStyle = UIBarStyleBlack;
        [self.layer insertSublayer:_toolbar.layer atIndex:0];

        _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        _backgroundView.alpha = 1.;
        _backgroundView.backgroundColor = [UIColor whiteColor];
        [self.layer insertSublayer:_backgroundView.layer above:_toolbar.layer];
    }
}

@end
