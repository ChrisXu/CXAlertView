//
//  CXAlertItem.h
//  CXAlertViewDemo
//
//  Created by ChrisXu on 13/9/12.
//  Copyright (c) 2013年 ChrisXu. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "CXAlertView.h"
typedef NS_ENUM(NSInteger, CXAlertViewButtonType) {
    CXAlertViewButtonTypeDefault = 0,
    CXAlertViewButtonTypeCustom = 1,
    CXAlertViewButtonTypeCancel = 2
};

@class CXAlertView;
@class CXAlertButtonItem;
typedef void(^CXAlertButtonHandler)(CXAlertView *alertView, CXAlertButtonItem *button);

@interface CXAlertButtonItem : UIButton


@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) CXAlertViewButtonType type;
@property (nonatomic, copy) CXAlertButtonHandler action;
@property (nonatomic) BOOL defaultRightLineVisible;

@end
