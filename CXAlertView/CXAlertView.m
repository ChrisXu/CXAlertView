//
//  CXAlertView.m
//  CXAlertViewDemo
//
//  Created by ChrisXu on 13/9/12.
//  Copyright (c) 2013年 ChrisXu. All rights reserved.
//

#import "CXAlertView.h"
#import "CXAlertBackgroundWindow.h"
#import "CXAlertButtonItem.h"
#import "CXAlertViewController.h"
#import <QuartzCore/QuartzCore.h>

#define SCROLL_VIEW_PADDING 10
#define BUTTON_TOP_PADDING 5
#define BUTTON_LEFT_PADDING 5
#define BUTTON_HEIGHT 44

#define CONTAINER_DEFAULT_WIDTH 280
#define VERICAL_PADDING 10

#define TOP_MAX_HEIGHT 50
#define TOP_MIN_HEIGHT 10

#define CONTENT_MIN_HEIGHT 0
#define CONTENT_MAX_HEIGHT 180

#define BOTTOM_HEIGHT 44
//#define BOTTOM_MIN_HEIGHT 44

@class CXAlertButtonItem;
@class CXAlertViewController;

static NSMutableArray *__cx_pending_alert_queue;
static BOOL __cx_alert_animating;
static CXAlertBackgroundWindow *__cx_alert_background_window;
static CXAlertView *__cx_alert_current_view;

@interface CXAlertView ()
{
    BOOL updateAnimated;
}

@property (nonatomic, strong) UIWindow *oldKeyWindow;
@property (nonatomic, strong) UIWindow *alertWindow;
@property (nonatomic, assign, getter = isVisible) BOOL visible;

@property (nonatomic, strong) UIScrollView *topScrollView;
@property (nonatomic, strong) UIScrollView *contentScrollView;
@property (nonatomic, strong) UIScrollView *bottomScrollView;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) NSMutableArray *buttons;

@property (nonatomic, assign, getter = isLayoutDirty) BOOL layoutDirty;

+ (NSMutableArray *)sharedQueue;
+ (CXAlertView *)currentAlertView;

+ (BOOL)isAnimating;
+ (void)setAnimating:(BOOL)animating;

+ (void)showBackground;
+ (void)hideBackgroundAnimated:(BOOL)animated;
// Height
- (CGFloat)heightOfLabelWithText:(NSString *)text font:(UIFont *)font;
- (CGFloat)preferredHeight;
- (CGFloat)heightForTopScrollView;
- (CGFloat)heightForContentScrollView;
- (CGFloat)heightForBottomScrollView;
//
- (void)setup;
- (void)tearDown;
- (void)validateLayout;
- (void)invalidateLayout;
- (void)resetTransition;
// Views
- (void)setupContainerView;
- (void)setupScrollViews;
- (void)updateTopScrollView;
- (void)updateContentScrollView;
- (void)updateBottomScrollView;
- (void)dismissWithCleanup:(BOOL)cleanup;
//transition
- (void)transitionInCompletion:(void(^)(void))completion;
- (void)transitionOutCompletion:(void(^)(void))completion;

// Buttons
- (CXAlertButtonItem *)buttonItemWithType:(CXAlertViewButtonType)type;
- (void)buttonAction:(CXAlertButtonItem *)buttonItem;
@end

@implementation CXAlertView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self validateLayout];
}
#pragma mark - CXAlertView PB
// Create
- (id)initWithTitle:(NSString *)title message:(NSString *)message
{
    UILabel *messageLabel = [[UILabel alloc] init];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.backgroundColor = [UIColor clearColor];
    messageLabel.font = [UIFont systemFontOfSize:18.0];
    messageLabel.textColor = [UIColor blackColor];
    messageLabel.numberOfLines = 0;
    messageLabel.text = message;
    messageLabel.frame = CGRectMake( VERICAL_PADDING, 0, CONTAINER_DEFAULT_WIDTH - VERICAL_PADDING*2, [self heightOfLabelWithText:message font:messageLabel.font]);
    
    return  [self initWithTitle:title contentView:messageLabel];
}

