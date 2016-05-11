//
//  FaeWelcomeVC.h
//  Fae
//
//  Created by Liu on 2/25/16.
//  Copyright (c) 2016 Aorinix Technologies Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FaeWelcomeVC : UIViewController
{
    IBOutlet UILabel*    lbl_ballonWelcome;
    IBOutlet UILabel*    lbl_Copyright;
    
    IBOutlet UIButton*   btn_signin;
    IBOutlet UIButton*   btn_join;
    IBOutlet UIButton*   btn_look;
}

// Utility Functions

- (void) initUI;

// IBActions

- (IBAction)onSignin:(id)sender;
- (IBAction)onJoin:(id)sender;
- (IBAction)onLook:(id)sender;

@end
