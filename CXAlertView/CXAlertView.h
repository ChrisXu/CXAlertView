//
//  CXAlertView.h
//  CXAlertViewDemo
//
//  Created by ChrisXu on 13/9/12.
//  Copyright (c) 2013年 ChrisXu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CXAlertButtonItem.h"
#import "CXAlertViewDelegate.h"

typedef void(^CXAlertViewHandler)(CXAlertView *alertView);

@interface CXAlertView : UIView

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) UIView *contentView;
@property (nonatomic, strong, readonly) NSMutableArray *buttons;
@property (nonatomic, assign) NSInteger cancelButtonIndex;
@property (nonatomic, assign) NSInteger supportedOrientation;

@property (nonatomic, copy) CXAlertViewHandler willShowHandler;
@property (nonatomic, copy) CXAlertViewHandler didShowHandler;
@property (nonatomic, copy) CXAlertViewHandler willDismissHandler;
@property (nonatomic, copy) CXAlertViewHandler didDismissHandler;

@property (nonatomic, readonly, getter = isVisible) BOOL visible;

@property (nonatomic, strong) UIColor *viewBackgroundColor NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *titleColor NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont *titleFont NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont *buttonFont NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *buttonColor NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *cancelButtonColor NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont *cancelButtonFont NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR; // default [UIFont boldSystemFontOfSize:18.]
@property (nonatomic, strong) UIColor *customButtonColor NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont *customButtonFont NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR; // default [UIFont systemFontOfSize:18.]
@property (nonatomic, assign) CGFloat cornerRadius NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR; // default is 8.0
@property (nonatomic, assign) CGFloat shadowRadius NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR; // default is 8.0

@property (nonatomic, assign) CGFloat scrollViewPadding;
@property (nonatomic, assign) CGFloat buttonHeight;
@property (nonatomic, assign) CGFloat containerWidth;
@property (nonatomic, assign) CGFloat vericalPadding;
@property (nonatomic, assign) CGFloat topScrollViewMaxHeight;
@property (nonatomic, assign) CGFloat topScrollViewMinHeight;
@property (nonatomic, assign) CGFloat contentScrollViewMaxHeight;
@property (nonatomic, assign) CGFloat contentScrollViewMinHeight;
@property (nonatomic, assign) CGFloat bottomScrollViewHeight;
@property (nonatomic, assign) BOOL showButtonLine;
@property (nonatomic, assign) BOOL showBlurBackground;

// Create
- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle;
- (id)initWithTitle:(NSString *)title contentView:(UIView *)contentView cancelButtonTitle:(NSString *)cancelButtonTitle;
- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id<CXAlertViewDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

// Buttons
- (NSInteger)addButtonWithTitle:(NSString *)title type:(CXAlertViewButtonType)type handler:(CXAlertButtonHandler)handler;
- (NSInteger)addDelegatedButtonWithTitle:(NSString *)title type:(CXAlertViewButtonType)type;
- (void)setDefaultButtonImage:(UIImage *)defaultButtonImage forState:(UIControlState)state NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
- (void)setCancelButtonImage:(UIImage *)cancelButtonImage forState:(UIControlState)state NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
- (void)setCustomButtonImage:(UIImage *)customButtonImage forState:(UIControlState)state NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;

// AlertView action
- (void)show;
- (void)dismiss;
- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex;
- (void)shake;

// Operation
- (void)cleanAllPenddingAlert;
@end