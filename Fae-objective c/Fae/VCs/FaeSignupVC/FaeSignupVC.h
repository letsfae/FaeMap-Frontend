//
//  FaeSignupVC.h
//  Fae
//
//  Created by Liu on 2/25/16.
//  Copyright (c) 2016 Aorinix Technologies Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "Constant.h"
#import "SHSPhoneLibrary.h"

@class TPKeyboardAvoidingScrollView;

@interface FaeSignupVC : UIViewController<MBProgressHUDDelegate, UITextFieldDelegate, UITextViewDelegate>
{
    
    IBOutlet UILabel*       lbl_copyRight;
    IBOutlet UIImageView*   image_status;

    IBOutlet TPKeyboardAvoidingScrollView *scrollView;
    
    // Signup Container
    IBOutlet UIView*        design_panel;
    
    // NSConstraints for AutoLayouts
    
    IBOutlet NSLayoutConstraint*    inputPanel_LeftPadding;
    
    IBOutlet NSLayoutConstraint*    underline_LeftPadding;
    
    IBOutlet NSLayoutConstraint*    img_cat_topPadding;
    
    IBOutlet NSLayoutConstraint*    panel_topPadding;
    
    IBOutlet NSLayoutConstraint*    line_email_topPadding;
    IBOutlet NSLayoutConstraint*    line_pass_topPadding;
    IBOutlet NSLayoutConstraint*    line_conf_topPadding;
    
    IBOutlet NSLayoutConstraint*    icon_email_Width;
    IBOutlet NSLayoutConstraint*    icon_pass_Width;
    IBOutlet NSLayoutConstraint*    icon_conf_Width;
    
    /// For iPhone4 and 5S
    IBOutlet NSLayoutConstraint*    icon_pass_Offset_Center;
    IBOutlet NSLayoutConstraint*    icon_conf_Offset_Center;
    /// -- End
    
    IBOutlet NSLayoutConstraint*    txt_left_padding;
    
    IBOutlet NSLayoutConstraint*    txt_email_bottom_padding;
    IBOutlet NSLayoutConstraint*    txt_pass_bottom_padding;
    IBOutlet NSLayoutConstraint*    txt_conf_bottom_padding;
    
    IBOutlet NSLayoutConstraint*    txt_height;
    
    IBOutlet NSLayoutConstraint*    checkicon_Width;
    IBOutlet NSLayoutConstraint*    checkBtn_Width;
    
    IBOutlet NSLayoutConstraint*    btnJoinTopPadding;
    IBOutlet NSLayoutConstraint*    btnJoinHeight;
    IBOutlet NSLayoutConstraint*    tosTopPadding;

    IBOutlet NSLayoutConstraint*    lbl_Copyright_Height;
    
    // Signup Underlines
    IBOutlet UIView*        lineView_email;
    IBOutlet UIView*        lineView_password;
    IBOutlet UIView*        lineView_conf_password;
    
    // Signup Input fields' icons
    IBOutlet UIImageView*   icon_email;
    IBOutlet UIImageView*   icon_password;
    IBOutlet UIImageView*   icon_conf_password;
    
    // Signup Input fields' check icons
    IBOutlet UIImageView*   check_icon_email;
    IBOutlet UIImageView*   check_icon_password;
    IBOutlet UIImageView*   check_icon_conf_password;
    
    // Signup Input fields
    IBOutlet UITextField*   txt_email;
    IBOutlet UITextField*   txt_password;
    IBOutlet UITextField*   txt_conf_password;
    
    // Signup Input fields' notification labels
    IBOutlet UILabel*       lbl_email_notification;
    IBOutlet UILabel*       lbl_password_notification;
    IBOutlet UILabel*       lbl_conf_notification;
    
    // Signup Input fields's clear buttons
    IBOutlet UIButton*      btn_clear_email;
    IBOutlet UIButton*      btn_clear_password;
    IBOutlet UIButton*      btn_clear_conf;
    
    IBOutlet UIButton*      btn_edit_password;
    IBOutlet UIButton*      btn_edit_conf;
    
    // Attributed Label for Terms and Service
    
    IBOutlet    UITextView*     textview_terms;
    
    // Signup Join Button
    IBOutlet UIButton*      btn_join;
    
    // Signup process - Check values
    BOOL        validEmail;
    BOOL        validPhone;
    BOOL        validPassword;
    BOOL        validConfirmPassword;
    
    BOOL        isEditMode_Password;
    BOOL        isEditMode_ConfPassword;
    
    CGFloat     maxFontSize;
    CGFloat     dotFontSize;
    CGFloat     tosFontSize;
    CGFloat     notificationFontSize;

    NSAttributedString *passPlaceholderStr;
    NSAttributedString *confirmStr;
}

////////////////////////////////////////
// Utility Functions

// - Initialize the User Interface
- (void)initUI;

// - Update UI Control's color and status
- (void)updateUIStatus:(UITextField* )textField DynamicalCheck:(BOOL)flag;

// - Update the Cat Image and Join button
- (void)updateCatImageandJoin:(BOOL)flag;

// - Register Signup Email to check duplication
- (BOOL)registerEmail:(NSString* )userEmail;

////////////////////////////////////////
// IBActions

- (IBAction)onBack:(id)sender;
- (IBAction)onJoin:(id)sender;
- (IBAction)onClear:(id)sender;
- (IBAction)onEditPassword:(id)sender;

////////////////////////////////////////

@end