- (id)initWithTitle:(NSString *)title contentView:(UIView *)contentView
{
    self = [super init];
    if (self) {
        _buttons = [[NSMutableArray alloc] init];
        _title = title;
        _contentView = contentView;
    }
    return self;
}
// Buttons
- (void)addButtonWithTitle:(NSString *)title type:(CXAlertViewButtonType)type handler:(CXAlertViewHandler)handler
{
    [self setupScrollViews];
    CXAlertButtonItem *button = [self buttonItemWithType:type];
    button.action = handler;
    button.type = type;
    [button setTitle:title forState:UIControlStateNormal];
    
    if ([_buttons count] == 0) {
        button.frame = CGRectMake( CONTAINER_DEFAULT_WIDTH/4, 0, CONTAINER_DEFAULT_WIDTH/2, BUTTON_HEIGHT);
    }
    else {
        // correct first button
        CXAlertButtonItem *firstButton = [_buttons objectAtIndex:0];
        CGRect newFrame = firstButton.frame;
        newFrame.origin.x = 0;
        firstButton.frame = newFrame;
        
        CGFloat last_y = 0;
        if ([_buttons lastObject]) {
            CXAlertButtonItem *lastButton = (CXAlertButtonItem *)[_buttons lastObject];
            last_y = CGRectGetMaxX(lastButton.frame);
        }
        
        button.frame = CGRectMake( last_y, 0, CONTAINER_DEFAULT_WIDTH/2, BUTTON_HEIGHT);
    }
    
    [_buttons addObject:button];
    [self.bottomScrollView addSubview:button];
    CGFloat newContentWidth = self.bottomScrollView.contentSize.width + CGRectGetWidth(button.frame);
    self.bottomScrollView.contentSize = CGSizeMake( newContentWidth, BUTTON_HEIGHT);
}

- (void)setDefaultButtonImage:(UIImage *)defaultButtonImage forState:(UIControlState)state
{
    
}

- (void)setCancelButtonImage:(UIImage *)cancelButtonImage forState:(UIControlState)state
{
    
}

- (void)setDestructiveButtonImage:(UIImage *)destructiveButtonImage forState:(UIControlState)state
{
    
}
// AlertView action
- (void)show
{
    self.oldKeyWindow = [[UIApplication sharedApplication] keyWindow];
    
    if (![[CXAlertView sharedQueue] containsObject:self]) {
        [[CXAlertView sharedQueue] addObject:self];
    }
    
    if ([CXAlertView isAnimating]) {
        return; // wait for next turn
    }
    
    if (self.isVisible) {
        return;
    }
    
    if ([CXAlertView currentAlertView].isVisible) {
        CXAlertView *alert = [CXAlertView currentAlertView];
        [alert dismissWithCleanup:NO];
        return;
    }
    
    if (self.willShowHandler) {
        self.willShowHandler(self);
    }
    
    self.visible = YES;
    
    [CXAlertView setAnimating:YES];
    [CXAlertView setCurrentAlertView:self];
    
    // transition background
    [CXAlertView showBackground];
    
    CXAlertViewController *viewController = [[CXAlertViewController alloc] initWithNibName:nil bundle:nil];
    viewController.alertView = self;
    
    if (!self.alertWindow) {
        UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        window.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        window.opaque = NO;
        window.windowLevel = UIWindowLevelAlert;
        window.rootViewController = viewController;
        self.alertWindow = window;
    }
    [self.alertWindow makeKeyAndVisible];
    
    [self validateLayout];
    
    [self transitionInCompletion:^{
        if (self.didShowHandler) {
            self.didShowHandler(self);
        }
        
        [CXAlertView setAnimating:NO];
        
        NSInteger index = [[CXAlertView sharedQueue] indexOfObject:self];
        if (index < [CXAlertView sharedQueue].count - 1) {
            [self dismissWithCleanup:NO]; // dismiss to show next alert view
        }
    }];
}

- (void)dismiss
{
    [self dismissWithCleanup:YES];
}
// Operation
- (void)cleanAllPenddingAlert
{
    [[CXAlertView sharedQueue] removeAllObjects];
}

#pragma mark - CXAlertView PV
+ (NSMutableArray *)sharedQueue
{
    if (!__cx_pending_alert_queue) {
        __cx_pending_alert_queue = [NSMutableArray array];
    }
    return __cx_pending_alert_queue;
}

