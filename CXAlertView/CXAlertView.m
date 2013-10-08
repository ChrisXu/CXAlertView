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
#import "CXAlertButtonContainerView.h"
#import <QuartzCore/QuartzCore.h>

#import "LFGlassView.h"

static CGFloat const kDefaultScrollViewPadding = 10.;
static CGFloat const kDefaultButtonHeight = 44.;
static CGFloat const kDefaultContainerWidth = 280.;
static CGFloat const kDefaultVericalPadding = 10.;
static CGFloat const kDefaultTopScrollViewMaxHeight = 50.;
static CGFloat const kDefaultTopScrollViewMinHeight = 10.;
static CGFloat const kDefaultContentScrollViewMaxHeight = 180.;
static CGFloat const kDefaultContentScrollViewMinHeight = 0.;
static CGFloat const kDefaultBottomScrollViewHeight = 44.;

//#define BOTTOM_MIN_HEIGHT 44

@class CXAlertButtonItem;
@class CXAlertViewController;

static NSMutableArray *__cx_pending_alert_queue;
static BOOL __cx_alert_animating;
static CXAlertBackgroundWindow *__cx_alert_background_window;
static CXAlertView *__cx_alert_current_view;

@interface CXAlertView ()
{
    BOOL _updateAnimated;
    NSString *_cancelButtonTitle;
}

@property (nonatomic, strong) UIWindow *oldKeyWindow;
@property (nonatomic, strong) UIWindow *alertWindow;
@property (nonatomic, assign, getter = isVisible) BOOL visible;

@property (nonatomic, strong) UIScrollView *topScrollView;
@property (nonatomic, strong) UIScrollView *contentScrollView;
@property (nonatomic, strong) CXAlertButtonContainerView *bottomScrollView;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) LFGlassView *blurView;

@property (nonatomic, strong) NSMutableArray *buttons;

@property (nonatomic, assign, getter = isLayoutDirty) BOOL layoutDirty;

+ (NSMutableArray *)sharedQueue;
+ (CXAlertView *)currentAlertView;

+ (BOOL)isAnimating;
+ (void)setAnimating:(BOOL)animating;

+ (void)showBackground;
+ (void)hideBackgroundAnimated:(BOOL)animated;
// Height
- (CGFloat)heightWithText:(NSString *)text font:(UIFont *)font;
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
- (void)addButtonWithTitle:(NSString *)title type:(CXAlertViewButtonType)type handler:(CXAlertButtonHandler)handler font:(UIFont *)font;
- (CXAlertButtonItem *)buttonItemWithType:(CXAlertViewButtonType)type font:(UIFont *)font;
- (void)buttonAction:(CXAlertButtonItem *)buttonItem;
- (void)setButtonImage:(UIImage *)image forState:(UIControlState)state andButtonType:(CXAlertViewButtonType)type;
- (void)updateAllButtonsFont;
// Blur
- (void)updateBlurBackground;
@end

@implementation CXAlertView

+ (void)initialize
{
    if (self != [CXAlertView class])
        return;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        CXAlertView *appearance = [self appearance];
        appearance.viewBackgroundColor = [UIColor whiteColor];
        appearance.titleColor = [UIColor blackColor];
        appearance.titleFont = [UIFont boldSystemFontOfSize:20];
        appearance.buttonFont = [UIFont systemFontOfSize:[UIFont buttonFontSize]];
        appearance.buttonColor = [UIColor colorWithRed:0.0f green:0.5f blue:1.0f alpha:1.0f];
        appearance.cancelButtonColor = [UIColor colorWithRed:0.0f green:0.5f blue:1.0f alpha:1.0f];
        appearance.cancelButtonFont = [UIFont boldSystemFontOfSize:18.];
        appearance.customButtonColor = [UIColor colorWithRed:0.075f green:0.6f blue:0.9f alpha:1.0f];
        appearance.customButtonFont = [UIFont systemFontOfSize:18.];
        appearance.cornerRadius = 8;
        appearance.shadowRadius = 8;
    });
}

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
- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle
{
    _vericalPadding = kDefaultVericalPadding;
    _containerWidth = kDefaultContainerWidth;
    
    UILabel *messageLabel = [[UILabel alloc] init];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.backgroundColor = [UIColor clearColor];
    messageLabel.font = [UIFont systemFontOfSize:14.0];
    messageLabel.textColor = [UIColor blackColor];
    messageLabel.numberOfLines = 0;
    messageLabel.text = message;
    messageLabel.frame = CGRectMake( self.vericalPadding, 0, self.containerWidth - self.vericalPadding*2, [self heightWithText:message font:messageLabel.font]);
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_6_0
    messageLabel.lineBreakMode = NSLineBreakByTruncatingTail;
#else
    messageLabel.lineBreakMode = UILineBreakModeTailTruncation;
#endif
    
    return  [self initWithTitle:title contentView:messageLabel cancelButtonTitle:cancelButtonTitle];
}

