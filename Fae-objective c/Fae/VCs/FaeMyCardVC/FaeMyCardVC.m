//
//  FaeMyCardVC.m
//  Fae
//
//  Created by Liu on 3/11/16.
//  Copyright (c) 2016 Aorinix Technologies Inc. All rights reserved.
//

#import "FaeMyCardVC.h"
#import "FaeAppDelegate.h"
#import "Constant.h"
#import "Global.h"
#import <QuartzCore/QuartzCore.h>
#import "SHSPhoneLibrary.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "AIDatePickerController.h"

@interface FaeMyCardVC ()

@end

@implementation FaeMyCardVC

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Will Init the UI Controls as it is the first screen.
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
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
        
        ////
        
        profileView_TopPadding.constant = 0.0f;
        profileView_Width.constant = 80.0f;
        profileView_Height.constant = 75.0f;
        profile_BorderWidth = 3.0f;
        
        [view_BigProfile setHidden:YES];
        [view_SmallProfile setHidden:NO];
        
        inputPanel_TopPadding.constant = 5.0f;
        
        line_fn_topPadding.constant = 35.0f;
        line_sn_topPadding.constant = 75.0f;
        line_birth_topPadding.constant = 110.0f;
        
        icon_fn_Width.constant = 15.0f;
        icon_birth_Width.constant = 16.0f;
        
        icon_fn_Offset_Center.constant = -1.0f;
        icon_sn_Offset_Center.constant = 0.0f;
        icon_birth_Offset_Center.constant = 0.0f;
        
        txt_left_padding.constant = 37.0f;
        txt_height.constant = 25.0f;
        
        sexpanel_TopPadding.constant = 45.0f;
        sexpanel_Width.constant = 125.0f;
        sexpanel_Height.constant = 34.0f;
        
        btn_Start_Height.constant = 33.0f;
        btn_Start_TopPadding.constant = 25.0f;
        
        ////
        
        lbl_Copyright_Height.constant = 40.0f;
        
    }
    else if (gDeviceType == DEVICE_IPHONE_40INCH)
    {
        underline_LeftPadding.constant = 20.0f;
        
        profileView_TopPadding.constant = 0.0f;
        profileView_Width.constant = 100.0f;
        profileView_Height.constant = 135.0f;
        profile_BorderWidth = 3.0f;
        
        [view_BigProfile setHidden:NO];
        [view_SmallProfile setHidden:YES];
        
        inputPanel_TopPadding.constant = 15.0f;
        
        line_fn_topPadding.constant = 40.0f;
        line_sn_topPadding.constant = 85.0f;
        line_birth_topPadding.constant = 130.0f;
        
        icon_fn_Width.constant = 15.0f;
        icon_birth_Width.constant = 16.0f;
        
        icon_fn_Offset_Center.constant = -1.0f;
        icon_sn_Offset_Center.constant = 0.0f;
        icon_birth_Offset_Center.constant = 0.0f;
        
        txt_left_padding.constant = 37.0f;
        txt_height.constant = 30.0f;
        
        sexpanel_TopPadding.constant = 45.0f;
        sexpanel_Width.constant = 125.0f;
        sexpanel_Height.constant = 34.0f;
        
        btn_Start_Height.constant = 36.0f;
        btn_Start_TopPadding.constant = 20.0f;
        
        lbl_Copyright_Height.constant = 40.0f;
    }
    else if (gDeviceType == DEVICE_IPHONE_47INCH)
    {
        underline_LeftPadding.constant = 30.0f;
        
        /////
        
        profileView_TopPadding.constant = 0.0f;
        profileView_Width.constant = 150.0f;
        profileView_Height.constant = 193.0f;
        profile_BorderWidth = 6.0f;
        
        [view_BigProfile setHidden:NO];
        [view_SmallProfile setHidden:YES];
        
        inputPanel_TopPadding.constant = 15.0f;
        
        line_fn_topPadding.constant = 40.0f;
        line_sn_topPadding.constant = 90.0f;
        line_birth_topPadding.constant = 140.0f;
        
        icon_fn_Width.constant = 21.0f;
        icon_birth_Width.constant = 23.0f;
        
        icon_fn_Offset_Center.constant = -3.0f;
        icon_sn_Offset_Center.constant = -3.0f;
        icon_birth_Offset_Center.constant = -3.0f;
        
        txt_left_padding.constant = 37.0f;
        txt_height.constant = 30.0f;
        
        sexpanel_TopPadding.constant = 50.0f;
        sexpanel_Width.constant = 180.0f;
        sexpanel_Height.constant = 45.0f;
        
        btn_Start_Height.constant = 40.0f;
        btn_Start_TopPadding.constant = 30.0f;
        
        /////
        
        lbl_Copyright_Height.constant = 50.0f;
     
    }
    else if (gDeviceType == DEVICE_IPHONE_55INCH)
    {
        underline_LeftPadding.constant = 30.0f;
        
        profileView_TopPadding.constant = 0.0f;
        profileView_Width.constant = 170.0f;
        profileView_Height.constant = 220.0f;
        profile_BorderWidth = 6.0f;
        
        [view_BigProfile setHidden:NO];
        [view_SmallProfile setHidden:YES];
        
        inputPanel_TopPadding.constant = 15.0f;
        
        line_fn_topPadding.constant = 34.0f;
        line_sn_topPadding.constant = 98.0f;
        line_birth_topPadding.constant = 162.0f;
        
        icon_fn_Width.constant = 21.0f;
        icon_birth_Width.constant = 23.0f;
        
        icon_fn_Offset_Center.constant = -3.0f;
        icon_sn_Offset_Center.constant = -3.0f;
        icon_birth_Offset_Center.constant = -3.0f;
        
        txt_left_padding.constant = 37.0f;
        txt_height.constant = 30.0f;
        
        sexpanel_TopPadding.constant = 50.0f;
        sexpanel_Width.constant = 180.0f;
        sexpanel_Height.constant = 45.0f;
        
        btn_Start_Height.constant = 43.0f;
        btn_Start_TopPadding.constant = 30.0f;
        
        lbl_Copyright_Height.constant = 50.0f;
    }
    
    [viewHeader setBackgroundColor:RED_COLOR];
    [lbl_Title setFont:FONT_REGULAR(22)];
    [lbl_Title setTextColor:[UIColor whiteColor]];
    [lbl_Title setText:@"My Card"];
    
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
    
    // Init Start Button
    
    [btn_start setBackgroundColor:RED_COLOR];
    [btn_start.layer setCornerRadius:8.f];
    
    if (gDeviceType == DEVICE_IPHONE_35INCH
        || gDeviceType == DEVICE_IPHONE_40INCH)
    {
        [btn_start.titleLabel setFont:FONT_REGULAR(20)];
    }
    else
    {
        [btn_start.titleLabel setFont:FONT_REGULAR(22)];
    }
    
    [self updateStartButton:NO];
    
    // Init Underlines
    
    [lineView_fn setBackgroundColor:GRAY_COLOR];
    [lineView_sn setBackgroundColor:GRAY_COLOR];
    [lineView_birth setBackgroundColor:GRAY_COLOR];
    
    if (gDeviceType == DEVICE_IPHONE_47INCH
        || gDeviceType == DEVICE_IPHONE_55INCH)
    {
        maxFontSize = 18;
        notificationFontSize = 11.0f;
    }
    else
    {
        maxFontSize = 17;
        notificationFontSize = 10.0f;
    }
    
    [txt_fn setFont:FONT_LIGHT(maxFontSize)];
    [txt_sn setFont:FONT_LIGHT(maxFontSize)];
    [txt_birth setFont:FONT_LIGHT(maxFontSize)];
    
    txt_fn.autocorrectionType = UITextAutocorrectionTypeNo;
    txt_sn.autocorrectionType = UITextAutocorrectionTypeNo;
    txt_birth.autocorrectionType = UITextAutocorrectionTypeNo;
    
    [txt_fn addTarget:self
               action:@selector(textFieldDidChange:)
     forControlEvents:UIControlEventEditingChanged];
    
    [txt_sn addTarget:self
               action:@selector(textFieldDidChange:)
     forControlEvents:UIControlEventEditingChanged];
    
    birthPlaceHolder_gray =
    [[NSAttributedString alloc] initWithString:@"Birthday"
                                    attributes:@{ NSForegroundColorAttributeName : GRAY_COLOR,
                                                  NSFontAttributeName : FONT_LIGHT(maxFontSize)}];
    
    birthPlaceHolder_red =
    [[NSAttributedString alloc] initWithString:@"Birthday"
                                    attributes:@{ NSForegroundColorAttributeName : RED_COLOR,
                                                  NSFontAttributeName : FONT_LIGHT(maxFontSize)}];
    
    myCardSex = FAE_SEX_NONE;
    
    [btn_sex_Male setImage:[UIImage imageNamed:@"sex_male_gray"] forState:UIControlStateSelected];
    [btn_sex_Female setImage:[UIImage imageNamed:@"sex_female_gray"] forState:UIControlStateSelected];
    
    [btn_sex_Male setSelected:YES];
    [btn_sex_Female setSelected:YES];
    
    // Init Terms and Service Label
    
    /*
     You’re under the eligible age for full version of Fae, some features &
     contents will be filtered. Please check our Terms for more info.
     */
    
    NSString*   segStr1 = @"You’re under the eligible age for full version of Fae, some features & contents will be filtered. Please check our ";
    
    NSString*   segStr2 = @"Terms";
    
    NSString*   segStr3 = @" for more info.";
    
    
    NSDictionary *bold_attributes = @{NSFontAttributeName:FONT_SEMIBOLD(notificationFontSize),
                                      NSForegroundColorAttributeName:RED_COLOR
                                      };
    
    NSDictionary *thin_attributes = @{NSFontAttributeName:FONT_LIGHT(notificationFontSize),
                                      NSForegroundColorAttributeName:RED_COLOR
                                      };
    
    NSMutableAttributedString *attributedSeg1 =
    [[NSMutableAttributedString alloc] initWithString:segStr1
                                           attributes:thin_attributes];
    
    NSMutableAttributedString *attributedSeg2 =
    [[NSMutableAttributedString alloc] initWithString:segStr2
                                           attributes:bold_attributes];
    
    NSMutableAttributedString *attributedSeg3 =
    [[NSMutableAttributedString alloc] initWithString:segStr3
                                           attributes:thin_attributes];
    
    [attributedSeg2 addAttribute:NSLinkAttributeName
                           value:TOS_Keyword1_link
                           range:NSMakeRange(0, segStr2.length)];
    
    NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentRight];
    
    [attributedSeg1 appendAttributedString:attributedSeg2];
    [attributedSeg1 appendAttributedString:attributedSeg3];
    
    [attributedSeg1 addAttribute:NSParagraphStyleAttributeName
                           value:paragraphStyle
                           range:NSMakeRange(0, (segStr1.length + segStr2.length + segStr3.length))];
    
    [textview_birthFilter setScrollEnabled:NO];
    [textview_birthFilter setAttributedText:attributedSeg1];
    
    textview_birthFilter.linkTextAttributes = @{NSForegroundColorAttributeName : RED_COLOR};
    
    [textview_birthFilter setBackgroundColor:[UIColor clearColor]];
    
    textview_birthFilter.selectable = YES;
    textview_birthFilter.dataDetectorTypes = UIDataDetectorTypeAll;
    [textview_birthFilter setEditable:NO];
    textview_birthFilter.delegate = self;
    
    [textview_birthFilter setHidden:YES];
}

