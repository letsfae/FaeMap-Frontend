//
//  FaeMyCardVC.h
//  Fae
//
//  Created by Liu on 3/11/16.
//  Copyright (c) 2016 Aorinix Technologies Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "Constant.h"
#import "Global.h"
#import "APAvatarImageView.h"

@interface FaeMyCardVC : UIViewController<MBProgressHUDDelegate, UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate>
{
    IBOutlet UIView*        viewHeader;
    IBOutlet UILabel*       lbl_Title;
    IBOutlet UILabel*       lbl_copyRight;

    // NSConstraints for AutoLayouts
    
    IBOutlet NSLayoutConstraint*    profileView_TopPadding;
    IBOutlet NSLayoutConstraint*    profileView_Width;
    IBOutlet NSLayoutConstraint*    profileView_Height;
    
    IBOutlet NSLayoutConstraint*    inputPanel_TopPadding;
    
    IBOutlet NSLayoutConstraint*    underline_LeftPadding;

    IBOutlet NSLayoutConstraint*    line_fn_topPadding;
    IBOutlet NSLayoutConstraint*    line_sn_topPadding;
    IBOutlet NSLayoutConstraint*    line_birth_topPadding;

    IBOutlet NSLayoutConstraint*    icon_fn_Width;
    IBOutlet NSLayoutConstraint*    icon_birth_Width;
    
    /// For iPhone4 and 5S
    IBOutlet NSLayoutConstraint*    icon_fn_Offset_Center;
    IBOutlet NSLayoutConstraint*    icon_sn_Offset_Center;
    IBOutlet NSLayoutConstraint*    icon_birth_Offset_Center;
    /// -- End
    
    IBOutlet NSLayoutConstraint*    txt_left_padding;
    IBOutlet NSLayoutConstraint*    txt_height;

    IBOutlet NSLayoutConstraint*    checkicon_Width;
    
    IBOutlet NSLayoutConstraint*    sexpanel_TopPadding;
    IBOutlet NSLayoutConstraint*    sexpanel_Width;
    IBOutlet NSLayoutConstraint*    sexpanel_Height;

    IBOutlet NSLayoutConstraint*    btn_Start_TopPadding;
    IBOutlet NSLayoutConstraint*    btn_Start_Height;
    
    IBOutlet NSLayoutConstraint*    lbl_Copyright_Height;
    
    // Big Profile  - 5 , 6 and 6S
    
    IBOutlet UIView*                view_BigProfile;
    IBOutlet UIImageView*     img_BigProfile;
    
    IBOutlet UIView*                view_SmallProfile;
    IBOutlet UIImageView*     img_SmallProfile;
    
    // Small Profile - 4S
    
    // Signup Underlines
    IBOutlet UIView*        lineView_fn;
    IBOutlet UIView*        lineView_sn;
    IBOutlet UIView*        lineView_birth;
    
    // Signup Input fields' icons
    IBOutlet UIImageView*   icon_fn;
    IBOutlet UIImageView*   icon_sn;
    IBOutlet UIImageView*   icon_birth;
    
    IBOutlet UIImageView*   check_icon_birth;
    IBOutlet UIButton*      btn_OpenBirth;
    
    IBOutlet UITextField*   txt_fn;
    IBOutlet UITextField*   txt_sn;
    IBOutlet UITextField*   txt_birth;
    
    IBOutlet UITextView*    textview_birthFilter;
    
    IBOutlet UIButton*      btn_sex_Male;
    IBOutlet UIButton*      btn_sex_Female;
    
    // Signup Join Button
    IBOutlet UIButton*      btn_start;
    
    // Signup process - Check values
    
    CGFloat     maxFontSize;
    CGFloat     notificationFontSize;
    
    NSAttributedString *birthPlaceHolder_red;
    NSAttributedString *birthPlaceHolder_gray;
    
    FAE_SEX                 myCardSex;
    
    CGFloat             profile_BorderWidth;
    
    UIImagePickerController *imagePickerController;
}

////////////////////////////////////////
// Utility Functions

// - Initialize the User Interface
- (void)initUI;

- (BOOL)observeValues;

// - Update the Cat Image and Join button
- (void)updateStartButton:(BOOL)flag;

////////////////////////////////////////
// IBActions

- (IBAction)onBack:(id)sender;
- (IBAction)onStart:(id)sender;
- (IBAction)onBirth:(id)sender;
- (IBAction)onSexMale:(id)sender;
- (IBAction)onSexFemale:(id)sender;
- (IBAction)onTakePicture:(id)sender;

////////////////////////////////////////

@end
