//
//  FaeWelcomeVC.m
//  Fae
//
//  Created by Liu on 2/25/16.
//  Copyright (c) 2016 Aorinix Technologies Inc. All rights reserved.
//

#import "FaeWelcomeVC.h"
#import "FaeSignupVC.h"
#import "FaeSigninVC.h"
#import "FaeAppDelegate.h"
#import "Global.h"
#import "Constant.h"
#import "UIButton+BBCBackgroundColor.h"
#import "FaeMyCardVC.h"

@interface FaeWelcomeVC ()

@end

@implementation FaeWelcomeVC

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 
- (void) initUI
{
    // Set Backgroud Color
    [self.view setBackgroundColor:RED_COLOR];
    
    // Set Ballon Welcome Label
    
    [lbl_ballonWelcome setFont:FONT_SEMIBOLD(36)];
    [lbl_ballonWelcome setTextColor:RED_COLOR];
    
    // Set Copyright
    if (gDeviceType == DEVICE_IPHONE_47INCH
        || gDeviceType == DEVICE_IPHONE_55INCH)
    {
        [lbl_Copyright setFont:FONT_LIGHT(11)];
    }
    else
    {
        [lbl_Copyright setFont:FONT_LIGHT(10)];
    }
    
    [lbl_Copyright setTextColor:[UIColor whiteColor]];
    
    // Setup Buttons
    
    CGFloat cornerRadius = 13.0f;
    CGFloat borderWidth = 3.0f;
    CGFloat labelFontSize = 22;
    
    if (gDeviceType == DEVICE_IPHONE_35INCH)
    {
        cornerRadius = 10.0f;
        borderWidth = 2.0f;
        labelFontSize = 18.0f;
    }
    else if (gDeviceType == DEVICE_IPHONE_40INCH)
    {
        cornerRadius = 10.0f;
        borderWidth = 2.0f;
        labelFontSize = 18.0f;
    }
    else
    {
        cornerRadius = 13.0f;
        borderWidth = 3.0f;
        labelFontSize = 22.0f;
    }
    
    // Button Color
    [btn_signin setTitleColor:[UIColor whiteColor] forState:(UIControlStateSelected | UIControlStateNormal | UIControlStateDisabled | UIControlStateHighlighted)];
    
    [btn_join setTitleColor:[UIColor whiteColor] forState:(UIControlStateSelected | UIControlStateNormal | UIControlStateDisabled | UIControlStateHighlighted)];
    
    [btn_look setTitleColor:[UIColor whiteColor] forState:(UIControlStateSelected | UIControlStateNormal | UIControlStateDisabled | UIControlStateHighlighted)];
    
    [btn_signin setBackgroundColor:[UIColor clearColor]];
    [btn_signin.layer setCornerRadius:cornerRadius];
    [btn_signin.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [btn_signin.layer setBorderWidth:borderWidth];
    btn_signin.clipsToBounds = YES;
    [btn_signin.titleLabel setTextColor:[UIColor whiteColor]];
    [btn_signin.titleLabel setFont:FONT_REGULAR(labelFontSize)];
        
    [btn_join setBackgroundColor:[UIColor clearColor]];
    [btn_join.layer setCornerRadius:cornerRadius];
    [btn_join.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [btn_join.layer setBorderWidth:borderWidth];
    btn_join.clipsToBounds = YES;
    [btn_join.titleLabel setTextColor:[UIColor whiteColor]];
    [btn_join.titleLabel setFont:FONT_REGULAR(labelFontSize)];
    
    [btn_look setBackgroundColor:[UIColor clearColor]];
    [btn_look.layer setCornerRadius:cornerRadius];
    [btn_look.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [btn_look.layer setBorderWidth:borderWidth];
    btn_look.clipsToBounds = YES;
    [btn_look.titleLabel setTextColor:[UIColor whiteColor]];
    [btn_look.titleLabel setFont:FONT_REGULAR(labelFontSize)];
    
    
    [btn_signin bbc_backgroundColorNormal:[UIColor clearColor]
                  backgroundColorSelected:[UIColor colorWithWhite:1.0 alpha:0.3]];
    
    [btn_join bbc_backgroundColorNormal:[UIColor clearColor]
                backgroundColorSelected:[UIColor colorWithWhite:1.0 alpha:0.3]];
    
    [btn_look bbc_backgroundColorNormal:[UIColor clearColor]
                backgroundColorSelected:[UIColor colorWithWhite:1.0 alpha:0.3]];
    
    
}

#pragma mark - IBActions

- (IBAction)onSignin:(id)sender
{
    FaeSigninVC* signinVC = [[FaeSigninVC alloc] initWithNibName:@"FaeSigninVC" bundle:nil];
    
    [self.navigationController pushViewController:signinVC animated:YES];
}

- (IBAction)onJoin:(id)sender
{
//    FaeMyCardVC* myCardVC = [[FaeMyCardVC alloc] initWithNibName:@"FaeMyCardVC" bundle:Nil];
//    
//    [self.navigationController pushViewController:myCardVC animated:YES];
//    
//    return;
    
    FaeSignupVC* signupVC = [[FaeSignupVC alloc] initWithNibName:@"FaeSignupVC" bundle:nil];
    
    [self.navigationController pushViewController:signupVC animated:YES];
}

- (IBAction)onLook:(id)sender
{
    [[FaeAppDelegate sharedDelegate] AutoHiddenAlert:kApplicationName
                                      messageContent:@"Under the Development"];
}


@end