- (BOOL)observeValues
{
    BOOL retVal = NO;
    
    BOOL checkVal_FName = YES;
    BOOL checkVal_SName = YES;
    BOOL checkVal_Birth = YES;
    BOOL checkVal_Sex = YES;
    
    if (txt_fn.text.length == 0
        || txt_fn.text == Nil
        || [txt_fn.text isEqualToString:@""])
    {
        checkVal_FName = NO;
    }
    
    if (txt_sn.text.length == 0
        || txt_sn.text == Nil
        || [txt_sn.text isEqualToString:@""])
    {
        checkVal_SName = NO;
    }
    
    if (txt_birth.text.length == 0
        || txt_birth.text == Nil
        || [txt_birth.text isEqualToString:@""])
    {
        checkVal_Birth = NO;
    }
    
    if (myCardSex == FAE_SEX_NONE)
    {
        checkVal_Sex = NO;
    }
    
    retVal = (checkVal_FName && checkVal_SName && checkVal_Birth && checkVal_Sex);
    
    return  retVal;
}

- (void)updateStartButton:(BOOL)flag
{
    if (flag)
    {
        [btn_start setBackgroundColor:RED_COLOR];
    }
    else
    {
        [btn_start setBackgroundColor:RED_COLOR_WITHOPACITY];
    }
    
    [btn_start setUserInteractionEnabled:flag];
}

