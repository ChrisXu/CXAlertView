//
//  CXAlertButtonContainerView.h
//  CXAlertViewDemo
//
//  Created by ChrisXu on 13/9/25.
//  Copyright (c) 2013年 ChrisXu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CXAlertView.h"

@interface CXAlertButtonContainerView : UIScrollView

@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic) BOOL defaultTopLineVisible;

- (void)addButtonWithTitle:(NSString *)title type:(CXAlertViewButtonType)type handler:(CXAlertButtonHandler)handler;

@end
