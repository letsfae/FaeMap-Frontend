//
//  AIDatePickerController.m
//  AIDatePickerController
//
//  Created by Ali Karagoz on 27/10/2013.
//  Copyright (c) 2013 Ali Karagoz All rights reserved.
//

#import "AIDatePickerController.h"

static NSTimeInterval const AIAnimatedTransitionDuration = 0.4;

@interface AIDatePickerController () <UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate>

@property (nonatomic) UIButton *dismissButton;
@property (nonatomic) UIView *datePickerContainerView;
@property (nonatomic) UIView *dimmedView;

// UIButton Actions
- (void)didTouchCancelButton:(id)sender;
- (void)didTouchSelectButton:(id)sender;

@end

@implementation AIDatePickerController

#pragma mark - Init

+ (id)pickerWithDate:(NSDate *)date selectedBlock:(AIDatePickerDateBlock)selectedBlock cancelBlock:(AIDatePickerVoidBlock)cancelBlock {
    
    if (![date isKindOfClass:NSDate.class]) {
        date = [NSDate date];
    }
    
    AIDatePickerController *datePickerController = [AIDatePickerController new];
    
    datePickerController.datePicker.date = date;
    datePickerController.selectedDate = date;
    datePickerController.dateBlock = [selectedBlock copy];
    datePickerController.voidBlock = [cancelBlock copy];
    
    return datePickerController;
}

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // Custom transition
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.transitioningDelegate = self;
    
    // Date Picker
    _datePicker = [UIDatePicker new];
    _datePicker.translatesAutoresizingMaskIntoConstraints = NO;
    _datePicker.backgroundColor = [UIColor whiteColor];
    _datePicker.datePickerMode = UIDatePickerModeDate;
    
    [_datePicker addTarget:self
                    action:@selector(dateIsChanged:)
          forControlEvents:UIControlEventValueChanged];
    
    return self;
}

- (void)dealloc {
    
}

#pragma mark - UIViewController

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)loadView {
    [super loadView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    // Dismiss View
    _dismissButton = [UIButton new];
    _dismissButton.translatesAutoresizingMaskIntoConstraints = NO;
    _dismissButton.userInteractionEnabled = YES;
    [_dismissButton addTarget:self action:@selector(didTouchSelectButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_dismissButton];
    
    // Date Picker Container
    _datePickerContainerView = [UIView new];
    _datePickerContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    _datePickerContainerView.backgroundColor = [UIColor clearColor];
    _datePickerContainerView.clipsToBounds = YES;
    _datePickerContainerView.layer.cornerRadius = 5.0;
    [self.view addSubview:_datePickerContainerView];
    
    // Date Picker
    [_datePickerContainerView addSubview:_datePicker];
    
    // Layout
    NSDictionary *views = NSDictionaryOfVariableBindings(_dismissButton,
                                                         _datePickerContainerView,
                                                         _datePicker);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_datePicker]|" options:0 metrics:nil views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_datePicker]|" options:0 metrics:nil views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_dismissButton]|" options:0 metrics:nil views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_datePickerContainerView]|" options:0 metrics:nil views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_dismissButton][_datePickerContainerView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
}

- (void)dateIsChanged:(id)sender
{
    self.selectedDate = _datePicker.date;
    
    NSLog(@"Date changed : %@", _datePicker.date);
}

#pragma mark - UIButton Actions

- (void)didTouchCancelButton:(id)sender {
    if (self.voidBlock != nil) {
        self.voidBlock();
        self.voidBlock = nil;
    }
}

- (void)didTouchSelectButton:(id)sender {
    if (self.dateBlock != nil)
    {
        self.dateBlock(self.selectedDate);
        
        self.dateBlock = nil;
    }
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return AIAnimatedTransitionDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    // If we are presenting
    if (toViewController.view == self.view) {
        fromViewController.view.userInteractionEnabled = NO;
        
        // Adding the view in the right order
        [containerView addSubview:self.dimmedView];
        [containerView addSubview:toViewController.view];
        
        // Moving the view OUT
        CGRect frame = toViewController.view.frame;
        frame.origin.y = CGRectGetHeight(toViewController.view.bounds);
        toViewController.view.frame = frame;
        
        self.dimmedView.alpha = 0.0;
        
        [UIView animateWithDuration:AIAnimatedTransitionDuration delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            self.dimmedView.alpha = 0.0;
            
            // Moving the view IN
            CGRect frame = toViewController.view.frame;
            frame.origin.y = 0.0;
            toViewController.view.frame = frame;
            
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
    }
    
    // If we are dismissing
    else {
        toViewController.view.userInteractionEnabled = YES;
        
        [UIView animateWithDuration:AIAnimatedTransitionDuration delay:0.1 usingSpringWithDamping:1.0 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.dimmedView.alpha = 0.0;
            
            // Moving the view OUT
            CGRect frame = fromViewController.view.frame;
            frame.origin.y = CGRectGetHeight(fromViewController.view.bounds);
            fromViewController.view.frame = frame;
            
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
    }
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                   presentingController:(UIViewController *)presenting
                                                                       sourceController:(UIViewController *)source {
    return self;
}


- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}

#pragma mark - Factory Methods

- (UIView *)dimmedView {
    if (!_dimmedView) {
        UIView *dimmedView = [[UIView alloc] initWithFrame:self.view.bounds];
        dimmedView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        dimmedView.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
        dimmedView.backgroundColor = [UIColor blackColor];
        _dimmedView = dimmedView;
    }
    
    return _dimmedView;
}

@end