- (void)dismissKeyboard
{
    [self.view endEditing:YES];
}

#pragma mark - IBActions

// Back to preview window
- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

// Start process
- (IBAction)onStart:(id)sender
{
    [[FaeAppDelegate sharedDelegate] AutoHiddenAlert:kApplicationName
                                      messageContent:@"Good to go Main Screen"];
}

- (IBAction)onBirth:(id)sender
{
    // Open Brith Select View
    
    if ([txt_fn isFirstResponder])
    {
        [txt_fn resignFirstResponder];
    }
    
    if ([txt_sn isFirstResponder])
    {
        [txt_sn resignFirstResponder];
    }
    
    txt_birth.text = @"";
    
    [icon_birth setImage:[UIImage imageNamed:@"card_birth_red"]];
    [lineView_birth setBackgroundColor:RED_COLOR];
    [txt_birth setAttributedPlaceholder:birthPlaceHolder_red];
    [check_icon_birth setImage:[UIImage imageNamed:@"card_birth_open_red"]];
    
    [self updateStartButton:[self observeValues]];
    
    // Display the DatePicker VC
    
    __weak FaeMyCardVC *weakSelf = self;
    
    // Creating a date
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [NSDate date];
    
    AIDatePickerController *datePickerViewController = [AIDatePickerController pickerWithDate:date selectedBlock:^(NSDate *selectedDate) {
        
        __strong FaeMyCardVC *strongSelf = weakSelf;
        
        [strongSelf dismissViewControllerAnimated:YES completion:nil];
        
        NSLog(@"Selected Date : %@", selectedDate);
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMMM dd, yyyy"];
        NSString *reqDateString = [dateFormatter stringFromDate:selectedDate];
        
        

        NSDate* now = [NSDate date];
        NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                           components:NSCalendarUnitYear
                                           fromDate:selectedDate
                                           toDate:now
                                           options:0];
        
        NSInteger age = [ageComponents year];
        
        [txt_birth setTextColor:RED_COLOR];
        
        if (age > 0)
        {
            txt_birth.text = reqDateString;
            
            [check_icon_birth setImage:[UIImage imageNamed:@"check_yes"]];
            
            if (age < 18)
            {
                [textview_birthFilter setHidden:NO];
            }
            else
            {
                [textview_birthFilter setHidden:YES];
            }
        }
        else
        {
            
            txt_birth.text = @"";
            
            [icon_birth setImage:[UIImage imageNamed:@"card_birth_gray"]];
            [lineView_birth setBackgroundColor:GRAY_COLOR];
            [txt_birth setAttributedPlaceholder:birthPlaceHolder_gray];
            [check_icon_birth setImage:[UIImage imageNamed:@"card_birth_open_gray"]];
            
            [[FaeAppDelegate sharedDelegate] AutoHiddenAlert:kApplicationName
                                              messageContent:@"Check your birthday again"];
        }
        
        [self updateStartButton:[self observeValues]];
        
    } cancelBlock:^{
        
        __strong FaeMyCardVC *strongSelf = weakSelf;
        
        [strongSelf dismissViewControllerAnimated:YES completion:nil];
        
        [textview_birthFilter setHidden:NO];
        
        [self updateStartButton:[self observeValues]];
    }];
    
    [self presentViewController:datePickerViewController animated:YES completion:nil];
}

