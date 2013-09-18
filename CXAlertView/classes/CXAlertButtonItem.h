//
//  CXAlertItem.h
//  CXAlertViewDemo
//
//  Created by ChrisXu on 13/9/12.
//  Copyright (c) 2013年 ChrisXu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CXAlertView.h"

@interface CXAlertButtonItem : UIButton

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) CXAlertViewButtonType type;
@property (nonatomic, copy) CXAlertViewHandler action;

@end