- (id)initWithTitle:(NSString *)title contentView:(UIView *)contentView cancelButtonTitle:(NSString *)cancelButtonTitle
{
    self = [super init];
    if (self) {
        _buttons = [[NSMutableArray alloc] init];
        _title = title;
        _contentView = contentView;
        
        _scrollViewPadding = kDefaultScrollViewPadding;
        _buttonHeight = kDefaultButtonHeight;
        _containerWidth = kDefaultContainerWidth;
        _vericalPadding = kDefaultVericalPadding;
        _topScrollViewMaxHeight = kDefaultTopScrollViewMaxHeight;
        _topScrollViewMinHeight = kDefaultTopScrollViewMinHeight;
        _contentScrollViewMaxHeight = kDefaultContentScrollViewMaxHeight;
        _contentScrollViewMinHeight = kDefaultContentScrollViewMinHeight;
        _bottomScrollViewHeight = kDefaultBottomScrollViewHeight;
        
        _showButtonLine = YES;
        _showBlurBackground = YES;
        [self setupScrollViews];
        if (cancelButtonTitle) {
            [self addButtonWithTitle:cancelButtonTitle type:CXAlertViewButtonTypeCancel handler:^(CXAlertView *alertView, CXAlertButtonItem *button) {
                [alertView dismiss];
            }];
        }
    }
    return self;
}
// Buttons
- (void)addButtonWithTitle:(NSString *)title type:(CXAlertViewButtonType)type handler:(CXAlertButtonHandler)handler
{
    UIFont *font = nil;
    switch (type) {
		case CXAlertViewButtonTypeCancel:
			font = self.cancelButtonFont;
			break;
		case CXAlertViewButtonTypeCustom:
            font = self.customButtonFont;
			break;
		case CXAlertViewButtonTypeDefault:
		default:
			font = self.buttonFont;
			break;
	}
    [self addButtonWithTitle:title type:type handler:handler font:font];
}

- (void)setDefaultButtonImage:(UIImage *)defaultButtonImage forState:(UIControlState)state
{
    [self setButtonImage:defaultButtonImage forState:state andButtonType:CXAlertViewButtonTypeDefault];
}

- (void)setCancelButtonImage:(UIImage *)cancelButtonImage forState:(UIControlState)state
{
    [self setButtonImage:cancelButtonImage forState:state andButtonType:CXAlertViewButtonTypeCancel];
}

- (void)setCustomButtonImage:(UIImage *)customButtonImage forState:(UIControlState)state
{
    [self setButtonImage:customButtonImage forState:state andButtonType:CXAlertViewButtonTypeCustom];
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

- (CGFloat)heightWithText:(NSString *)text font:(UIFont *)font
{
    if (text) {
        CGSize size = CGSizeZero;
        CGSize rSize = CGSizeMake(self.containerWidth - 2*self.vericalPadding - 1, NSUIntegerMax);
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_7_0
        NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys: font, NSFontAttributeName, nil];
        CGRect rect = [text boundingRectWithSize:rSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
        size = rect.size;
#else
        size = [text sizeWithFont:font constrainedToSize:rSize];
#endif
        return size.height;
    }
    
    return 0;
}

- (CGFloat)preferredHeight
{
    CGFloat height = 0;
    height += ([self heightForTopScrollView] + self.scrollViewPadding);
    height += ([self heightForContentScrollView] + self.scrollViewPadding);
    height += ([self heightForBottomScrollView] + self.scrollViewPadding);
    return height;
}

- (CGFloat)heightForTopScrollView
{
    return MAX(self.topScrollViewMinHeight, MIN(self.topScrollViewMaxHeight, CGRectGetHeight(_titleLabel.frame)));
}

- (CGFloat)heightForContentScrollView
{
    return MAX(self.contentScrollViewMinHeight, MIN(self.contentScrollViewMaxHeight, CGRectGetHeight(self.contentView.frame)));
}

- (CGFloat)heightForBottomScrollView
{
    return self.bottomScrollViewHeight;
}

- (void)setup
{
    [self setupContainerView];
    [self setupScrollViews];
    [self updateTopScrollView];
    [self updateContentScrollView];
    [self updateBottomScrollView];
}

- (void)tearDown
{
    [self.containerView removeFromSuperview];
    [self.blurView removeFromSuperview];
    
    [self.titleLabel removeFromSuperview];
    self.titleLabel = nil;
    
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
    CGFloat left = (self.bounds.size.width - self.containerWidth) * 0.5;
    CGFloat top = (self.bounds.size.height - height) * 0.5;
    _containerView.transform = CGAffineTransformIdentity;
    _blurView.transform = CGAffineTransformIdentity;
    if (_updateAnimated) {
        _updateAnimated = NO;
        [UIView animateWithDuration:0.3 animations:^{
            _containerView.frame = CGRectMake(left, top, self.containerWidth, height);
            _blurView.frame = CGRectMake(left, top, self.containerWidth, height);
        }];
    }
    else {
        _containerView.frame = CGRectMake(left, top, self.containerWidth, height);
        _blurView.frame = CGRectMake(left, top, self.containerWidth, height);
    }
    _containerView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:_containerView.bounds cornerRadius:_containerView.layer.cornerRadius].CGPath;
}