- (IBAction)onSexMale:(id)sender
{
    if (myCardSex != FAE_SEX_MALE)
    {
        myCardSex = FAE_SEX_MALE;
        
        [btn_sex_Male setImage:[UIImage imageNamed:@"sex_male_red"] forState:UIControlStateSelected];
        [btn_sex_Female setImage:[UIImage imageNamed:@"sex_female_gray"] forState:UIControlStateSelected];
        
        [btn_sex_Male setSelected:YES];
        [btn_sex_Female setSelected:NO];
    }
    
    [self updateStartButton:[self observeValues]];
}

- (IBAction)onSexFemale:(id)sender
{
    if (myCardSex != FAE_SEX_FEMALE)
    {
        myCardSex = FAE_SEX_FEMALE;
        
        [btn_sex_Male setImage:[UIImage imageNamed:@"sex_male_gray"] forState:UIControlStateSelected];
        [btn_sex_Female setImage:[UIImage imageNamed:@"sex_female_red"] forState:UIControlStateSelected];
        
        [btn_sex_Male setSelected:NO];
        [btn_sex_Female setSelected:YES];
    }
    
    [self updateStartButton:[self observeValues]];
}

- (IBAction)onTakePicture:(id)sender
{
    imagePickerController = [[UIImagePickerController alloc] init];
    [imagePickerController setDelegate:self];
    imagePickerController.allowsEditing = YES;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Take photo", @"Choose Existing", nil];
        [actionSheet showInView:self.view];
    }
    else
    {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:imagePickerController
                           animated:YES
                         completion:Nil];
    }
}

