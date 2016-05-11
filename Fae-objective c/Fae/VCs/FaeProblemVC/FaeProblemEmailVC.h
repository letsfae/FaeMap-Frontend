//
//  FaeProblemEmailVC.h
//  Fae
//
//  Created by Liu on 3/1/16.
//  Copyright (c) 2016 Aorinix Technologies Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TPKeyboardAvoidingScrollView;

@interface FaeProblemEmailVC : UIViewController<UITextViewDelegate, UITextFieldDelegate>
{
    IBOutlet    UILabel*    lbl_CopyRight;
    
    IBOutlet TPKeyboardAvoidingScrollView *scrollView;
    
    // Look Container
    IBOutlet UIView*        design_panel;
    
    IBOutlet    UIButton*   btn_Recover;
    IBOutlet    UITextView* txt_Terms;
    
    // Look Underlines
    IBOutlet UIView*        lineView_email;
    
    // Look Input fields' icons
    IBOutlet UIImageView*   icon_email;
    
    // Look Input fields
    IBOutlet UITextField*   txt_email;
}

- (void)initUI;
- (void)updateCatImageandJoin:(BOOL)flag;
- (void)updateUIStatus:(UITextField* )textField;

- (IBAction)onBack:(id)sender;
- (IBAction)onNext:(id)sender;

@end