- (void)invalidateLayout
{
    self.layoutDirty = YES;
    [self setNeedsLayout];
}

- (void)resetTransition
{
    [_containerView.layer removeAllAnimations];
}
// Scroll Views
- (void)setupContainerView
{
    _containerView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:self.containerView];
    
    _containerView.clipsToBounds = YES;
    
    _containerView.backgroundColor = _viewBackgroundColor ? _viewBackgroundColor : [UIColor whiteColor];
    _containerView.layer.cornerRadius = self.cornerRadius;
    _containerView.layer.shadowOffset = CGSizeZero;
    _containerView.layer.shadowRadius = self.shadowRadius;
    _containerView.layer.shadowOpacity = 0.5;
    
    [self updateBlurBackground];
}

- (void)setupScrollViews
{
    if (!_topScrollView) {
        _topScrollView = [[UIScrollView alloc] init];
    }
    
    if (!_contentScrollView) {
        _contentScrollView = [[UIScrollView alloc] init];
    }
    
    if (!_bottomScrollView) {
        _bottomScrollView = [[CXAlertButtonContainerView alloc] init];
        _bottomScrollView.defaultTopLineVisible = _showButtonLine;
    }
}

- (void)updateTopScrollView
{
    if (self.title) {
        if (!_titleLabel) {
            _titleLabel = [[UILabel alloc] init];
            [_topScrollView addSubview:_titleLabel];
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
        _titleLabel.frame = CGRectMake( self.vericalPadding, 0, self.containerWidth - self.vericalPadding*2, [self heightWithText:self.title font:_titleLabel.font]);
        _titleLabel.text = self.title;
        
        _topScrollView.frame = CGRectMake( 0 , self.scrollViewPadding, self.containerWidth, [self heightForTopScrollView]);
        _topScrollView.contentSize = _titleLabel.bounds.size;
        
        if (![_containerView.subviews containsObject:_topScrollView]) {
            [_containerView addSubview:_topScrollView];
        }
        
        [_topScrollView setScrollEnabled:([self heightForTopScrollView] < CGRectGetHeight(_titleLabel.frame))];

    }
    else {
        [_titleLabel removeFromSuperview];
        _titleLabel = nil;
        [_topScrollView setFrame:CGRectZero];
        [_topScrollView removeFromSuperview];
    }
}

- (void)updateContentScrollView
{
    for (UIView *view in _contentScrollView.subviews) {
        [view removeFromSuperview];
    }
    
    if (_contentView) {
        
        if (CGRectGetWidth(_contentView.frame) < self.containerWidth) {
            CGRect frame = _contentView.frame;
            frame.origin.x = (self.containerWidth - CGRectGetWidth(_contentView.frame))/2;
            _contentView.frame = frame;
        }
        
        [_contentScrollView addSubview:_contentView];
        
        CGFloat y = 0;
        y += [self heightForTopScrollView] + self.scrollViewPadding;
        
        y += self.scrollViewPadding;
        
        _contentScrollView.frame = CGRectMake( 0, y, self.containerWidth, [self heightForContentScrollView]);
        _contentScrollView.contentSize = _contentView.bounds.size;
        
        if (![_containerView.subviews containsObject:_contentScrollView]) {
            [_containerView addSubview:_contentScrollView];
        }
        
        [_contentScrollView setScrollEnabled:([self heightForContentScrollView] < CGRectGetHeight(_contentView.frame))];
    }
    else {
        [_contentScrollView setFrame:CGRectZero];
        [_contentScrollView removeFromSuperview];
    }
    
    [self invalidateLayout];
}

- (void)updateBottomScrollView
{
    CGFloat y = 0;
    
    y += [self heightForTopScrollView] + self.scrollViewPadding;
    
    y += [self heightForContentScrollView] + self.scrollViewPadding;
    
    y += self.scrollViewPadding;
    
    _bottomScrollView.backgroundColor = [UIColor clearColor];
    _bottomScrollView.frame = CGRectMake( 0, y, self.containerWidth, [self heightForBottomScrollView]);
    
    if (![_containerView.subviews containsObject:_bottomScrollView]) {
        [_containerView addSubview:_bottomScrollView];
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
    
    [_oldKeyWindow makeKeyWindow];
    _oldKeyWindow.hidden = NO;
}
// Transition
- (void)transitionInCompletion:(void(^)(void))completion
{
    _containerView.alpha = 0;
    _containerView.transform = CGAffineTransformMakeScale(1.2, 1.2);
    
    _blurView.alpha = 0;
    _blurView.transform = CGAffineTransformMakeScale(1.2, 1.2);
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         _containerView.alpha = 1.;
                         _containerView.transform = CGAffineTransformMakeScale(1.0,1.0);
                         
                         _blurView.alpha = 1.;
                         _blurView.transform = CGAffineTransformMakeScale(1.0,1.0);
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
                         _containerView.alpha = 0;
                         _containerView.transform = CGAffineTransformMakeScale(0.9,0.9);
                         
                         _blurView.alpha = 0;
                         _blurView.transform = CGAffineTransformMakeScale(0.9,0.9);
                     }
                     completion:^(BOOL finished) {
                         if (completion) {
                             completion();
                         }
                     }];
}