#pragma mark - UITextField Delegates

// Check the textfield whenever change event is occured

-(void)textFieldDidChange :(UITextField *)textField
{
    
}

// If the textField get the focus, then update the UI controls

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [textField setTintColor:RED_COLOR];
    [textField setTextColor:RED_COLOR];
    
    [txt_fn layoutIfNeeded];
    [txt_sn layoutIfNeeded];
    [txt_birth layoutIfNeeded];
    
    if (txt_birth.text.length == 0
        || txt_birth.text == Nil
        || [txt_birth.text isEqualToString:@""])
    {
        [icon_birth setImage:[UIImage imageNamed:@"card_birth_gray"]];
        [lineView_birth setBackgroundColor:GRAY_COLOR];
        [check_icon_birth setImage:[UIImage imageNamed:@"card_birth_open_gray"]];
    }
    else
    {
        [icon_birth setImage:[UIImage imageNamed:@"card_birth_red"]];
        [lineView_birth setBackgroundColor:RED_COLOR];
        [txt_birth setAttributedPlaceholder:birthPlaceHolder_red];
        [check_icon_birth setImage:[UIImage imageNamed:@"card_birth_open_red"]];
    }
    
    if ([textField isEqual:txt_fn])
    {
        [icon_fn setImage:[UIImage imageNamed:@"signin_email_red"]];
        [lineView_fn setBackgroundColor:RED_COLOR];
    }
    else if ([textField isEqual:txt_sn])
    {
        [icon_sn setImage:[UIImage imageNamed:@"signin_email_red"]];
        [lineView_sn setBackgroundColor:RED_COLOR];
    }
}