+ (CXAlertView *)currentAlertView
{
    return __cx_alert_current_view;
}

+ (void)setCurrentAlertView:(CXAlertView *)alertView
{
    __cx_alert_current_view = alertView;
}

+ (BOOL)isAnimating
{
    return __cx_alert_animating;
}

+ (void)setAnimating:(BOOL)animating
{
    __cx_alert_animating = animating;
}

+ (void)showBackground
{
    if (!__cx_alert_background_window) {
        __cx_alert_background_window = [[CXAlertBackgroundWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        
        [__cx_alert_background_window makeKeyAndVisible];
        __cx_alert_background_window.alpha = 0;
        [UIView animateWithDuration:0.3
                         animations:^{
                             __cx_alert_background_window.alpha = 1;
                         }];
    }
}

+ (void)hideBackgroundAnimated:(BOOL)animated
{
    if (!animated) {
        [__cx_alert_background_window removeFromSuperview];
        __cx_alert_background_window = nil;
        return;
    }
    [UIView animateWithDuration:0.3
                     animations:^{
                         __cx_alert_background_window.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [__cx_alert_background_window removeFromSuperview];
                         __cx_alert_background_window = nil;
                     }];
}

- (CGFloat)heightOfLabelWithText:(NSString *)text font:(UIFont *)font
{
    if (text) {
        CGSize size = [text sizeWithFont:font constrainedToSize:CGSizeMake(CONTAINER_DEFAULT_WIDTH - 2*VERICAL_PADDING - 1, NSUIntegerMax)];
        
        return size.height;
    }
    
    return 0;
}

- (CGFloat)preferredHeight
{
    CGFloat height = 0;
    height += ([self heightForTopScrollView] + SCROLL_VIEW_PADDING);
    height += ([self heightForContentScrollView] + SCROLL_VIEW_PADDING);
    height += ([self heightForBottomScrollView] + SCROLL_VIEW_PADDING);
    return height;
}

- (CGFloat)heightForTopScrollView
{
    return MAX(TOP_MIN_HEIGHT, MIN(TOP_MAX_HEIGHT, CGRectGetHeight(_titleLabel.frame)));
}

- (CGFloat)heightForContentScrollView
{
    return MAX(CONTENT_MIN_HEIGHT, MIN(CONTENT_MAX_HEIGHT, CGRectGetHeight(_contentView.frame)));
}

- (CGFloat)heightForBottomScrollView
{
    return BOTTOM_HEIGHT;
}

- (void)setup
{
    [self setupContainerView];
    [self setupScrollViews];
    [self updateTopScrollView];
    [self updateContentScrollView];
    [self updateBottomScrollView];
    [self invalidateLayout];
}

- (void)tearDown
{
    [self.containerView removeFromSuperview];
    
//    [self.topScrollView removeFromSuperview];
//    self.topScrollView = nil;
    
//    [self.contentScrollView removeFromSuperview];
//    self.contentScrollView = nil;
    
//    [self.bottomScrollView removeFromSuperview];
//    self.bottomScrollView = nil;
    
    [self.titleLabel removeFromSuperview];
    self.titleLabel = nil;
//    self.messageContentView = nil;
    
    [self.alertWindow removeFromSuperview];
    self.alertWindow = nil;
    self.layoutDirty = NO;
}

- (void)validateLayout
{
    if (!self.isLayoutDirty) {
        return;
    }
    self.layoutDirty = NO;

    CGFloat height = [self preferredHeight];
    CGFloat left = (self.bounds.size.width - CONTAINER_DEFAULT_WIDTH) * 0.5;
    CGFloat top = (self.bounds.size.height - height) * 0.5;
    self.containerView.transform = CGAffineTransformIdentity;
    if (updateAnimated) {
        updateAnimated = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self.containerView.frame = CGRectMake(left, top, CONTAINER_DEFAULT_WIDTH, height);
        }];
    }
    else {
        self.containerView.frame = CGRectMake(left, top, CONTAINER_DEFAULT_WIDTH, height);
    }
    self.containerView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.containerView.bounds cornerRadius:self.containerView.layer.cornerRadius].CGPath;
}

- (void)invalidateLayout
{
    self.layoutDirty = YES;
    [self setNeedsLayout];
}