// Buttons
- (void)addButtonWithTitle:(NSString *)title type:(CXAlertViewButtonType)type handler:(CXAlertButtonHandler)handler font:(UIFont *)font
{
    CXAlertButtonItem *button = [self buttonItemWithType:type font:font];
    button.action = handler;
    button.type = type;
    button.defaultRightLineVisible = _showButtonLine;
    [button setTitle:title forState:UIControlStateNormal];
    if ([_buttons count] == 0) {
        button.defaultRightLineVisible = NO;
        button.frame = CGRectMake( self.containerWidth/4, 0, self.containerWidth/2, self.buttonHeight);
    }
    else {
        // correct first button
        CXAlertButtonItem *firstButton = [_buttons objectAtIndex:0];
        firstButton.defaultRightLineVisible = _showButtonLine;
        CGRect newFrame = firstButton.frame;
        newFrame.origin.x = 0;
        [firstButton setNeedsDisplay];
        
        CGFloat last_x = self.containerWidth/2 * [_buttons count];
        button.frame = CGRectMake( last_x + self.containerWidth/2, 0, self.containerWidth/2, self.buttonHeight);
        button.alpha = 0.;
        if (self.isVisible) {
            [UIView animateWithDuration:0.3 animations:^{
                firstButton.frame = newFrame;
                button.alpha = 1.;
                button.frame = CGRectMake( last_x, 0, self.containerWidth/2, self.buttonHeight);
            }];
        }
        else {
            firstButton.frame = newFrame;
            button.alpha = 1.;
            button.frame = CGRectMake( last_x, 0, self.containerWidth/2, self.buttonHeight);
        }
    }
    
    [_buttons addObject:button];
    [_bottomScrollView addSubview:button];
    CGFloat newContentWidth = self.bottomScrollView.contentSize.width + CGRectGetWidth(button.frame);
    _bottomScrollView.contentSize = CGSizeMake( newContentWidth, self.buttonHeight);
}