// If the textField drop the focus, then update the UI controls

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [txt_fn layoutIfNeeded];
    [txt_sn layoutIfNeeded];
    [txt_birth layoutIfNeeded];
    
    if ([textField isEqual:txt_fn])
    {
        if (textField.text.length == 0
            || textField.text == Nil
            || [textField.text isEqualToString:@""])
        {
            [icon_fn setImage:[UIImage imageNamed:@"signin_email_gray"]];
            [lineView_fn setBackgroundColor:GRAY_COLOR];
        }
        else
        {
            [icon_fn setImage:[UIImage imageNamed:@"signin_email_red"]];
            [lineView_fn setBackgroundColor:RED_COLOR];
        }
    }
    else if ([textField isEqual:txt_sn])
    {
        if (textField.text.length == 0
            || textField.text == Nil
            || [textField.text isEqualToString:@""])
        {
            [icon_sn setImage:[UIImage imageNamed:@"signin_email_gray"]];
            [lineView_sn setBackgroundColor:GRAY_COLOR];
        }
        else
        {
            [icon_sn setImage:[UIImage imageNamed:@"signin_email_red"]];
            [lineView_sn setBackgroundColor:RED_COLOR];
        }
    }
    
    [self updateStartButton:[self observeValues]];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

// Keyboard update accoording to the Return button

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length > 0)
    {
        if ([textField isEqual:txt_fn])
        {
            [txt_sn becomeFirstResponder];
        }
        else if ([textField isEqual:txt_sn])
        {
            [txt_sn resignFirstResponder];
            
            [self onBirth:Nil];
        }
        
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.showsCameraControls = YES;
    }
    else if (buttonIndex == 1)
    {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    [self presentViewController:imagePickerController
                       animated:YES
                     completion:Nil];
}

#pragma mark - UIImagePickerControllerDelegate

// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *edited_image = [info valueForKey:UIImagePickerControllerEditedImage];
    
    if (!edited_image)
    {
        edited_image = [info valueForKey:UIImagePickerControllerOriginalImage];
    }
    
    if (gDeviceType == DEVICE_IPHONE_35INCH)
    {
        [img_SmallProfile setImage:edited_image];
        img_SmallProfile.layer.cornerRadius = img_SmallProfile.frame.size.width / 2;
        img_SmallProfile.clipsToBounds = YES;
        img_SmallProfile.layer.borderWidth = profile_BorderWidth;
        img_SmallProfile.layer.borderColor = RED_COLOR.CGColor;
    }
    else
    {
        [img_BigProfile setImage:edited_image];
        img_BigProfile.layer.cornerRadius = img_SmallProfile.frame.size.width / 2;
        img_BigProfile.clipsToBounds = YES;
        img_BigProfile.layer.borderWidth = profile_BorderWidth;
        img_BigProfile.layer.borderColor = RED_COLOR.CGColor;
    }
    
    [self dismissViewControllerAnimated:YES completion:Nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo
{
    UIImage *edited_image = [editingInfo valueForKey:UIImagePickerControllerEditedImage];
    
    if (!edited_image)
    {
        edited_image = [editingInfo valueForKey:UIImagePickerControllerOriginalImage];
    }
    
    if (gDeviceType == DEVICE_IPHONE_35INCH)
    {
        [img_SmallProfile setImage:edited_image];
        img_SmallProfile.layer.cornerRadius = img_SmallProfile.frame.size.width / 2;
        img_SmallProfile.clipsToBounds = YES;
        img_SmallProfile.layer.borderWidth = profile_BorderWidth;
        img_SmallProfile.layer.borderColor = RED_COLOR.CGColor;
    }
    else
    {
        [img_BigProfile setImage:edited_image];
        img_BigProfile.layer.cornerRadius = img_SmallProfile.frame.size.width / 2;
        img_BigProfile.clipsToBounds = YES;
        img_BigProfile.layer.borderWidth = profile_BorderWidth;
        img_BigProfile.layer.borderColor = RED_COLOR.CGColor;
    }
    
    [self dismissViewControllerAnimated:YES completion:Nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
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
    
    if ([[UIApplication sharedApplication] canOpenURL:URL])
    {
        [[UIApplication sharedApplication] openURL:URL];
    }
    
    return NO;
}

@end
