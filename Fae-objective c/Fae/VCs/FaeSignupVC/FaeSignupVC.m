//
//  FaeSignupVC.m
//  Fae
//
//  Created by Liu on 2/25/16.
//  Copyright (c) 2016 Aorinix Technologies Inc. All rights reserved.
//

#import "FaeSignupVC.h"
#import "FaeAppDelegate.h"
#import "Constant.h"
#import "Global.h"
#import <QuartzCore/QuartzCore.h>
#import "SHSPhoneLibrary.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "FaeMyCardVC.h"

////////////////////////////////////////
// - Define MACROS




@interface FaeSignupVC ()

@end

@implementation FaeSignupVC

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Will Init the UI Controls as it is the first screen.
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Utility Functions

// - Initialize the User Interface
- (void)initUI
{
    if (gDeviceType == DEVICE_IPHONE_35INCH)
    {
        underline_LeftPadding.constant = 20.0f;
        
        img_cat_topPadding.constant = 15.0f;
        panel_topPadding.constant = -5.0f;
        
        line_email_topPadding.constant = 40.0f;
        line_pass_topPadding.constant = 85.0f;
        line_conf_topPadding.constant = 130.0f;
        
        icon_email_Width.constant = 18.0f;
        icon_pass_Width.constant = 15.0f;
        icon_conf_Width.constant = 20.0f;
        
        icon_pass_Offset_Center.constant = 3.0f;
        icon_conf_Offset_Center.constant = -2.0f;
        
        txt_height.constant = 30.0f;
        txt_left_padding.constant = 32.0f;
        txt_email_bottom_padding.constant = -3.0f;
        txt_pass_bottom_padding.constant = -3.0f;
        txt_conf_bottom_padding.constant = -3.0f;
        
        checkicon_Width.constant = 15.0f;
        checkBtn_Width.constant = 45.0f;
        
        btnJoinTopPadding.constant = 30.0f;
        btnJoinHeight.constant = 36.0f;
        
        tosTopPadding.constant = 5.0f;
        
        lbl_Copyright_Height.constant = 40.0f;
    }
    else if (gDeviceType == DEVICE_IPHONE_40INCH)
    {
        underline_LeftPadding.constant = 20.0f;
        
        img_cat_topPadding.constant = 65.0f;
        panel_topPadding.constant = 0.0f;
        
        line_email_topPadding.constant = 40.0f;
        line_pass_topPadding.constant = 85.0f;
        line_conf_topPadding.constant = 130.0f;
        
        icon_email_Width.constant = 18.0f;
        icon_pass_Width.constant = 15.0f;
        icon_conf_Width.constant = 20.0f;
        
        icon_pass_Offset_Center.constant = 3.0f;
        icon_conf_Offset_Center.constant = -2.0f;
        
        txt_height.constant = 30.0f;
        txt_left_padding.constant = 32.0f;
        txt_email_bottom_padding.constant = -3.0f;
        txt_pass_bottom_padding.constant = -3.0f;
        txt_conf_bottom_padding.constant = -3.0f;
        
        checkicon_Width.constant = 15.0f;
        checkBtn_Width.constant = 45.0f;
        
        btnJoinTopPadding.constant = 30.0f;
        btnJoinHeight.constant = 36.0f;
        
        tosTopPadding.constant = 5.0f;
        
        lbl_Copyright_Height.constant = 40.0f;
    }
    else if (gDeviceType == DEVICE_IPHONE_47INCH)
    {
        underline_LeftPadding.constant = 30.0f;
        
        img_cat_topPadding.constant = 40.0f;
        panel_topPadding.constant = 10.0f;
        
        line_email_topPadding.constant = 56.0f;
        line_pass_topPadding.constant = 112.0f;
        line_conf_topPadding.constant = 168.0f;
        
        icon_email_Width.constant = 21.0f;
        icon_pass_Width.constant = 17.0f;
        icon_conf_Width.constant = 24.0f;
        
        icon_pass_Offset_Center.constant = 3.0f;
        icon_conf_Offset_Center.constant = -2.0f;
        
        txt_height.constant = 30.0f;
        txt_left_padding.constant = 37.0f;
        
        txt_email_bottom_padding.constant = 1.0f;
        txt_pass_bottom_padding.constant = 1.0f;
        
        checkicon_Width.constant = 19.0f;
        checkBtn_Width.constant = 50.0f;
        
        btnJoinTopPadding.constant = 33.0f;
        btnJoinHeight.constant = 43.0f;
        
        tosTopPadding.constant = 15.0f;
        
        lbl_Copyright_Height.constant = 50.0f;
    }
    else if (gDeviceType == DEVICE_IPHONE_55INCH)
    {
        underline_LeftPadding.constant = 30.0f;
        
        img_cat_topPadding.constant = 60.0f;
        panel_topPadding.constant = 10.0f;
        
        line_email_topPadding.constant = 64.0f;
        line_pass_topPadding.constant = 128.0f;
        line_conf_topPadding.constant = 192.0f;
        
        icon_email_Width.constant = 21.0f;
        icon_pass_Width.constant = 17.0f;
        icon_conf_Width.constant = 24.0f;
        
        icon_pass_Offset_Center.constant = 2.0f;
        icon_conf_Offset_Center.constant = -2.0f;
        
        txt_height.constant = 30.0f;
        txt_left_padding.constant = 37.0f;
        txt_email_bottom_padding.constant = 1.0f;
        txt_pass_bottom_padding.constant = 1.0f;
        
        checkicon_Width.constant = 19.0f;
        checkBtn_Width.constant = 50.0f;
        
        btnJoinTopPadding.constant = 33.0f;
        btnJoinHeight.constant = 43.0f;
        
        tosTopPadding.constant = 15.0f;
        
        lbl_Copyright_Height.constant = 50.0f;
    }
    
    // Set Copyright
    
    if (gDeviceType == DEVICE_IPHONE_47INCH
        || gDeviceType == DEVICE_IPHONE_55INCH)
    {
        [lbl_copyRight setFont:FONT_LIGHT(11)];
    }
    else
    {
        [lbl_copyRight setFont:FONT_LIGHT(10)];
    }
    
    
    [lbl_copyRight setTextColor:[UIColor whiteColor]];
    
    DLog(@"%@", NSStringFromCGSize(CGSizeMake(design_panel.frame.size.width, design_panel.frame.size.height)));
    
    [scrollView setContentSize:CGSizeMake(design_panel.frame.size.width, design_panel.frame.size.height)];
    
    // Init Status ImageView and Join Button
    
    // Init Join Button
    
    [btn_join setBackgroundColor:RED_COLOR];
    [btn_join.layer setCornerRadius:8.f];
    
    if (gDeviceType == DEVICE_IPHONE_35INCH
        || gDeviceType == DEVICE_IPHONE_40INCH)
    {
        [btn_join.titleLabel setFont:FONT_REGULAR(20)];
    }
    else
    {
        [btn_join.titleLabel setFont:FONT_REGULAR(22)];
    }
    [self updateCatImageandJoin:NO];
    
    [design_panel setBackgroundColor:[UIColor clearColor]];
    [design_panel setAlpha:1.0];
    
    // Init Underlines
    
    [lineView_email setBackgroundColor:GRAY_COLOR];
    [lineView_password setBackgroundColor:GRAY_COLOR];
    [lineView_conf_password setBackgroundColor:GRAY_COLOR];
    
    // Init Input Fields's icons
    
    [icon_email setImage:[UIImage imageNamed:EMAIL_GRAY]];
    [icon_password setImage:[UIImage imageNamed:PASS_GRAY]];
    [icon_conf_password setImage:[UIImage imageNamed:CONF_PASS_GRAY]];
    
    // Init Check Fields' Icons
    
    [check_icon_email setImage:Nil];
    [check_icon_password setImage:Nil];
    [check_icon_conf_password setImage:Nil];
    [lbl_conf_notification setTextColor:[UIColor clearColor]];
    [lbl_conf_notification setText:@""];
    
    
    // Init UITextFields
    
    if (gDeviceType == DEVICE_IPHONE_47INCH
        || gDeviceType == DEVICE_IPHONE_55INCH)
    {
        maxFontSize = 18;
        dotFontSize = 21.0f;
        tosFontSize = 15.0f;
        notificationFontSize = 11.0f;
    }
    else
    {
        maxFontSize = 17;
        dotFontSize = 21.0f;
        tosFontSize = 13.0f;
        notificationFontSize = 10.0f;
    }
    
    [txt_email setFont:FONT_LIGHT(maxFontSize)];
    [txt_password setFont:FONT_LIGHT(maxFontSize)];
    [txt_conf_password setFont:FONT_LIGHT(maxFontSize)];
    
    txt_email.autocorrectionType = UITextAutocorrectionTypeNo;
    txt_password.autocorrectionType = UITextAutocorrectionTypeNo;
    txt_conf_password.autocorrectionType = UITextAutocorrectionTypeNo;
    
    txt_password.adjustsFontSizeToFitWidth = NO;
    txt_conf_password.adjustsFontSizeToFitWidth = NO;
    
    [txt_email addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    
    [txt_password addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    
    [txt_conf_password addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    
    passPlaceholderStr =
    [[NSAttributedString alloc] initWithString:@"New Password"
                                    attributes:@{ NSForegroundColorAttributeName : GRAY_COLOR,
                                                  NSFontAttributeName : FONT_LIGHT(maxFontSize)}];
    
    confirmStr =
    [[NSAttributedString alloc] initWithString:@"Confirm Password"
                                    attributes:@{ NSForegroundColorAttributeName : GRAY_COLOR,
                                                  NSFontAttributeName : FONT_LIGHT(maxFontSize)}];
    
    txt_password.attributedPlaceholder = passPlaceholderStr;
    txt_conf_password.attributedPlaceholder = confirmStr;
    
    // Hide clear buttons
    
    [btn_clear_email setHidden:YES];
    [btn_clear_password setHidden:YES];
    [btn_clear_conf setHidden:YES];
    
    [btn_edit_password setHidden:YES];
    [btn_edit_conf setHidden:YES];
    
    // Init Observer Flags
    
    validEmail = NO;
    validPhone = NO;
    validPassword = NO;
    validConfirmPassword = NO;
    
    isEditMode_Password = NO;
    isEditMode_ConfPassword = NO;
    
    // Init Terms and Service Label
    
    NSString* prefixStr = @"By signing up, you agree to Fae's ";
    NSString* andStr = @" and ";
    
    NSDictionary *bold_attributes = @{NSFontAttributeName:FONT_SEMIBOLD(tosFontSize),
                                      NSForegroundColorAttributeName:RED_COLOR
                                      };
    
    NSDictionary *thin_attributes = @{NSFontAttributeName:FONT_LIGHT(tosFontSize),
                                      NSForegroundColorAttributeName:RED_COLOR
                                      };
    
    NSMutableAttributedString *attributedTos =
            [[NSMutableAttributedString alloc] initWithString:prefixStr
                                                   attributes:thin_attributes];
    
    NSMutableAttributedString *attributedKeyword1 =
    [[NSMutableAttributedString alloc] initWithString:TOS_Keyword1
                                           attributes:bold_attributes];
    
    NSMutableAttributedString *attributedKeyword2 =
    [[NSMutableAttributedString alloc] initWithString:TOS_Keyword2
                                           attributes:bold_attributes];
    
    NSMutableAttributedString *attributedAndstr =
    [[NSMutableAttributedString alloc] initWithString:andStr
                                           attributes:thin_attributes];
    
    
    [attributedKeyword1 addAttribute:NSLinkAttributeName
                               value:TOS_Keyword1_link
                               range:NSMakeRange(0, TOS_Keyword1.length)];
    
    [attributedKeyword2 addAttribute:NSLinkAttributeName
                               value:TOS_Keyword2_link
                               range:NSMakeRange(0, TOS_Keyword2.length)];
    
    
    [attributedTos appendAttributedString:attributedKeyword1];
    [attributedTos appendAttributedString:attributedAndstr];
    [attributedTos appendAttributedString:attributedKeyword2];
    
    NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    
    [attributedTos addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedTos.string.length)];
    
    [textview_terms setScrollEnabled:NO];
    [textview_terms setAttributedText:attributedTos];
    
    textview_terms.linkTextAttributes = @{NSForegroundColorAttributeName : RED_COLOR};
    
    [textview_terms setBackgroundColor:[UIColor clearColor]];
    
    textview_terms.selectable = YES;
    textview_terms.dataDetectorTypes = UIDataDetectorTypeAll;
    [textview_terms setEditable:NO];
    textview_terms.delegate = self;
    
    [lbl_email_notification setFont:FONT_REGULAR(notificationFontSize)];
    
    [lbl_password_notification setFont:FONT_REGULAR(notificationFontSize)];
    
    [lbl_conf_notification setFont:FONT_REGULAR(notificationFontSize)];
    
    
}

// - Update UI Control's color and status
- (void)updateUIStatus:(UITextField* )textField DynamicalCheck:(BOOL)isDynamic
{
    BOOL includeUppercase = NO;
    BOOL includeSpeicalChar = NO;
    BOOL includePunctuation = NO;
    BOOL includeNumber = NO;
    
    NSInteger twoFactorCheckSum = 0;
    
    // Check Email field
    if ([textField isEqual:txt_email])
    {
        [txt_email setFont:FONT_LIGHT(maxFontSize)];
        [lbl_email_notification setText:@""];
        
        if (textField.text.length == 0
            || textField.text == Nil
            || [textField.text isEqualToString:@""])
        {
            // No process
            
            [icon_email setImage:[UIImage imageNamed:EMAIL_RED]];
            [lineView_email setBackgroundColor:RED_COLOR];
            
            [check_icon_email setImage:Nil];
            [btn_clear_email setHidden:YES];
            [lbl_email_notification setText:@""];
        }
        else
        {
            [icon_email setImage:[UIImage imageNamed:EMAIL_RED]];
            [lineView_email setBackgroundColor:RED_COLOR];
            
            if ([[FaeAppDelegate sharedDelegate] isValidEmail:textField.text])
            {
                [check_icon_email setImage:[UIImage imageNamed:CHECK_YES]];
                validEmail = YES;
                [btn_clear_email setHidden:YES];
            }
            else
            {
                [check_icon_email setImage:[UIImage imageNamed:CHECK_CROSS_RED]];
                validEmail = NO;
                [btn_clear_email setHidden:NO];
            }
        }
    }   // Check Phone field
    else if ([textField isEqual:txt_password])
    {
        DLog(@"%@", textField.text);
        
        if (textField.text.length == 0)
        {
            [txt_password setFont:FONT_LIGHT(maxFontSize)];
            
            [textField setTintColor:RED_COLOR];
            [textField setTextColor:RED_COLOR];
            
            [icon_password setImage:[UIImage imageNamed:PASS_RED]];
            [lineView_password setBackgroundColor:RED_COLOR];
            
            [check_icon_password setImage:Nil];
            validPassword = NO;
            [btn_clear_password setHidden:YES];
            [btn_edit_password setHidden:YES];
            
            [lbl_password_notification setTextColor:RED_COLOR];
            [lbl_password_notification setText:@"Must be at least 8 characters"];
            
            
        }
        else
        {
            if (isEditMode_Password == NO)
            {
                [txt_password setFont:FONT_DOT(dotFontSize)];
            }
            else
            {
                [txt_password setFont:FONT_LIGHT(maxFontSize)];
            }
            
            if (textField.text.length < 8)
            {
                [textField setTintColor:YELLOW_COLOR];
                [textField setTextColor:YELLOW_COLOR];
                
                [icon_password setImage:[UIImage imageNamed:PASS_YELLOW]];
                
                if (isEditMode_Password)
                {
                    [check_icon_password setImage:[UIImage imageNamed:CHECK_EYE_OPEN_YELLOW]];
                    
                    [btn_clear_password setHidden:YES];
                    [btn_edit_password setHidden:NO];
                }
                else
                {
                    if (isDynamic)
                    {
                        [check_icon_password setImage:[UIImage imageNamed:CHECK_EYE_CLOSE_YELLOW]];
                        
                        [btn_clear_password setHidden:YES];
                        [btn_edit_password setHidden:NO];
                    }
                    else
                    {
                        [check_icon_password setImage:[UIImage imageNamed:CHECK_CROSS_YELLOW]];
                        
                        [btn_clear_password setHidden:NO];
                        [btn_edit_password setHidden:YES];
                        
                    }
                }
                
                [lineView_password setBackgroundColor:YELLOW_COLOR];
                validPassword = NO;
                
                [lbl_password_notification setTextColor:YELLOW_COLOR];
                [lbl_password_notification setText:@"Password need to be at least 8 characters long!"];
                
            }
            else if (textField.text.length >=8)
            {
                [textField setTintColor:ORANGE_COLOR];
                [textField setTextColor:ORANGE_COLOR];
                
                [icon_password setImage:[UIImage imageNamed:PASS_ORANGE]];
                
                if (isEditMode_Password)
                {
                    [check_icon_password setImage:[UIImage imageNamed:CHECK_EYE_OPEN_ORANGE]];
                    
                    [btn_clear_password setHidden:YES];
                    [btn_edit_password setHidden:NO];
                }
                else
                {
                    if (isDynamic)
                    {
                        [check_icon_password setImage:[UIImage imageNamed:CHECK_EYE_CLOSE_ORANGE]];
                        
                        [btn_clear_password setHidden:YES];
                        [btn_edit_password setHidden:NO];
                    }
                    else
                    {
                        [check_icon_password setImage:[UIImage imageNamed:CHECK_CROSS_ORANGE]];
                        
                        [btn_clear_password setHidden:NO];
                        [btn_edit_password setHidden:YES];
                    }
                    
                }
                
                [lineView_password setBackgroundColor:ORANGE_COLOR];
                validPassword = NO;
                
                [lbl_password_notification setTextColor:ORANGE_COLOR];
                
                // find the Upper case string
                
                NSString *passwordStr = txt_password.text;
                
                // Check if there is any UPPER case string
                for (int i = 0; i < [passwordStr length]; i++)
                {
                    includeUppercase = [[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:[passwordStr characterAtIndex:i]];
                    
                    if (includeUppercase)
                        break;
                }
                
                // Check if there is any symbols string
                for (int i = 0; i < [passwordStr length]; i++)
                {
                    includeSpeicalChar = [[NSCharacterSet symbolCharacterSet] characterIsMember:[passwordStr characterAtIndex:i]];
                    
                    if (includeSpeicalChar)
                        break;
                }
                
                // Check if there is any punctuation string
                for (int i = 0; i < [passwordStr length]; i++)
                {
                    includePunctuation = [[NSCharacterSet punctuationCharacterSet] characterIsMember:[passwordStr characterAtIndex:i]];
                    
                    if (includePunctuation)
                        break;
                }
                
                // Check if there is any number in the string
                
                NSCharacterSet *numberCharset = [NSCharacterSet characterSetWithCharactersInString:@"1234567890"];
                
                for (int i = 0; i < [passwordStr length]; i++)
                {
                    includeNumber = [numberCharset characterIsMember:[passwordStr characterAtIndex:i]];
                    
                    if (includeNumber)
                        break;
                }
                
                twoFactorCheckSum = (NSInteger)includeUppercase +
                (NSInteger)(includeSpeicalChar || includePunctuation) +
                (NSInteger)includeNumber;
                
                if (twoFactorCheckSum == 0)
                {
                    [txt_password setTintColor:ORANGE_COLOR];
                    [txt_password setTextColor:ORANGE_COLOR];
                    [icon_password setImage:[UIImage imageNamed:PASS_ORANGE]];
                    [lineView_password setBackgroundColor:ORANGE_COLOR];
                    
                    if (isEditMode_Password)
                    {
                        [check_icon_password setImage:[UIImage imageNamed:CHECK_EYE_OPEN_ORANGE]];
                        
                        [btn_clear_password setHidden:YES];
                        [btn_edit_password setHidden:NO];
                    }
                    else
                    {
                        if (isDynamic)
                        {
                            [check_icon_password setImage:[UIImage imageNamed:CHECK_EYE_CLOSE_ORANGE]];
                            
                            [btn_clear_password setHidden:YES];
                            [btn_edit_password setHidden:NO];
                        }
                        else
                        {
                            [check_icon_password setImage:[UIImage imageNamed:CHECK_EXCLAMATION_ORANGE]];
                            
                            [btn_clear_password setHidden:YES];
                            [btn_edit_password setHidden:YES];
                        }
                    }
                    
                    validPassword = YES;
                    
                    [lbl_password_notification setTextColor:ORANGE_COLOR];
                    
                    [lbl_password_notification setText:@"Add capital letters/numbers/symbols to strengthen your password!"];
                }
                else if (twoFactorCheckSum < 2)
                {
                    [txt_password setTintColor:ORANGE_COLOR];
                    [txt_password setTextColor:ORANGE_COLOR];
                    
                    [icon_password setImage:[UIImage imageNamed:PASS_ORANGE]];
                    [lineView_password setBackgroundColor:ORANGE_COLOR];
                    
                    if (isEditMode_Password)
                    {
                        [check_icon_password setImage:[UIImage imageNamed:CHECK_EYE_OPEN_ORANGE]];
                        
                        [btn_clear_password setHidden:YES];
                        [btn_edit_password setHidden:NO];
                    }
                    else
                    {
                        if (isDynamic)
                        {
                            [check_icon_password setImage:[UIImage imageNamed:CHECK_EYE_CLOSE_ORANGE]];
                            
                            [btn_clear_password setHidden:YES];
                            [btn_edit_password setHidden:NO];
                        }
                        else
                        {
                            [check_icon_password setImage:[UIImage imageNamed:CHECK_EXCLAMATION_ORANGE]];
                            
                            [btn_clear_password setHidden:YES];
                            [btn_edit_password setHidden:YES];
                        }
                    }
                    
                    validPassword = YES;
                    
                    [lbl_password_notification setTextColor:ORANGE_COLOR];
                    [lbl_password_notification setText:@"Add capital letters/numbers/symbols to strengthen your password!"];
                }
                else if (twoFactorCheckSum >= 2)
                {
                    [txt_password setTintColor:RED_COLOR];
                    [txt_password setTextColor:RED_COLOR];
                    
                    [icon_password setImage:[UIImage imageNamed:PASS_RED]];
                    [lineView_password setBackgroundColor:RED_COLOR];
                    [lbl_password_notification setTextColor:RED_COLOR];
                    
                    if (isEditMode_Password)
                    {
                        [check_icon_password setImage:[UIImage imageNamed:CHECK_EYE_OPEN_RED]];
                        
                        [btn_clear_password setHidden:YES];
                        [btn_edit_password setHidden:NO];
                    }
                    else
                    {
                        if (isDynamic)
                        {
                            [check_icon_password setImage:[UIImage imageNamed:CHECK_EYE_CLOSE_RED]];
                            
                            [btn_clear_password setHidden:YES];
                            [btn_edit_password setHidden:NO];
                        }
                        else
                        {
                            [txt_password setTintColor:RED_COLOR];
                            [txt_password setTextColor:RED_COLOR];
                            [icon_password setImage:[UIImage imageNamed:PASS_RED]];
                            [lineView_password setBackgroundColor:RED_COLOR];
                            [lbl_password_notification setTextColor:RED_COLOR];
                            
                            [check_icon_password setImage:[UIImage imageNamed:CHECK_YES]];
                            
                            [btn_clear_password setHidden:YES];
                            [btn_edit_password setHidden:YES];
                        }
                    }
                    
                    validPassword = YES;
                    
                    [lbl_password_notification setText:@"Your Password is Strong!"];
                }
            }
        }
        
    }   // Check Confirm Password field
    else if ([textField isEqual:txt_conf_password])
    {
        [txt_conf_password setTintColor:RED_COLOR];
        [txt_conf_password setTextColor:RED_COLOR];
        
        if (textField.text.length == 0
            || textField.text == Nil
            || [textField.text isEqualToString:@""])
        {
            [txt_conf_password setFont:FONT_LIGHT(maxFontSize)];
            
            [icon_conf_password setImage:[UIImage imageNamed:CONF_PASS_RED]];
            [lineView_conf_password setBackgroundColor:RED_COLOR];
            
            [check_icon_conf_password setImage:Nil];

            [btn_clear_conf setHidden:YES];
            [btn_edit_conf setHidden:YES];
            
            [lbl_conf_notification setTextColor:[UIColor clearColor]];
            [lbl_conf_notification setText:@""];
        }
        else
        {
            if (isEditMode_ConfPassword == NO)
            {
                [txt_conf_password setFont:FONT_DOT(dotFontSize)];
            }
            else
            {
                [txt_conf_password setFont:FONT_LIGHT(maxFontSize)];
            }
            
            [icon_conf_password setImage:[UIImage imageNamed:CONF_PASS_RED]];
            [lineView_conf_password setBackgroundColor:RED_COLOR];
            
            if (txt_password.text.length > 0
                && txt_conf_password.text.length > 0)
            {
                if ([txt_conf_password.text isEqualToString:txt_password.text])
                {
                    validConfirmPassword = YES;
                    
                    [lbl_conf_notification setTextColor:[UIColor clearColor]];
                    [lbl_conf_notification setText:@""];
                    
                    if (isEditMode_ConfPassword)
                    {
                        [check_icon_conf_password setImage:[UIImage imageNamed:CHECK_EYE_OPEN_RED]];
                        
                        [btn_edit_conf setHidden:NO];
                        [btn_clear_conf setHidden:YES];
                    }
                    else
                    {
                        if (isDynamic)
                        {
                            [check_icon_conf_password setImage:[UIImage imageNamed:CHECK_EYE_CLOSE_RED]];
                            
                            [btn_edit_conf setHidden:NO];
                            [btn_clear_conf setHidden:YES];
                        }
                        else
                        {
                            [check_icon_conf_password setImage:[UIImage imageNamed:CHECK_YES]];
                            
                            [btn_edit_conf setHidden:YES];
                            [btn_clear_conf setHidden:YES];
                        }
                    }
                }
                else
                {
                    validConfirmPassword = NO;
                    
                    [lbl_conf_notification setTextColor:RED_COLOR];
                    [lbl_conf_notification setText:@"Your Passwords don't match!"];
                    
                    if (isEditMode_ConfPassword)
                    {
                        [check_icon_conf_password setImage:[UIImage imageNamed:CHECK_EYE_OPEN_RED]];
                        
                        [btn_edit_conf setHidden:NO];
                        [btn_clear_conf setHidden:YES];
                    }
                    else
                    {
                        if (isDynamic)
                        {
                            [check_icon_conf_password setImage:[UIImage imageNamed:CHECK_EYE_CLOSE_RED]];
                            
                            [btn_edit_conf setHidden:NO];
                            [btn_clear_conf setHidden:YES];
                        }
                        else
                        {
                            [check_icon_conf_password setImage:[UIImage imageNamed:CHECK_CROSS_RED]];
                            
                            [btn_edit_conf setHidden:YES];
                            [btn_clear_conf setHidden:NO];
                        }
                    }
                }
            }
            else if (txt_conf_password.text.length == 0)
            {
                [check_icon_conf_password setImage:Nil];
                
                [lbl_conf_notification setTextColor:[UIColor clearColor]];
                [lbl_conf_notification setText:@""];
                
                [btn_clear_conf setHidden:YES];
                [btn_edit_conf setHidden:YES];
                
                txt_conf_password.attributedPlaceholder = confirmStr;
            }
            else
            {
                validConfirmPassword = NO;
                
                [lbl_conf_notification setTextColor:RED_COLOR];
                [lbl_conf_notification setText:@"Your passwords don't match!"];
                
                if (isEditMode_ConfPassword)
                {
                    [check_icon_conf_password setImage:[UIImage imageNamed:CHECK_EYE_OPEN_RED]];
                    
                    [btn_edit_conf setHidden:NO];
                    [btn_clear_conf setHidden:YES];
                }
                else
                {
                    if (isDynamic)
                    {
                        [check_icon_conf_password setImage:[UIImage imageNamed:CHECK_EYE_CLOSE_RED]];
                        
                        [btn_edit_conf setHidden:NO];
                        [btn_clear_conf setHidden:YES];
                    }
                    else
                    {
                        [check_icon_conf_password setImage:[UIImage imageNamed:CHECK_CROSS_RED]];
                        
                        [btn_edit_conf setHidden:YES];
                        [btn_clear_conf setHidden:NO];
                    }
                }
            }
        }
    }
    
    if (txt_password.text.length > 0
        && txt_conf_password.text.length > 0)
    {
        if ([txt_conf_password.text isEqualToString:txt_password.text])
        {
            if (txt_password.text.length < 8)
            {
                [self updateCatImageandJoin:NO];
            }
            else
            {
                if ([[FaeAppDelegate sharedDelegate] isValidEmail:txt_email.text])
                {
                    [self updateCatImageandJoin:YES];
                }
                else
                {
                    [self updateCatImageandJoin:NO];
                }
            }
        }
        else
        {
            [self updateCatImageandJoin:NO];
        }
    }
    else
    {
        [self updateCatImageandJoin:NO];
    }
}

// - Register Signup Email to check duplication

- (BOOL)registerEmail:(NSString* )userEmail
{
    BOOL retVal = YES;
    
    NSUserDefaults* userdefault = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray* emailArray = [[NSMutableArray alloc] init];
    
    if ([userdefault objectForKey:kFAEREGISTERED_EMAILS])
    {
        emailArray = [[userdefault objectForKey:kFAEREGISTERED_EMAILS] mutableCopy];
        
        if ([emailArray containsObject:userEmail.lowercaseString])
        {
            retVal = NO;
        }
        else
        {
            [emailArray addObject:userEmail.lowercaseString];
            
            [userdefault setObject:emailArray forKey:kFAEREGISTERED_EMAILS];
            
            [userdefault synchronize];
        }
    }
    else
    {
        [emailArray addObject:userEmail];
        
        [userdefault setObject:emailArray forKey:kFAEREGISTERED_EMAILS];
        
        [userdefault synchronize];
    }
    
    return retVal;
}

- (void)updateCatImageandJoin:(BOOL)flag
{
    if (flag)
    {
        [image_status setImage:[UIImage imageNamed:SMILE_CAT]];
        [btn_join setBackgroundColor:RED_COLOR];
    }
    else
    {
        [image_status setImage:[UIImage imageNamed:NORMAL_CAT]];
        [btn_join setBackgroundColor:RED_COLOR_WITHOPACITY];
    }
    
    [btn_join setUserInteractionEnabled:flag];
}

#pragma mark - IBActions

// Back to preview window
- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

// Join process
- (IBAction)onJoin:(id)sender
{
    // Check the passwords
    
    if (txt_password.text.length > 0
        && txt_conf_password.text.length > 0)
    {
        if ([txt_conf_password.text isEqualToString:txt_password.text])
        {
            // Check Password Length
            if (txt_password.text.length < 8)
            {
                return;
            }
            else
            {
                if ([[FaeAppDelegate sharedDelegate] isValidEmail:txt_email.text])
                {
                    if (validPassword && validConfirmPassword)
                    {
                        // Simulation Progress bar to show the signing progress
                        
                        [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
                        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                        
                        double delayInSeconds = 2.0;
                        
                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                            
                            [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
                            
                            [self updateCatImageandJoin:NO];
                            
                            [icon_password setImage:[UIImage imageNamed:PASS_GRAY]];
                            [lineView_password setBackgroundColor:GRAY_COLOR];
                            [txt_password setText:@""];
                            [check_icon_password setImage:Nil];
                            [lbl_password_notification setText:@""];
                            [btn_clear_password setHidden:YES];
                            [btn_edit_password setHidden:YES];
                            
                            [icon_conf_password setImage:[UIImage imageNamed:CONF_PASS_GRAY]];
                            [lineView_conf_password setBackgroundColor:GRAY_COLOR];
                            [txt_conf_password setText:@""];
                            [check_icon_conf_password setImage:Nil];
                            [lbl_conf_notification setText:@""];
                            [btn_clear_conf setHidden:YES];
                            
                            txt_conf_password.attributedPlaceholder = confirmStr;
                            
                            if ([self registerEmail:txt_email.text])
                            {
                                [icon_email setImage:[UIImage imageNamed:EMAIL_GRAY]];
                                [lineView_email setBackgroundColor:GRAY_COLOR];
                                [txt_email setText:@""];
                                [check_icon_email setImage:Nil];
                                [lbl_email_notification setText:@""];
                                [btn_clear_email setHidden:YES];
                                
                                validEmail = NO;
                                validPhone = NO;
                                validPassword = NO;
                                validConfirmPassword = NO;
                                
                                [self.view endEditing:YES];
                                
                                FaeMyCardVC* myCardVC = [[FaeMyCardVC alloc] initWithNibName:@"FaeMyCardVC" bundle:Nil];
                                
                                [self.navigationController pushViewController:myCardVC animated:YES];
                            }
                            else
                            {
                                [check_icon_email setImage:[UIImage imageNamed:CHECK_EXCLAMATION_RED]];
                                [lbl_email_notification setTextColor:RED_COLOR];
                                [lbl_email_notification setText:@"This email is registered! Log in!"];
                                [btn_clear_email setHidden:YES];
                            }
                            
                        });
                    }
                    else
                    {
                        [[FaeAppDelegate sharedDelegate] AutoHiddenAlert:kApplicationName
                                                          messageContent:@"Please confirm passwords"];
                    }
                }
                else
                {
                    [[FaeAppDelegate sharedDelegate] AutoHiddenAlert:kApplicationName
                                                     messageContent:@"Please use the valid email address."];
                }
            }
        }
        else
        {
            [check_icon_conf_password setImage:Nil];
            [lbl_conf_notification setTextColor:[UIColor clearColor]];
            [lbl_conf_notification setText:@""];
            [btn_clear_conf setHidden:YES];
            
            txt_conf_password.text = @"";
            
            txt_conf_password.attributedPlaceholder = confirmStr;
        }
    }
}

// Clear input fileds according to the Check Icons' status

- (IBAction)onClear:(id)sender
{
    UIButton* selectedBtn = (UIButton* )sender;
    NSInteger tag = selectedBtn.tag;
    UITextField* focusTextField = Nil;
    
    if (tag == 1000)
    {
        focusTextField = txt_email;
        
        [check_icon_email setImage:Nil];
        [btn_clear_email setHidden:YES];
    }
    else if (tag == 1002)
    {
        focusTextField = txt_password;
        
        [check_icon_password setImage:Nil];
        [btn_clear_password setHidden:YES];
    }
    else if (tag == 1003)
    {
        focusTextField = txt_conf_password;
        
        [check_icon_conf_password setImage:Nil];
        [btn_clear_conf setHidden:YES];
    }
    
    focusTextField.text = @"";
    
    [self updateUIStatus:focusTextField DynamicalCheck:NO];
}

- (IBAction)onEditPassword:(id)sender
{
    UIButton* selectedBtn = (UIButton* )sender;
    NSInteger tag = selectedBtn.tag;
    UITextField* focusTextField = Nil;
    
    if (tag == 2002)
    {
        focusTextField = txt_password;
        
        if (isEditMode_Password)
        {
            [txt_password setFont:FONT_DOT(dotFontSize)];
            
            [txt_password setSecureTextEntry:YES];
        }
        else
        {
            NSString* password = txt_password.text;
            
            [txt_password resignFirstResponder];
            
            [txt_password setSecureTextEntry:NO];
            
            [txt_password setText:password];
            
            [txt_password becomeFirstResponder];
            
            [txt_password setFont:FONT_LIGHT(maxFontSize)];
        }
        
        isEditMode_Password = !isEditMode_Password;
        
        [self updateUIStatus:txt_password DynamicalCheck:YES];
        
        [btn_clear_password setHidden:YES];
        [btn_edit_password setHidden:NO];
    }
    else if (tag == 2003)
    {
        focusTextField = txt_conf_password;
     
        if (isEditMode_ConfPassword)
        {
            [txt_conf_password setFont:FONT_DOT(dotFontSize)];
            
            [txt_conf_password setSecureTextEntry:YES];
        }
        else
        {
            NSString* password = txt_conf_password.text;
            
            [txt_conf_password resignFirstResponder];
            
            [txt_conf_password setSecureTextEntry:NO];
            
            [txt_conf_password setText:password];
            
            [txt_conf_password becomeFirstResponder];
            
            [txt_conf_password setFont:FONT_LIGHT(maxFontSize)];
        }
        
        if (isEditMode_ConfPassword)
        {
            [check_icon_conf_password setImage:[UIImage imageNamed:CHECK_EYE_CLOSE_RED]];
        }
        else
        {
            [check_icon_conf_password setImage:[UIImage imageNamed:CHECK_EYE_OPEN_RED]];
        }
        
        isEditMode_ConfPassword = !isEditMode_ConfPassword;
        
        [btn_clear_conf setHidden:YES];
        [btn_edit_conf setHidden:NO];
    }
}
#pragma mark - UITextField Delegates

// Check the textfield whenever change event is occured

-(void)textFieldDidChange :(UITextField *)textField
{
    [self updateUIStatus:textField DynamicalCheck:YES];
}

// If the textField get the focus, then update the UI controls

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [textField setTintColor:RED_COLOR];
    [textField setTextColor:RED_COLOR];
    
    [txt_email layoutIfNeeded];
    [txt_password layoutIfNeeded];
    [txt_conf_password layoutIfNeeded];
    
    [self updateUIStatus:textField DynamicalCheck:YES];
    
    if ([textField isEqual:txt_email])
    {
        [txt_email setFont:FONT_LIGHT(maxFontSize)];
        
        [icon_email setImage:[UIImage imageNamed:EMAIL_RED]];
        [lineView_email setBackgroundColor:RED_COLOR];
    }
    else if ([textField isEqual:txt_password])
    {
        if (textField.text.length == 0)
        {
            [txt_password setFont:FONT_LIGHT(maxFontSize)];
            
            txt_password.attributedPlaceholder = passPlaceholderStr;
        }
        else
        {
            if (isEditMode_Password == NO)
            {
                [txt_password setFont:FONT_DOT(dotFontSize)];
            }
            else
            {
                [txt_password setFont:FONT_LIGHT(maxFontSize)];
            }
        }
    }
    else if ([textField isEqual:txt_conf_password])
    {
        if (textField.text.length == 0)
        {
            [txt_conf_password setFont:FONT_LIGHT(maxFontSize)];
            
            txt_conf_password.attributedPlaceholder = confirmStr;
        }
        else
        {
            if (isEditMode_ConfPassword == NO)
            {
                [txt_conf_password setFont:FONT_DOT(dotFontSize)];
            }
            else
            {
                [txt_conf_password setFont:FONT_LIGHT(maxFontSize)];
            }
        }
        
    }
}

// If the textField drop the focus, then update the UI controls

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [txt_email layoutIfNeeded];
    [txt_password layoutIfNeeded];
    [txt_conf_password layoutIfNeeded];
    
    if ([textField isEqual:txt_email])
    {
        [txt_email setFont:FONT_LIGHT(maxFontSize)];
        
        [self updateUIStatus:textField DynamicalCheck:NO];
        
        if (textField.text.length == 0
            || textField.text == Nil
            || [textField.text isEqualToString:@""])
        {
            [icon_email setImage:[UIImage imageNamed:EMAIL_GRAY]];
            [lineView_email setBackgroundColor:GRAY_COLOR];
        }
        else
        {
            
        }
    }
    else if ([textField isEqual:txt_password])
    {
        isEditMode_Password = NO;
        
        [self updateUIStatus:textField DynamicalCheck:NO];
        
        if (textField.text.length == 0
            || textField.text == Nil
            || [textField.text isEqualToString:@""])
        {
            txt_password.attributedPlaceholder = passPlaceholderStr;
            
            [icon_password setImage:[UIImage imageNamed:PASS_GRAY]];
            [lineView_password setBackgroundColor:GRAY_COLOR];
            lbl_password_notification.text = @"";
        }
        else
        {
            [txt_password setFont:FONT_DOT(dotFontSize)];
            
        }
        
        [btn_edit_password setHidden:YES];
        
        [txt_password setSecureTextEntry:YES];
        
    }
    else if ([textField isEqual:txt_conf_password])
    {
        isEditMode_ConfPassword = NO;
        
        [self updateUIStatus:textField DynamicalCheck:NO];
       
        if (textField.text.length == 0
            || textField.text == Nil
            || [textField.text isEqualToString:@""])
        {
            txt_conf_password.attributedPlaceholder = confirmStr;
            
            [icon_conf_password setImage:[UIImage imageNamed:CONF_PASS_GRAY]];
            [lineView_conf_password setBackgroundColor:GRAY_COLOR];
            lbl_conf_notification.text = @"";
        }
        else
        {
            [txt_conf_password setFont:FONT_DOT(dotFontSize)];
            
            [icon_conf_password setImage:[UIImage imageNamed:CONF_PASS_RED]];
            [lineView_conf_password setBackgroundColor:RED_COLOR];
        }
        
        [btn_edit_conf setHidden:YES];
        
        [txt_conf_password setSecureTextEntry:YES];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField isEqual:txt_password])
    {
        if (textField.isSecureTextEntry == NO)
        {
            [txt_password setFont:FONT_LIGHT(maxFontSize)];
            
            return YES;
        }
        else
        {
            if (textField.text.length == 0)
            {
                [txt_password setFont:FONT_DOT(dotFontSize)];
                txt_password.attributedPlaceholder = passPlaceholderStr;
            }
            
            [textField setSecureTextEntry:NO];
            
            NSString *updatedString = [textField.text stringByReplacingCharactersInRange:range withString:string];
            
            textField.text = updatedString;
            
            [textField setSecureTextEntry:YES];
            
            [self updateUIStatus:txt_password DynamicalCheck:YES];
            
            return NO;
        }
        
    }
    else if ([textField isEqual:txt_conf_password])
    {
        if (textField.isSecureTextEntry == NO)
        {
            [txt_conf_password setFont:FONT_LIGHT(maxFontSize)];
            
            return YES;
        }
        else
        {
            if (textField.text.length == 0)
            {
                [txt_conf_password setFont:FONT_DOT(dotFontSize)];
                txt_conf_password.attributedPlaceholder = confirmStr;
            }
            
            [textField setSecureTextEntry:NO];
            
            NSString *updatedString = [textField.text stringByReplacingCharactersInRange:range withString:string];
            
            textField.text = updatedString;
            
            [textField setSecureTextEntry:YES];
            
            [self updateUIStatus:txt_conf_password DynamicalCheck:YES];
            
            return NO;
        }
    }
    else
    {
        [txt_email setFont:FONT_LIGHT(maxFontSize)];
    }
    return YES;
}

