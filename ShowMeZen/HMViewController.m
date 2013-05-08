//
//  HMViewController.m
//  ShowMeZen
//
//  Created by Ben Stovold on 07/05/2013.
//  Copyright (c) 2013 Hydric Media Pty Ltd. All rights reserved.
//

#import "HMViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface HMViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *logoImageView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *logoImageViewTopConstraint;
@property (nonatomic, assign) CGFloat logoImageViewTopConstraintConstantFromNib;

@property (nonatomic, weak) IBOutlet UIView *fieldView;
@property (nonatomic, weak) IBOutlet UITextField *userTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;
@property (nonatomic, weak) IBOutlet UIButton *loginButton;
@property (nonatomic, strong) IBOutletCollection(NSLayoutConstraint) NSArray *spacingConstraints;

@end

@implementation HMViewController


#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.fieldView.layer.cornerRadius = 4.f;
    self.fieldView.layer.borderColor = [UIColor colorWithWhite:0.75f alpha:1.f].CGColor;
    self.fieldView.layer.borderWidth = 1.f;
    
    
    self.logoImageViewTopConstraintConstantFromNib = self.logoImageViewTopConstraint.constant;
    self.logoImageViewTopConstraint.constant = 0.33f * CGRectGetHeight(self.view.bounds);
    self.fieldView.alpha = self.loginButton.alpha = 0.f;
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    CGFloat durationUnit = 0.33f;
    
    self.logoImageViewTopConstraint.constant = self.logoImageViewTopConstraintConstantFromNib;
    [self.logoImageView setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:durationUnit delay:durationUnit*2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        [self.logoImageView layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:durationUnit delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            self.fieldView.alpha = self.loginButton.alpha = 1.f;
            
        } completion:nil];
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name: UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name: UIKeyboardWillHideNotification object:nil];
    
    [super viewWillDisappear:animated];
}

#pragma mark - NSNotification handling

- (void)keyboardWillShow:(NSNotification*)notification
{
    NSTimeInterval duration;
    UIViewAnimationOptions animationOptions;
    [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationOptions];
    [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&duration];
    
    for (NSLayoutConstraint *constraint in self.spacingConstraints) {
        constraint.constant = [self deviceIsTall] ? 26.f : 15.f;
    }
    
    [self.view setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:duration delay:0.f options:animationOptions animations:^ {
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    NSTimeInterval duration;
    UIViewAnimationOptions animationOptions;
    [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationOptions];
    [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&duration];
    
    [UIView animateWithDuration:duration delay:0.f options:animationOptions animations:^ {
        for (NSLayoutConstraint *constraint in self.spacingConstraints) {
            constraint.constant = 32.f;
        }
        [self.view layoutIfNeeded];
    } completion:nil];
}


#pragma mark - IBActions

- (IBAction)viewTapped:(id)sender
{
    [self.userTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

- (IBAction)attemptLogin:(id)sender
{
    if (self.userTextField.text.length > 0 && self.passwordTextField.text.length > 0) {
        
        if ([self.userTextField isFirstResponder]) {
            [self.userTextField resignFirstResponder];
        } else if ([self.passwordTextField isFirstResponder]) {
            [self.passwordTextField resignFirstResponder];
        }
        
        // Do login here
    }
}

#pragma mark - UITextFieldDelegate conformance

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.loginButton.enabled = (self.userTextField.text.length > 0 && self.passwordTextField.text.length > 0);
    });
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.userTextField]) {
        [self.passwordTextField becomeFirstResponder];
    } else if (self.userTextField.text.length > 0) {
        [self attemptLogin:self];
    } else {
        [self.userTextField becomeFirstResponder];
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if ([textField isEqual:self.userTextField] && self.passwordTextField.text.length) {
        self.passwordTextField.text = nil;
    }
    self.loginButton.enabled = NO;
    
    return YES;
}

#pragma mark - Private methods

- (BOOL)deviceIsTall
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return [UIScreen mainScreen].bounds.size.height > 480.f;
    }
    
    return NO;
}

@end
