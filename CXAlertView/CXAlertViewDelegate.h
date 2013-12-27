//
//  CXAlertViewDelegate.h
//  CXAlertViewDemo
//
//  Created by Rama Krishna Chunduri on 21-Dec-2013.
//  Copyright (c) 2013年 ChrisXu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CXAlertView;

@protocol CXAlertViewDelegate <NSObject>
@optional

// before animation and showing view
- (void)willPresentCXAlertView:(CXAlertView *)alertView;

// after animation
- (void)didPresentCXAlertView:(CXAlertView *)alertView;

// before animation and hiding view
- (void)cxAlertView:(CXAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex;

// after animation
- (void)cxAlertView:(CXAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;

@end