// Keyboard update accoording to the Return button

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length > 0)
    {
        if ([textField isEqual:txt_email])
        {
            [txt_password becomeFirstResponder];
        }
        else if ([textField isEqual:txt_password])
        {
            if (textField.text.length == 0)
            {
                txt_password.attributedPlaceholder = passPlaceholderStr;
            }
            
            [txt_conf_password becomeFirstResponder];
        }
        else if ([textField isEqual:txt_conf_password])
        {
            if (textField.text.length == 0)
            {
                txt_conf_password.attributedPlaceholder = confirmStr;
            }
            [textField resignFirstResponder];
            // Join Function ???
        }
        
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark - CCHLinkAttributeName Delegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    NSString* openPath = [URL absoluteString];
    
    DLog(@"%@", openPath);
    
    if ([openPath isEqualToString:TOS_Keyword1_link])
    {
        [[FaeAppDelegate sharedDelegate] ShowAlert:kApplicationName
                                    messageContent:@"Terms of Service"];
    }
    else if ([openPath isEqualToString:TOS_Keyword2_link])
    {
        [[FaeAppDelegate sharedDelegate] ShowAlert:kApplicationName
                                    messageContent:@"Privacy Policy"];
    }
    
    if ([[UIApplication sharedApplication] canOpenURL:URL])
    {
        [[UIApplication sharedApplication] openURL:URL];
    }
    
    return NO;
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)src_scrollView
{
    src_scrollView.contentOffset = CGPointMake(src_scrollView.contentOffset.x, 0);
}

@end
