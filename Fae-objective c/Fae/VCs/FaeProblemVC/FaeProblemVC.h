//
//  FaeProblemVC.h
//  Fae
//
//  Created by Liu on 3/1/16.
//  Copyright (c) 2016 Aorinix Technologies Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FaeProblemVC : UIViewController<UITextViewDelegate>
{
    IBOutlet    UILabel*    lbl_CopyRight;
    
    IBOutlet    UILabel*    lbl_Alert;
    IBOutlet    UIButton*   btn_Recover;
    IBOutlet    UITextView* txt_Terms;
}

- (void)initUI;

- (IBAction)onBack:(id)sender;
- (IBAction)onRecover:(id)sender;


@end