- (void)resetTransition
{
    [self.containerView.layer removeAllAnimations];
}
// Scroll Views
- (void)setupContainerView
{
    self.containerView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:self.containerView];
    
    self.containerView.backgroundColor = _viewBackgroundColor ? _viewBackgroundColor : [UIColor whiteColor];
    self.containerView.layer.cornerRadius = self.cornerRadius;
    self.containerView.layer.shadowOffset = CGSizeZero;
    self.containerView.layer.shadowRadius = self.shadowRadius;
    self.containerView.layer.shadowOpacity = 0.5;
}

- (void)setupScrollViews
{
    if (!self.topScrollView) {
        self.topScrollView = [[UIScrollView alloc] init];
    }
    
    if (!self.contentScrollView) {
        self.contentScrollView = [[UIScrollView alloc] init];
    }
    
    if (!self.bottomScrollView) {
        self.bottomScrollView = [[UIScrollView alloc] init];
    }
}

- (void)updateTopScrollView
{
    if (self.title) {
        if (!_titleLabel) {
            _titleLabel = [[UILabel alloc] init];
            [self.topScrollView addSubview:_titleLabel];
        }
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = self.titleFont;
        _titleLabel.textColor = self.titleColor;
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        _titleLabel.numberOfLines = 0;
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_6_0
        _titleLabel.minimumScaleFactor = 0.75;
#else
        _titleLabel.minimumFontSize = self.titleLabel.font.pointSize * 0.75;
#endif
        _titleLabel.frame = CGRectMake( VERICAL_PADDING, 0, CONTAINER_DEFAULT_WIDTH - VERICAL_PADDING*2, [self heightOfLabelWithText:self.title font:_titleLabel.font]);
        _titleLabel.text = self.title;
        
        self.topScrollView.frame = CGRectMake( 0 , SCROLL_VIEW_PADDING, CONTAINER_DEFAULT_WIDTH, [self heightForTopScrollView]);
        self.topScrollView.contentSize = _titleLabel.bounds.size;
        
        if (![self.containerView.subviews containsObject:self.topScrollView]) {
            [self.containerView addSubview:self.topScrollView];
        }
        
        [self.topScrollView setScrollEnabled:([self heightForTopScrollView] < CGRectGetHeight(_titleLabel.frame))];

    }
    else {
        [_titleLabel removeFromSuperview];
        _titleLabel = nil;
        [self.topScrollView setFrame:CGRectZero];
        [self.topScrollView removeFromSuperview];
    }
}

- (void)updateContentScrollView
{
    for (UIView *view in self.contentScrollView.subviews) {
        [view removeFromSuperview];
    }
    
    if (_contentView) {
        
        if (CGRectGetWidth(_contentView.frame) < CONTAINER_DEFAULT_WIDTH) {
            CGRect frame = _contentView.frame;
            frame.origin.x = (CONTAINER_DEFAULT_WIDTH - CGRectGetWidth(_contentView.frame))/2;
            _contentView.frame = frame;
        }
        
        [self.contentScrollView addSubview:_contentView];
        
        CGFloat y = 0;
        y += [self heightForTopScrollView] + SCROLL_VIEW_PADDING;
        
        y += SCROLL_VIEW_PADDING;
        
        self.contentScrollView.frame = CGRectMake( 0, y, CONTAINER_DEFAULT_WIDTH, [self heightForContentScrollView]);
        self.contentScrollView.contentSize = _contentView.bounds.size;
        
        if (![self.containerView.subviews containsObject:self.contentScrollView]) {
            [self.containerView addSubview:self.contentScrollView];
        }
        
        [self.contentScrollView setScrollEnabled:([self heightForContentScrollView] < CGRectGetHeight(_contentView.frame))];
    }
    else {
        [self.contentScrollView setFrame:CGRectZero];
        [self.contentScrollView removeFromSuperview];
    }
    
    [self invalidateLayout];
}

