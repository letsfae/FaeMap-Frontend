//
//  FaeProblemEmailVC.m
//  Fae
//
//  Created by Liu on 3/1/16.
//  Copyright (c) 2016 Aorinix Technologies Inc. All rights reserved.
//

#import "FaeProblemEmailVC.h"
#import "Constant.h"
#import "FaeAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "TPKeyboardAvoidingScrollView.h"

@interface FaeProblemEmailVC ()

@end

@implementation FaeProblemEmailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initUI
{
    [scrollView setContentSize:CGSizeMake(design_panel.frame.size.width, design_panel.frame.size.height)];
    
    // Init Join Button
    
    [btn_Recover setBackgroundColor:RED_COLOR];
    [btn_Recover.layer setCornerRadius:8.f];
    [btn_Recover.titleLabel setTextColor:[UIColor whiteColor]];
    
    // Init Status ImageView and Join Button
    
    [self updateCatImageandJoin:NO];
    
    [design_panel setBackgroundColor:[UIColor clearColor]];
    [design_panel setAlpha:1.0];
    
    // Set Copyright
    [lbl_CopyRight setFont:FONT_LIGHT(11)];
    [lbl_CopyRight setTextColor:RED_COLOR];
    
    [btn_Recover setBackgroundColor:[UIColor whiteColor]];
    [btn_Recover.layer setCornerRadius:13.f];
    
    [btn_Recover.layer setBorderColor:[UIColor colorWithRed:249.0f/255 green:90.0f/255 blue:90.0f/255 alpha:1].CGColor];
    
    [btn_Recover.layer setBorderWidth:3.0f];
    [btn_Recover.titleLabel setTextColor:[UIColor blackColor]];
    [btn_Recover.titleLabel setFont:FONT_REGULAR(22)];
    
    // Init Terms and Service Label
    
    NSString* string1 = @"For other problems with signin in\nor the account in general, enter Fae\nas";
    NSString* string2 = @" and contact ";
    NSString* string3 = @" directly";
    
    NSDictionary *thin_attributes = @{NSFontAttributeName:FONT_EXTRALIGHT(15),
                                      NSForegroundColorAttributeName:RED_COLOR
                                      };
    
    NSDictionary *bold_attributes = @{NSFontAttributeName:FONT_SEMIBOLD(15),
                                      NSForegroundColorAttributeName:RED_COLOR
                                      };
    
    NSMutableAttributedString *attributedString1 =
    [[NSMutableAttributedString alloc] initWithString:string1
                                           attributes:thin_attributes];
    
    NSMutableAttributedString *attributedString2 =
    [[NSMutableAttributedString alloc] initWithString:string2
                                           attributes:thin_attributes];
    
    NSMutableAttributedString *attributedString3 =
    [[NSMutableAttributedString alloc] initWithString:string3
                                           attributes:thin_attributes];
    
    NSMutableAttributedString *attributedGuest =
    [[NSMutableAttributedString alloc] initWithString:PROBLEM_GUEST
                                           attributes:bold_attributes];
    
    NSMutableAttributedString *attributedSupport =
    [[NSMutableAttributedString alloc] initWithString:PROBLEM_SUPPORT
                                           attributes:bold_attributes];
    
    [attributedGuest addAttribute:NSLinkAttributeName
                            value:PROBLEM_GUEST_link
                            range:NSMakeRange(0, PROBLEM_GUEST.length)];
    
    [attributedSupport addAttribute:NSLinkAttributeName
                              value:PROBLEM_SUPPORT_link
                              range:NSMakeRange(0, PROBLEM_SUPPORT.length)];
    
    NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    
    [attributedString1 appendAttributedString:attributedGuest];
    [attributedString1 appendAttributedString:attributedString2];
    [attributedString1 appendAttributedString:attributedSupport];
    [attributedSupport appendAttributedString:attributedString3];
    
    [txt_Terms setScrollEnabled:NO];
    
    [attributedString1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedString1.string.length)];
    [txt_Terms setAttributedText:attributedString1];
    
    txt_Terms.linkTextAttributes = @{NSForegroundColorAttributeName : RED_COLOR};
    
    [txt_Terms setBackgroundColor:[UIColor clearColor]];
    
    txt_Terms.selectable = YES;
    txt_Terms.dataDetectorTypes = UIDataDetectorTypeAll;
    [txt_Terms setEditable:NO];
    txt_Terms.delegate = self;
}

- (void)updateCatImageandJoin:(BOOL)flag
{
    if (flag)
    {
        [btn_Recover setBackgroundColor:RED_COLOR];
    }
    else
    {
        [btn_Recover setBackgroundColor:RED_COLOR_WITHOPACITY];
    }
    
    [btn_Recover setUserInteractionEnabled:flag];
}

// - Update UI Control's color and status
- (void)updateUIStatus:(UITextField* )textField
{
    // Check Email field
    if ([textField isEqual:txt_email])
    {
        [icon_email setImage:[UIImage imageNamed:EMAIL_GRAY]];
        [lineView_email setBackgroundColor:RED_COLOR];
        
        if (textField.text.length == 0
            || textField.text == Nil
            || [textField.text isEqualToString:@""])
        {
            
        }
        else
        {
            
        }
    }
}

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onNext:(id)sender
{
    // Will go to email VC
    
}

#pragma mark - CCHLinkAttributeName Delegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    NSString* openPath = [URL absoluteString];
    
    DLog(@"%@", openPath);
    
    if ([openPath isEqualToString:PROBLEM_GUEST_link])
    {
        [[FaeAppDelegate sharedDelegate] ShowAlert:kApplicationName messageContent:PROBLEM_GUEST_link];
    }
    else if ([openPath isEqualToString:PROBLEM_SUPPORT_link])
    {
        [[FaeAppDelegate sharedDelegate] ShowAlert:kApplicationName messageContent:PROBLEM_SUPPORT_link];
    }
    
    if ([[UIApplication sharedApplication] canOpenURL:URL])
    {
        [[UIApplication sharedApplication] openURL:URL];
    }
    
    return NO;
}

#pragma mark - UITextField Delegates

// Check the textfield whenever change event is occured

-(void)textFieldDidChange :(UITextField *)textField
{
    [self updateUIStatus:textField];
}

// If the textField get the focus, then update the UI controls

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [textField setTintColor:RED_COLOR];
    [textField setTextColor:RED_COLOR];
    
    [self updateUIStatus:textField];
    
    [self updateCatImageandJoin:NO];
}

// If the textField drop the focus, then update the UI controls

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField isEqual:txt_email])
    {
        if (textField.text.length == 0
            || textField.text == Nil
            || [textField.text isEqualToString:@""])
        {
            [icon_email setImage:[UIImage imageNamed:SIGNIN_EMAIL_GRAY]];
            [lineView_email setBackgroundColor:GRAY_COLOR];
        }
        else
        {
            [icon_email setImage:[UIImage imageNamed:SIGNIN_EMAIL_RED]];
            [lineView_email setBackgroundColor:RED_COLOR];
        }
    }
    
    if ([[FaeAppDelegate sharedDelegate] isValidEmail:txt_email.text])
    {
        [self updateCatImageandJoin:YES];
    }
    else
    {
        [self updateCatImageandJoin:NO];
    }
}

// Keyboard update accoording to the Return button

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

@end
