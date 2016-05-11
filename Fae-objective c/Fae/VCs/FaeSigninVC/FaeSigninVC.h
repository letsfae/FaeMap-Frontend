//
//  FaeSigninVC.h
//  Fae
//
//  Created by Liu on 2/29/16.
//  Copyright (c) 2016 Aorinix Technologies Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "Constant.h"
#import "REPagedScrollView.h"

@class TPKeyboardAvoidingScrollView;

@interface FaeSigninVC : UIViewController<MBProgressHUDDelegate, UITextFieldDelegate, UITextViewDelegate>
{
    IBOutlet UILabel*       lbl_copyRight;
    IBOutlet UIImageView*   image_status;

    IBOutlet NSLayoutConstraint*    underline_LeftPadding;
    
    IBOutlet NSLayoutConstraint*    pageScrollPaddingTop;
    
    IBOutlet NSLayoutConstraint*    pageScrollHeight;
    IBOutlet NSLayoutConstraint*    swipeBtnHeight;
    IBOutlet NSLayoutConstraint*    btn_LeftSwipe_Padding;
    IBOutlet NSLayoutConstraint*    btn_RightSwipe_Padding;
    
    IBOutlet NSLayoutConstraint*    imagePaddingTop;
    
    IBOutlet NSLayoutConstraint*    emailLine_PaddingTop;
    IBOutlet NSLayoutConstraint*    passwordLine_PaddingTop;
    
    IBOutlet NSLayoutConstraint*    textFieldHeight;
    IBOutlet NSLayoutConstraint*    textFieldLeftPadding;
    
    IBOutlet NSLayoutConstraint*    txt_email_bottom_padding;
    IBOutlet NSLayoutConstraint*    txt_pass_bottom_padding;
    
    IBOutlet NSLayoutConstraint*    icon_email_Width;
    IBOutlet NSLayoutConstraint*    icon_pass_Width;
    
    /// For iPhone4 and 5S
    IBOutlet NSLayoutConstraint*    icon_email_Offset_Center;
    IBOutlet NSLayoutConstraint*    icon_pass_Offset_Center;
    
    /// -- End
    
    IBOutlet NSLayoutConstraint*    btnGoTopPadding;
    IBOutlet NSLayoutConstraint*    btnGoHeight;
    IBOutlet NSLayoutConstraint*    tosTopPadding;
    
    IBOutlet NSLayoutConstraint*    checkEmailIconBottomPadding;
    IBOutlet NSLayoutConstraint*    checkIconBottomPadding;
    IBOutlet NSLayoutConstraint*    checkIconWidth;
    
    /// For iPhone4 and 5S
    IBOutlet NSLayoutConstraint*    checkBtnWidth;
    IBOutlet NSLayoutConstraint*    checkBtnBottomPadding;
    
    /// -- End
    
    IBOutlet NSLayoutConstraint*    lbl_Copyright_Height;
    
    IBOutlet TPKeyboardAvoidingScrollView *scrollView;
    
    // Signin Container
    IBOutlet UIView*        scroll_panel;
    IBOutlet UIView*        design_panel;
    
    IBOutlet UIView*        accountSwipePanel;
    IBOutlet UIButton*      btn_SwipeLeft;
    IBOutlet UIButton*      btn_SwipeRight;
    NSInteger               focused_Profile_Idx;
    IBOutlet UITextField*   lbl_AccountName;
    
    // Signup Alerts
    IBOutlet UIView*        view_AlertType1;
    IBOutlet UILabel*       lbl_alertType1;
    
    IBOutlet UIView*        view_AlertType2;
    IBOutlet UILabel*       lbl_alertType2;
    
    IBOutlet UIView*        view_AlertType3;
    IBOutlet UILabel*       lbl_alertType3;
    
    // Signin Underlines
    IBOutlet UIView*        lineView_email;
    IBOutlet UIView*        lineView_password;
    
    IBOutlet UILabel*       lbl_emailAlert;
    IBOutlet UILabel*       lbl_passwordAlert;
    
    // Signin Input fields' icons
    IBOutlet UIImageView*   icon_email;
    IBOutlet UIImageView*   icon_password;
    
    // Signin Input fields' check icons
    IBOutlet UIImageView*   check_icon_email;
    IBOutlet UIImageView*   check_icon_password;
    
    // Signin Input fields
    IBOutlet UITextField*   txt_email;
    IBOutlet UITextField*   txt_password;
    
    IBOutlet UIButton*      btn_edit_password;
    
    IBOutlet    UITextView*     textview_terms;
    
    // Signup Join Button
    IBOutlet UIButton*      btn_join;
    
    BOOL    isEditMode_Password;
    
    NSInteger               joinTryCount;
    
    CGFloat     maxFontSize;
    CGFloat     dotFontSize;
    CGFloat     tosFontSize;

    CGRect      txt_Email_frame;
    
    NSAttributedString *confirmStr;
}

@property (strong, nonatomic) REPagedScrollView*    swipeScroll;

////////////////////////////////////////
// Utility Functions

// - Initialize the User Interface
- (void)initUI;

// - Update UI Control's color and status
- (void)updateUIStatus:(UITextField* )textField;

// - Update the Cat Image and Join button
- (void)updateCatImageandJoin:(BOOL)flag;

// - Update the Alert type
- (void)updateAlertType:(NSInteger)typeMode;

- (void)initAccouts;

////////////////////////////////////////
// IBActions

- (IBAction)onBack:(id)sender;
- (IBAction)onJoin:(id)sender;
- (IBAction)onEditPassword:(id)sender;

////////////////////////////////////////

@end
