//
//  CXAlertItem.m
//  CXAlertViewDemo
//
//  Created by ChrisXu on 13/9/12.
//  Copyright (c) 2013年 ChrisXu. All rights reserved.
//

#import "CXAlertButtonItem.h"

@implementation CXAlertButtonItem

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
    }
    else {
        self.backgroundColor = [UIColor clearColor];
    }
}

- (void)drawRect:(CGRect)rect
{
    if (_defaultRightLineVisible) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextClearRect(context, self.bounds);
        
        CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.671 green:0.675 blue:0.694 alpha:1.000].CGColor);
        CGContextSetLineWidth(context, 1.0);
        CGContextMoveToPoint(context, CGRectGetWidth(self.frame),0);
        CGContextAddLineToPoint(context, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        CGContextStrokePath(context);
    }
}

@end