- (void)updateBottomScrollView
{
    CGFloat y = 0;
    
    y += [self heightForTopScrollView] + SCROLL_VIEW_PADDING;
    
    y += [self heightForContentScrollView] + SCROLL_VIEW_PADDING;
    
    y += SCROLL_VIEW_PADDING;
    
    self.bottomScrollView.backgroundColor = [UIColor clearColor];
    self.bottomScrollView.frame = CGRectMake( 0, y, CONTAINER_DEFAULT_WIDTH, [self heightForBottomScrollView]);
    
    if (![self.containerView.subviews containsObject:self.bottomScrollView]) {
        [self.containerView addSubview:self.bottomScrollView];
    }
    
    [self invalidateLayout];
}

- (void)dismissWithCleanup:(BOOL)cleanup
{
    BOOL isVisible = self.isVisible;
    
    if (isVisible) {
        if (self.willDismissHandler) {
            self.willDismissHandler(self);
        }
    }
    
    void (^dismissComplete)(void) = ^{
        self.visible = NO;
        [self tearDown];
        
        [CXAlertView setCurrentAlertView:nil];
        
        CXAlertView *nextAlertView;
        NSInteger index = [[CXAlertView sharedQueue] indexOfObject:self];
        if (index != NSNotFound && index < [CXAlertView sharedQueue].count - 1) {
            nextAlertView = [CXAlertView sharedQueue][index + 1];
        }
        
        if (cleanup) {
            [[CXAlertView sharedQueue] removeObject:self];
        }
        
        [CXAlertView setAnimating:NO];
        
        if (isVisible) {
            if (self.didDismissHandler) {
                self.didDismissHandler(self);
            }
        }
        
        // check if we should show next alert
        if (!isVisible) {
            return;
        }
        
        if (nextAlertView) {
            [nextAlertView show];
        } else {
            // show last alert view
            if ([CXAlertView sharedQueue].count > 0) {
                CXAlertView *alert = [[CXAlertView sharedQueue] lastObject];
                [alert show];
            }
        }
    };
    
    if (isVisible) {
        [CXAlertView setAnimating:YES];
        [self transitionOutCompletion:dismissComplete];
        
        if ([CXAlertView sharedQueue].count == 1) {
            [CXAlertView hideBackgroundAnimated:YES];
        }
        
    } else {
        dismissComplete();
        
        if ([CXAlertView sharedQueue].count == 0) {
            [CXAlertView hideBackgroundAnimated:YES];
        }
    }
    
    [self.oldKeyWindow makeKeyWindow];
    self.oldKeyWindow.hidden = NO;
}
// Transition
- (void)transitionInCompletion:(void(^)(void))completion
{
    self.containerView.alpha = 0;
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.containerView.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         if (completion) {
                             completion();
                         }
                     }];
}

- (void)transitionOutCompletion:(void(^)(void))completion
{
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.containerView.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         if (completion) {
                             completion();
                         }
                     }];
}