- (CXAlertButtonItem *)buttonItemWithType:(CXAlertViewButtonType)type font:(UIFont *)font
{
	CXAlertButtonItem *button = [CXAlertButtonItem buttonWithType:UIButtonTypeCustom];
//	button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    button.titleLabel.font = font;
	UIImage *normalImage = nil;
	UIImage *highlightedImage = nil;
	switch (type) {
		case CXAlertViewButtonTypeCancel:
			[button setTitleColor:self.cancelButtonColor forState:UIControlStateNormal];
            [button setTitleColor:[self.cancelButtonColor colorWithAlphaComponent:0.8] forState:UIControlStateHighlighted];
			break;
		case CXAlertViewButtonTypeCustom:
            [button setTitleColor:self.customButtonColor forState:UIControlStateNormal];
            [button setTitleColor:[self.customButtonColor colorWithAlphaComponent:0.8] forState:UIControlStateHighlighted];
			break;
		case CXAlertViewButtonTypeDefault:
		default:
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
        buttonItem.action(self,buttonItem);
    }
}

- (void)setButtonImage:(UIImage *)image forState:(UIControlState)state andButtonType:(CXAlertViewButtonType)type
{
    for (CXAlertButtonItem *button in _buttons)
    {
        if(button.type == type)
        {
            [button setBackgroundImage:image forState:state];
        }
    }
}

- (void)updateAllButtonsFont
{
    for (CXAlertButtonItem *button in _buttons) {
        switch (button.type) {
            case CXAlertViewButtonTypeCancel:
                button.titleLabel.font = self.cancelButtonFont;
                break;
            case CXAlertViewButtonTypeCustom:
                button.titleLabel.font = self.customButtonFont;
                break;
            case CXAlertViewButtonTypeDefault:
            default:
                button.titleLabel.font = self.buttonFont;
                break;
        }
    }
}

- (void)updateBlurBackground
{
    UIColor *containerBKGColor = _viewBackgroundColor ? _viewBackgroundColor : [UIColor whiteColor];
    self.containerView.backgroundColor = [containerBKGColor colorWithAlphaComponent:_showBlurBackground ? 0.7 : 1.];;
    
    if (_showBlurBackground) {
        if (self.blurView == nil) {
            self.blurView = [[LFGlassView alloc] initWithFrame:self.containerView.frame];
            self.blurView.clipsToBounds = YES;
            self.blurView.layer.cornerRadius = self.cornerRadius;
            self.blurView.blurRadius = 10.;
            self.blurView.scaleFactor = 1.;
            self.blurView.blurSuperView = self.oldKeyWindow.rootViewController.view;
        }
        
        [self insertSubview:self.blurView belowSubview:self.containerView];
    } else {
        [self.blurView removeFromSuperview];
    }
}
#pragma mark - Setter
- (void)setTitle:(NSString *)title
{
    if (_title != title) {
        _title = title;
        
        _updateAnimated = YES;
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
        
        _updateAnimated = YES;
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
    [self updateBlurBackground];
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
    [self updateAllButtonsFont];
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    if (_cornerRadius == cornerRadius) {
        return;
    }
    _cornerRadius = cornerRadius;
    self.containerView.layer.cornerRadius = cornerRadius;
    self.blurView.layer.cornerRadius = cornerRadius;
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

- (void)setCancelButtonFont:(UIFont *)cancelButtonFont
{
    if (_cancelButtonFont == cancelButtonFont) {
        return;
    }
    _cancelButtonFont = cancelButtonFont;
    [self updateAllButtonsFont];
}

- (void)setCustomButtonColor:(UIColor *)buttonColor
{
    if (_customButtonColor == buttonColor) {
        return;
    }
    _customButtonColor = buttonColor;
    [self setColor:buttonColor toButtonsOfType:CXAlertViewButtonTypeCustom];
}

- (void)setCustomButtonFont:(UIFont *)customButtonFont
{
    if (_customButtonFont == customButtonFont) {
        return;
    }
    _customButtonFont = customButtonFont;
    [self updateAllButtonsFont];
}

-(void)setColor:(UIColor *)color toButtonsOfType:(CXAlertViewButtonType)type {
    for (CXAlertButtonItem *button in _buttons) {
        if (button.type == type) {
            [button setTitleColor:color forState:UIControlStateNormal];
            [button setTitleColor:[color colorWithAlphaComponent:0.8] forState:UIControlStateHighlighted];
        }
    }
}

- (void)setShowBlurBackground:(BOOL)showBlurBackground
{
    if (_showBlurBackground == showBlurBackground) {
        return;
    }
    _showBlurBackground = showBlurBackground;
    [self updateBlurBackground];
}
@end