// Buttons
- (CXAlertButtonItem *)buttonItemWithType:(CXAlertViewButtonType)type
{
	CXAlertButtonItem *button = [CXAlertButtonItem buttonWithType:UIButtonTypeCustom];
//	button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    button.titleLabel.font = self.buttonFont;
	UIImage *normalImage = nil;
	UIImage *highlightedImage = nil;
	switch (type) {
		case CXAlertViewButtonTypeCancel:
			normalImage = [UIImage imageNamed:@"SIAlertView.bundle/button-cancel"];
			highlightedImage = [UIImage imageNamed:@"SIAlertView.bundle/button-cancel-d"];
			[button setTitleColor:self.cancelButtonColor forState:UIControlStateNormal];
            [button setTitleColor:[self.cancelButtonColor colorWithAlphaComponent:0.8] forState:UIControlStateHighlighted];
			break;
		case CXAlertViewButtonTypeDestructive:
			normalImage = [UIImage imageNamed:@"SIAlertView.bundle/button-destructive"];
			highlightedImage = [UIImage imageNamed:@"SIAlertView.bundle/button-destructive-d"];
            [button setTitleColor:self.destructiveButtonColor forState:UIControlStateNormal];
            [button setTitleColor:[self.destructiveButtonColor colorWithAlphaComponent:0.8] forState:UIControlStateHighlighted];
			break;
		case CXAlertViewButtonTypeDefault:
		default:
			normalImage = [UIImage imageNamed:@"SIAlertView.bundle/button-default"];
			highlightedImage = [UIImage imageNamed:@"SIAlertView.bundle/button-default-d"];
			[button setTitleColor:self.buttonColor forState:UIControlStateNormal];
            [button setTitleColor:[self.buttonColor colorWithAlphaComponent:0.8] forState:UIControlStateHighlighted];
			break;
	}
	CGFloat hInset = floorf(normalImage.size.width / 2);
	CGFloat vInset = floorf(normalImage.size.height / 2);
	UIEdgeInsets insets = UIEdgeInsetsMake(vInset, hInset, vInset, hInset);
	normalImage = [normalImage resizableImageWithCapInsets:insets];
	highlightedImage = [highlightedImage resizableImageWithCapInsets:insets];
	[button setBackgroundImage:normalImage forState:UIControlStateNormal];
	[button setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
	[button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (void)buttonAction:(CXAlertButtonItem *)buttonItem
{
    if (buttonItem.action) {
        buttonItem.action(self);
    }
}

#pragma mark - Setter
- (void)setTitle:(NSString *)title
{
    if (_title != title) {
        _title = title;
        
        updateAnimated = YES;
        [self updateTopScrollView];
        [self updateContentScrollView];
        [self updateBottomScrollView];
        [self invalidateLayout];
    }
}

- (void)setContentView:(UIView *)contentView
{
    if (_contentView != contentView) {
        _contentView = contentView;
        
        updateAnimated = YES;
        [self updateContentScrollView];
        [self updateBottomScrollView];
        [self invalidateLayout];
    }
}

#pragma mark - UIAppearance setters

- (void)setViewBackgroundColor:(UIColor *)viewBackgroundColor
{
    if (_viewBackgroundColor == viewBackgroundColor) {
        return;
    }
    _viewBackgroundColor = viewBackgroundColor;
    self.containerView.backgroundColor = viewBackgroundColor;
}

- (void)setTitleFont:(UIFont *)titleFont
{
    if (_titleFont == titleFont) {
        return;
    }
    _titleFont = titleFont;
    self.titleLabel.font = titleFont;
    [self invalidateLayout];
}

- (void)setTitleColor:(UIColor *)titleColor
{
    if (_titleColor == titleColor) {
        return;
    }
    _titleColor = titleColor;
    self.titleLabel.textColor = titleColor;
}

- (void)setButtonFont:(UIFont *)buttonFont
{
    if (_buttonFont == buttonFont) {
        return;
    }
    _buttonFont = buttonFont;
    for (UIButton *button in self.buttons) {
        button.titleLabel.font = buttonFont;
    }
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    if (_cornerRadius == cornerRadius) {
        return;
    }
    _cornerRadius = cornerRadius;
    self.containerView.layer.cornerRadius = cornerRadius;
}

- (void)setShadowRadius:(CGFloat)shadowRadius
{
    if (_shadowRadius == shadowRadius) {
        return;
    }
    _shadowRadius = shadowRadius;
    self.containerView.layer.shadowRadius = shadowRadius;
}

- (void)setButtonColor:(UIColor *)buttonColor
{
    if (_buttonColor == buttonColor) {
        return;
    }
    _buttonColor = buttonColor;
    [self setColor:buttonColor toButtonsOfType:CXAlertViewButtonTypeDefault];
}

- (void)setCancelButtonColor:(UIColor *)buttonColor
{
    if (_cancelButtonColor == buttonColor) {
        return;
    }
    _cancelButtonColor = buttonColor;
    [self setColor:buttonColor toButtonsOfType:CXAlertViewButtonTypeCancel];
}

- (void)setDestructiveButtonColor:(UIColor *)buttonColor
{
    if (_destructiveButtonColor == buttonColor) {
        return;
    }
    _destructiveButtonColor = buttonColor;
    [self setColor:buttonColor toButtonsOfType:CXAlertViewButtonTypeDestructive];
}

-(void)setColor:(UIColor *)color toButtonsOfType:(CXAlertViewButtonType)type {
    for (CXAlertButtonItem *button in _buttons) {
        if (button.type == type) {
            [button setTitleColor:color forState:UIControlStateNormal];
            [button setTitleColor:[color colorWithAlphaComponent:0.8] forState:UIControlStateHighlighted];
        }
    }
}
@end
