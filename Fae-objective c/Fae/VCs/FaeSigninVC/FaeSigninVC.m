//
//  FaeSigninVC.m
//  Fae
//
//  Created by Liu on 2/29/16.
//  Copyright (c) 2016 Aorinix Technologies Inc. All rights reserved.
//

#import "FaeSigninVC.h"
#import "FaeAppDelegate.h"
#import "Constant.h"
#import "Global.h"
#import <QuartzCore/QuartzCore.h>
#import "TPKeyboardAvoidingScrollView.h"
#import "FaeProblemVC.h"
#import "REPagedScrollView.h"

@interface FaeSigninVC ()

@end

@implementation FaeSigninVC



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    

    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    [self initUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Utility Functions

// - Initialize the User Interface
- (void)initUI
{
    // Update the UI through Devices
    
    pageScrollHeight.constant = gScreenSize.width * (115.0f / 414.0f);
    
    if (gDeviceType == DEVICE_IPHONE_35INCH)
    {
        underline_LeftPadding.constant = 20.0f;
        
        imagePaddingTop.constant = 40.0f;
        pageScrollPaddingTop.constant = 40.0f;
        
        emailLine_PaddingTop.constant = 30.0f;
        passwordLine_PaddingTop.constant = 80.0f;
        textFieldHeight.constant = 30.0f;
        textFieldLeftPadding.constant = 32.0f;
        
        icon_email_Width.constant = 16.0f;
        icon_pass_Width.constant = 15.0f;
        
        icon_email_Offset_Center.constant = -2.0f;
        icon_pass_Offset_Center.constant = -3.0f;
        
        txt_email_bottom_padding.constant = -4.0f;
        txt_pass_bottom_padding.constant = -4.0f;
        
        btnGoTopPadding.constant = 104.0f;
        btnGoHeight.constant = 36.0f;
        
        tosTopPadding.constant = 6.0f;
        
        checkIconBottomPadding.constant = 6.0f;
        checkIconWidth.constant = 15.0f;
        
        checkEmailIconBottomPadding.constant = 5.0f;
        checkBtnWidth.constant = 50.0f;
        checkBtnBottomPadding.constant = 15.0f;
        
        lbl_Copyright_Height.constant = 40.0f;
        
    }
    else if (gDeviceType == DEVICE_IPHONE_40INCH)
    {
        underline_LeftPadding.constant = 20.0f;
        
        imagePaddingTop.constant = 135.0f;
        pageScrollPaddingTop.constant = 135.0f;
        
        emailLine_PaddingTop.constant = 30.0f;
        passwordLine_PaddingTop.constant = 75.0f;
        
        textFieldHeight.constant = 30.0f;
        textFieldLeftPadding.constant = 32.0f;
        
        icon_email_Width.constant = 16.0f;
        icon_pass_Width.constant = 15.0f;
        
        icon_email_Offset_Center.constant = -2.0f;
        icon_pass_Offset_Center.constant = -4.0f;
        
        txt_email_bottom_padding.constant = -4.0f;
        txt_pass_bottom_padding.constant = -4.0f;
        
        btnGoTopPadding.constant = 94.0f;
        btnGoHeight.constant = 36.0f;
        
        tosTopPadding.constant = 6.0f;
        
        checkIconBottomPadding.constant = 6.0f;
        checkIconWidth.constant = 15.0f;
        checkEmailIconBottomPadding.constant = 5.0f;
        checkBtnWidth.constant = 50.0f;
        checkBtnBottomPadding.constant = 15.0f;
        
        lbl_Copyright_Height.constant = 40.0f;
    }
    else
    {
        underline_LeftPadding.constant = 30.0f;
        
        imagePaddingTop.constant = 180.0f;
        pageScrollPaddingTop.constant = 180.0f;
        
        if (gDeviceType == DEVICE_IPHONE_47INCH)
        {
            imagePaddingTop.constant = 165.0f;
            pageScrollPaddingTop.constant = 165.0f;
        }
        
        emailLine_PaddingTop.constant = 64.0f;
        passwordLine_PaddingTop.constant = 128.0f;
        textFieldHeight.constant = 30.f;
        textFieldLeftPadding.constant = 37.0f;
        
        icon_email_Width.constant = 20.0f;
        icon_pass_Width.constant = 16.0f;
        
        icon_email_Offset_Center.constant = -2.0f;
        icon_pass_Offset_Center.constant = -2.0f;
        
        txt_email_bottom_padding.constant = -1.0f;
        txt_pass_bottom_padding.constant = -1.0f;
        
        btnGoTopPadding.constant = 168.0f;
        btnGoHeight.constant = 43.0f;
        
        tosTopPadding.constant = 12.0f;
        
        checkIconBottomPadding.constant = 9.0f;
        
        if (gDeviceType == DEVICE_IPHONE_47INCH)
        {
            checkIconBottomPadding.constant = 10.0f;
        }
        
        checkIconWidth.constant = 19.0f;
        checkEmailIconBottomPadding.constant = 7.0f;
        checkBtnWidth.constant = 50.0f;
        
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
    
    [lbl_copyRight setTextColor:RED_COLOR];
    
    [scrollView setContentSize:CGSizeMake(design_panel.frame.size.width, design_panel.frame.size.height)];
    
    // Init Status ImageView and Join Button
    
    // Init Join Button
    
    [btn_join setBackgroundColor:RED_COLOR];
    [btn_join.layer setCornerRadius:8.f];
    [btn_join.titleLabel setTextColor:[UIColor whiteColor]];
    
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
    
    // Init Input Fields's icons
    
    [icon_email setImage:[UIImage imageNamed:SIGNIN_EMAIL_GRAY]];
    [icon_password setImage:[UIImage imageNamed:PASS_GRAY]];
    
    // Init Check Fields' Icons
    
    [check_icon_email setImage:Nil];
    [check_icon_password setImage:Nil];
    
    [btn_edit_password setHidden:YES];
    
    // Init UITextFields
    
    if (gDeviceType == DEVICE_IPHONE_47INCH
        || gDeviceType == DEVICE_IPHONE_55INCH)
    {
        maxFontSize = 18;
        dotFontSize = 21.0f;
        tosFontSize = 15.0f;
    }
    else
    {
        maxFontSize = 17;
        dotFontSize = 21.0f;
        tosFontSize = 13.0f;
    }
    
    [txt_email setFont:FONT_LIGHT(maxFontSize)];
    [txt_password setFont:FONT_LIGHT(maxFontSize)];
    [lbl_AccountName setFont:FONT_LIGHT(maxFontSize)];
    [lbl_AccountName setTextColor:RED_COLOR];
    
    txt_password.adjustsFontSizeToFitWidth = NO;
    [txt_password setSecureTextEntry:YES];
    
    txt_email.autocorrectionType = UITextAutocorrectionTypeNo;
    txt_password.autocorrectionType = UITextAutocorrectionTypeNo;
    
    [txt_email addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    
    [txt_password addTarget:self
                     action:@selector(textFieldDidChange:)
           forControlEvents:UIControlEventEditingChanged];
    
    isEditMode_Password = NO;
    
    confirmStr =
    [[NSAttributedString alloc] initWithString:@"Password"
                                    attributes:@{ NSForegroundColorAttributeName : GRAY_COLOR,
                                                  NSFontAttributeName : FONT_LIGHT(maxFontSize)}];
    
    [txt_password setFont:FONT_DOT(dotFontSize)];
    
    txt_password.attributedPlaceholder = confirmStr;
    
    
    // iPhone4's Alert Labels.
    
    if (gDeviceType == DEVICE_IPHONE_35INCH)
    {
        [lbl_emailAlert setHidden:NO];
        [lbl_passwordAlert setHidden:NO];
        
        [lbl_emailAlert setFont:FONT_EXTRALIGHT(7)];
        [lbl_passwordAlert setFont:FONT_EXTRALIGHT(7)];
        
        [lbl_emailAlert setTextColor:RED_COLOR];
        [lbl_passwordAlert setTextColor:RED_COLOR];
    }
    else
    {
        [lbl_emailAlert setHidden:YES];
        [lbl_passwordAlert setHidden:YES];
    }
    
    // Init Terms and Service Label
    
    NSDictionary *thin_attributes = @{NSFontAttributeName:FONT_EXTRALIGHT(tosFontSize),
                                      NSForegroundColorAttributeName:RED_COLOR
                                      };
    
    NSMutableAttributedString *attributedProblem =
    [[NSMutableAttributedString alloc] initWithString:SIGNIN_PROBLEM
                                           attributes:thin_attributes];
    
    [attributedProblem addAttribute:NSLinkAttributeName
                              value:SIGNIN_Problem_link
                               range:NSMakeRange(0, SIGNIN_PROBLEM.length)];
    
    NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    
    [attributedProblem addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, SIGNIN_PROBLEM.length)];
    
    [textview_terms setScrollEnabled:NO];
    [textview_terms setAttributedText:attributedProblem];
    
    textview_terms.linkTextAttributes = @{NSForegroundColorAttributeName : RED_COLOR};
    
    [textview_terms setBackgroundColor:[UIColor clearColor]];
    
    textview_terms.selectable = YES;
    textview_terms.dataDetectorTypes = UIDataDetectorTypeAll;
    [textview_terms setEditable:NO];
    textview_terms.delegate = self;
    
    joinTryCount = -1;
    
    txt_Email_frame = txt_email.frame;
    
    [self updateAlertType:joinTryCount];
    
    // Update the UI for the stored accounts
    
    if ([[FaeAppDelegate sharedDelegate] countOfStoredAccounts] < 2)
    {
        // Do not show the arrow button, and account change panel
        
        [accountSwipePanel setHidden:YES];
        [image_status setHidden:NO];
    }
    else
    {
        [accountSwipePanel setHidden:NO];
        [image_status setHidden:NO];
        [image_status setImage:Nil];
        
        [self initAccouts];
    }
}

- (void)initAccouts
{
    [accountSwipePanel setBackgroundColor:[UIColor clearColor]];
    
    _swipeScroll = [[REPagedScrollView alloc] initWithFrame:CGRectMake(0, 0, gScreenSize.width, pageScrollHeight.constant)];
    
    [_swipeScroll setBackgroundColor:[UIColor clearColor]];
    [_swipeScroll.pageControl setHidden:YES];
    _swipeScroll.delegate = self;
    
    [accountSwipePanel addSubview:_swipeScroll];
    [accountSwipePanel sendSubviewToBack:_swipeScroll];
    [accountSwipePanel bringSubviewToFront:btn_SwipeLeft];
    [accountSwipePanel bringSubviewToFront:btn_SwipeRight];
    
    // Set Button's Frame
    
    swipeBtnHeight.constant = pageScrollHeight.constant / 4;
    
    CGFloat swipeBtnPadding = 0.0f;
    
    swipeBtnPadding = (((gScreenSize.width - pageScrollHeight.constant) / 2 ) - btn_SwipeLeft.frame.size.width) / 2;
    
    btn_LeftSwipe_Padding.constant = swipeBtnPadding;
    btn_RightSwipe_Padding.constant = swipeBtnPadding;
    
    for (int i = 0 ; i < [[FaeAppDelegate sharedDelegate] countOfStoredAccounts] ; i ++)
    {
        UIView* view_ProfileAccount = [[UIView alloc] initWithFrame:CGRectMake(0, 0, gScreenSize.width, pageScrollHeight.constant)];
        
        view_ProfileAccount.backgroundColor = [UIColor clearColor];
        
        UIImageView* profileImg = [[UIImageView alloc] initWithFrame:CGRectMake((gScreenSize.width - pageScrollHeight.constant) / 2, 0, pageScrollHeight.constant, pageScrollHeight.constant)];
        profileImg.tag = 2000 + i;
        
        [view_ProfileAccount addSubview:profileImg];
        
        UIButton* selectBtn = [[UIButton alloc] initWithFrame:profileImg.frame];
        selectBtn.tag = 1000 + i;
        [selectBtn setBackgroundColor:[UIColor clearColor]];
        [selectBtn addTarget:self action:@selector(onBtnSelector:) forControlEvents:UIControlEventTouchUpInside];
        
        [view_ProfileAccount addSubview:selectBtn];
        
        if (i == 0)
        {
            [profileImg setImage:[UIImage imageNamed:NORMAL_CAT]];
        }
        else if (i == 1)
        {
            [profileImg setImage:[UIImage imageNamed:@"account_1"]];
        }
        else if (i == 2)
        {
            [profileImg setImage:[UIImage imageNamed:@"account_2"]];
        }
        
        [_swipeScroll addPage:view_ProfileAccount];
    }
    
    [_swipeScroll scrollToPageWithIndex:0 animated:YES];
    
    focused_Profile_Idx = 0;
    
    UIView* containerView = (UIView*)[_swipeScroll.pages objectAtIndex:focused_Profile_Idx];
    
    if ([containerView.subviews count] == 1)
    {
        UIView* pageViewContainer = [containerView.subviews firstObject];
        
        for (UIView* subView in pageViewContainer.subviews)
        {
            if ([subView isKindOfClass:[UIImageView class]])
            {
                if (subView.tag ==  2000)
                {
                    image_status = (UIImageView* )subView;
                    
                    break;
                }
            }
        }
    }
    
    [self updateSwipeButtons];
}

// - Update UI Control's color and status
- (void)updateUIStatus:(UITextField* )textField
{
    // Check Email field
    if ([textField isEqual:txt_email])
    {
        [txt_email setFont:FONT_LIGHT(maxFontSize)];
        
        [icon_email setImage:[UIImage imageNamed:SIGNIN_EMAIL_RED]];
        [lineView_email setBackgroundColor:RED_COLOR];
        [check_icon_email setImage:Nil];
        
        if (textField.text.length == 0
            || textField.text == Nil
            || [textField.text isEqualToString:@""])
        {
            
        }
        else
        {
            
        }
    }   // Check Password field
    else if ([textField isEqual:txt_password])
    {
        DLog(@"%@", textField.text);
        
        [icon_password setImage:[UIImage imageNamed:PASS_RED]];
        [lineView_password setBackgroundColor:RED_COLOR];
        
        if (textField.text.length == 0)
        {
            [txt_password setFont:FONT_LIGHT(maxFontSize)];
            
            txt_password.attributedPlaceholder = confirmStr;
            
            [check_icon_password setImage:Nil];
            [btn_edit_password setHidden:YES];
        }
        else
        {
            if (txt_password.secureTextEntry)
            {
                [txt_password setFont:FONT_DOT(dotFontSize)];
            }
            else
            {
                [txt_password setFont:FONT_LIGHT(maxFontSize)];
            }
            
            if (isEditMode_Password)
            {
                [check_icon_password setImage:[UIImage imageNamed:CHECK_EYE_OPEN_RED]];
            }
            else
            {
                [check_icon_password setImage:[UIImage imageNamed:CHECK_EYE_CLOSE_RED]];
            }
            
            if (gDeviceType == DEVICE_IPHONE_35INCH)
            {
                checkIconBottomPadding.constant = 6.0f;
            }
            else if (gDeviceType == DEVICE_IPHONE_40INCH)
            {
                
            }
            else if (gDeviceType == DEVICE_IPHONE_47INCH)
            {
                checkIconBottomPadding.constant = 10.0f;
            }
            else
            {
                checkIconBottomPadding.constant = 9.0f;
            }
            
            [btn_edit_password setHidden:NO];
        }
    }
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

- (void)updateAlertType:(NSInteger)typeMode
{
    CGFloat alert_font1 = 33.0f;
    CGFloat alert_font2 = 33.0f;
    CGFloat alert_font3 = 20.0f;
    
    if (gDeviceType == DEVICE_IPHONE_35INCH
        || gDeviceType == DEVICE_IPHONE_40INCH)
    {
        alert_font1 = 28.0f;
        alert_font2 = 24.0f;
        alert_font3 = 16.0f;
    }
    else if (gDeviceType == DEVICE_IPHONE_47INCH)
    {
        alert_font1 = 33.0f;
        alert_font2 = 29.0f;
        alert_font3 = 20.0f;
    }
    else if (gDeviceType == DEVICE_IPHONE_55INCH)
    {
        alert_font1 = 33.0f;
        alert_font2 = 33.0f;
        alert_font3 = 20.0f;
    }
    
    [lbl_alertType1 setTextColor:[UIColor whiteColor]];
    [lbl_alertType1 setTextAlignment:NSTextAlignmentCenter];
    [lbl_alertType1 setFont:FONT_SEMIBOLD(alert_font1)];
    [lbl_alertType1 setMinimumScaleFactor:0.5f];
    [lbl_alertType1 setNumberOfLines:1];
    
    [lbl_alertType2 setTextColor:[UIColor whiteColor]];
    [lbl_alertType2 setTextAlignment:NSTextAlignmentCenter];
    [lbl_alertType2 setFont:FONT_SEMIBOLD(alert_font2)];
    [lbl_alertType2 setMinimumScaleFactor:0.5f];
    [lbl_alertType2 setNumberOfLines:2];
    
    [lbl_alertType3 setTextColor:[UIColor whiteColor]];
    [lbl_alertType3 setTextAlignment:NSTextAlignmentCenter];
    [lbl_alertType3 setFont:FONT_SEMIBOLD(alert_font3)];
    [lbl_alertType3 setMinimumScaleFactor:0.5f];
    [lbl_alertType3 setNumberOfLines:4];
    
    [image_status setImage:[UIImage imageNamed:NORMAL_CAT]];
    
    switch (typeMode) {
        case -1:
        {
            [view_AlertType1 setHidden:YES];
            [view_AlertType2 setHidden:YES];
            [view_AlertType3 setHidden:YES];
            
            [check_icon_email setImage:Nil];
            [check_icon_password setImage:Nil];
            
            [image_status setImage:[UIImage imageNamed:NORMAL_CAT]];
            
            [lbl_emailAlert setHidden:YES];
            [lbl_passwordAlert setHidden:YES];
        }
            break;
        case 0:
        {
            [view_AlertType1 setHidden:NO];
            [view_AlertType2 setHidden:YES];
            [view_AlertType3 setHidden:YES];
            
            lbl_alertType1.text = @"Hi!";
            
            [check_icon_email setImage:Nil];
            
            [image_status setImage:[UIImage imageNamed:NORMAL_CAT]];
            
            [lbl_emailAlert setHidden:YES];
            [lbl_passwordAlert setHidden:YES];
        }
            break;
        case 1:
        {
            [view_AlertType1 setHidden:YES];
            [view_AlertType2 setHidden:NO];
            [view_AlertType3 setHidden:YES];
            
            lbl_alertType2.text = @"Almost\nthere!";
            
            [check_icon_email setImage:Nil];
            
            [image_status setImage:[UIImage imageNamed:NORMAL_CAT]];
            
            [lbl_emailAlert setHidden:YES];
            [lbl_passwordAlert setHidden:YES];
        }
            break;
        case 2:
        {
            [view_AlertType1 setHidden:YES];
            [view_AlertType2 setHidden:NO];
            [view_AlertType3 setHidden:YES];
            
            lbl_alertType2.text = @"Let's Go!";
            
            [check_icon_email setImage:Nil];
            [check_icon_password setImage:Nil];
            
            [image_status setImage:[UIImage imageNamed:SMILE_CAT]];
            
            [lbl_emailAlert setHidden:YES];
            [lbl_passwordAlert setHidden:YES];
            
        }
            break;
        case 3:
        {
            [view_AlertType1 setHidden:YES];
            [view_AlertType2 setHidden:YES];
            [view_AlertType3 setHidden:NO];
            
            lbl_alertType3.text = @"Oh No! We can't find\nyour account!\nPlease check your\nUsername/Email";
            
            [check_icon_email setImage:[UIImage imageNamed:CHECK_EXCLAMATION_RED]];
            [check_icon_password setImage:[UIImage imageNamed:CHECK_EXCLAMATION_RED]];
            
            if (gDeviceType == DEVICE_IPHONE_35INCH)
            {
                checkIconBottomPadding.constant = 6.0f;
            }
            else if (gDeviceType == DEVICE_IPHONE_40INCH)
            {
                
            }
            else if (gDeviceType == DEVICE_IPHONE_47INCH)
            {
                checkIconBottomPadding.constant = 5.0f;
            }
            else
            {
                checkIconBottomPadding.constant = 9.0f;
            }
            
            [image_status setImage:[UIImage imageNamed:SAD_CAT]];
            
            [lbl_emailAlert setHidden:NO];
            [lbl_passwordAlert setHidden:YES];
            
            [lbl_emailAlert setText:@"Oh No! We can't find your account! Please check your Username/Email"];
        }
            break;
        case 4:
        {
            [view_AlertType1 setHidden:YES];
            [view_AlertType2 setHidden:YES];
            [view_AlertType3 setHidden:NO];
            
            lbl_alertType3.text = @"Oops! That's not the\ncorrect Password!\nPlease check your\nPassword!";
            [check_icon_email setImage:Nil];
            [check_icon_password setImage:[UIImage imageNamed:CHECK_EXCLAMATION_RED]];
            
            [image_status setImage:[UIImage imageNamed:SAD_CAT]];
            
            [lbl_emailAlert setHidden:YES];
            [lbl_passwordAlert setHidden:NO];
            
            [lbl_passwordAlert setText:@"Oops! That's not the correct Password! Please check your Password!"];
        }
            break;
        case 5:
        {
            [view_AlertType1 setHidden:YES];
            [view_AlertType2 setHidden:YES];
            [view_AlertType3 setHidden:NO];
            
            lbl_alertType3.text = @"Oh No! Please check\nyour Password\ncarefully! You have\n3 more tries left!";
            
            [check_icon_email setImage:Nil];
            [check_icon_password setImage:[UIImage imageNamed:CHECK_EXCLAMATION_RED]];
            
            [image_status setImage:[UIImage imageNamed:SAD_CAT]];
            
            [lbl_emailAlert setHidden:YES];
            [lbl_passwordAlert setHidden:NO];
            lbl_passwordAlert.text = @"Oh No! Please check your Password carefully! You have 3 more tries left!";
            
        }
            break;
        case 6:
        {
            [view_AlertType1 setHidden:YES];
            [view_AlertType2 setHidden:YES];
            [view_AlertType3 setHidden:NO];
            
            lbl_alertType3.text = @"Oh No! Please check\nyour Password\ncarefully! You have\n2 more tries left!";
            
            [check_icon_email setImage:Nil];
            [check_icon_password setImage:[UIImage imageNamed:CHECK_EXCLAMATION_RED]];
            
            [image_status setImage:[UIImage imageNamed:SAD_CAT]];
            
            [lbl_emailAlert setHidden:YES];
            [lbl_passwordAlert setHidden:NO];
            
            lbl_passwordAlert.text = @"Oh No! Please check your Password carefully! You have 2 more tries left!";
            
        }
            break;
        case 7:
        {
            [view_AlertType1 setHidden:YES];
            [view_AlertType2 setHidden:YES];
            [view_AlertType3 setHidden:NO];
            
            lbl_alertType3.text = @"Oh No! Please check\nyour Password\ncarefully! You have\n1 last try left!";
            
            [check_icon_email setImage:Nil];
            [check_icon_password setImage:[UIImage imageNamed:CHECK_EXCLAMATION_RED]];
            
            [image_status setImage:[UIImage imageNamed:SAD_CAT]];
            
            [lbl_emailAlert setHidden:YES];
            [lbl_passwordAlert setHidden:NO];
            
            lbl_passwordAlert.text = @"Oh No! Please check your Password carefully! You have 1 last try left!";
        }
            break;
        case 8:
        {
            [view_AlertType1 setHidden:YES];
            [view_AlertType2 setHidden:YES];
            [view_AlertType3 setHidden:NO];
            
            lbl_alertType3.text = @"Sorry! Your Fae is\nlocked for your\nsecurity. Please\nsee support!";
            
            [check_icon_email setImage:Nil];
            [check_icon_password setImage:[UIImage imageNamed:CHECK_EXCLAMATION_RED]];
            
            [image_status setImage:[UIImage imageNamed:SAD_CAT]];
            
            [lbl_emailAlert setHidden:YES];
            [lbl_passwordAlert setHidden:NO];
            
            lbl_passwordAlert.text = @"Sorry! Your Fae is locked for your security. Please see support!";
        }
            break;
        case 9:
        {
            [view_AlertType1 setHidden:YES];
            [view_AlertType2 setHidden:YES];
            [view_AlertType3 setHidden:YES];
            
            [check_icon_email setImage:Nil];
            [check_icon_password setImage:Nil];
            
            [image_status setImage:[UIImage imageNamed:SMILE_CAT]];
            
            [[FaeAppDelegate sharedDelegate] ShowAlert:kApplicationName
                                        messageContent:@"We are ready to Go!"];
            
            [lbl_emailAlert setHidden:YES];
            [lbl_passwordAlert setHidden:YES];
            
        }
            break;
    }
    
    if (gDeviceType == DEVICE_IPHONE_35INCH)
    {
        checkIconBottomPadding.constant = 4.0f;
        checkEmailIconBottomPadding.constant = 4.0f;
    }
    else if (gDeviceType == DEVICE_IPHONE_40INCH)
    {
        
    }
    else if (gDeviceType == DEVICE_IPHONE_47INCH)
    {
        checkIconBottomPadding.constant = 7.0f;
    }
    else
    {
        checkIconBottomPadding.constant = 7.0f;
    }
    
    if (gDeviceType == DEVICE_IPHONE_35INCH)
    {
        [view_AlertType1 setHidden:YES];
        [view_AlertType2 setHidden:YES];
        [view_AlertType3 setHidden:YES];
    }
    else
    {
        [lbl_emailAlert setHidden:YES];
        [lbl_passwordAlert setHidden:YES];
    }
}

- (void)updateSwipeButtons
{
    if (focused_Profile_Idx == 0)
    {
        [btn_SwipeLeft setHidden:YES];
        [btn_SwipeRight setHidden:NO];
    }
    else if (focused_Profile_Idx < (_swipeScroll.pages.count - 1))
    {
        [btn_SwipeLeft setHidden:NO];
        [btn_SwipeRight setHidden:NO];
    }
    else
    {
        [btn_SwipeLeft setHidden:NO];
        [btn_SwipeRight setHidden:YES];
    }
    
    if (focused_Profile_Idx == 0)
    {
        [self updateAlertType:-1];
        
        [lbl_AccountName setHidden:YES];
        
        lbl_AccountName.text = @"";
        
        [lineView_email setHidden:NO];
        [icon_email setHidden:NO];
        [txt_email setHidden:NO];
        
        [lineView_email setBackgroundColor:GRAY_COLOR];
        [icon_email setImage:[UIImage imageNamed:SIGNIN_EMAIL_GRAY]];
        
        [lineView_password setBackgroundColor:GRAY_COLOR];
        [icon_password setImage:[UIImage imageNamed:PASS_GRAY]];
        
        txt_email.text = @"";
        txt_password.text = @"";
        
        if ([txt_email isFirstResponder])
        {
            [txt_email resignFirstResponder];
        }
        else if ([txt_password isFirstResponder])
        {
            [txt_password resignFirstResponder];
        }
    }
    else
    {
        [self updateAlertType:0];
        
        [lbl_AccountName setHidden:NO];
        
        lbl_AccountName.text = [NSString stringWithFormat:@"Beta Tester%d", (int)focused_Profile_Idx];
        
        [lineView_email setHidden:YES];
        [icon_email setHidden:YES];
        [txt_email setHidden:YES];
    }
    
    if (focused_Profile_Idx == 0)
    {
        if (txt_email.text.length > 0
            && txt_password.text.length > 0)
        {
            [self updateCatImageandJoin:YES];
        }
        else
        {
            [self updateCatImageandJoin:NO];
        }
    }
    else
    {
        if (txt_password.text.length > 0)
        {
            [self updateCatImageandJoin:YES];
        }
        else
        {
            [self updateCatImageandJoin:NO];
        }
    }
}

- (void)dismissKeyboard
{
    [self.view endEditing:YES];
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
 
    [txt_email layoutIfNeeded];
    [txt_password layoutIfNeeded];
    
    [self updateUIStatus:textField];
    
    if ([textField isEqual:txt_email])
    {
        [txt_email setFont:FONT_LIGHT(maxFontSize)];
        
        if (txt_password.text.length == 0
            || txt_password.text == Nil
            || [txt_password.text isEqualToString:@""])
        {
            [self updateAlertType:0];
        }
        else
        {
            [self updateAlertType:1];
        }
    }
    else if ([textField isEqual:txt_password])
    {
        if (textField.text.length == 0)
        {
            [txt_password setFont:FONT_LIGHT(maxFontSize)];
            
            txt_password.attributedPlaceholder = confirmStr;
            
            [textField setTintColor:RED_COLOR];
            [textField setTextColor:RED_COLOR];
            
            [check_icon_password setImage:Nil];
        }
        else
        {
            if (txt_password.secureTextEntry)
            {
                [txt_password setFont:FONT_DOT(dotFontSize)];
            }
            else
            {
                [txt_password setFont:FONT_LIGHT(maxFontSize)];
            }
            
            [check_icon_password setImage:[UIImage imageNamed:CHECK_EYE_CLOSE_RED]];
            
            [btn_edit_password setHidden:NO];
        }
    
        if (focused_Profile_Idx == 0)
        {
            if (txt_email.text.length == 0
                || txt_email.text == Nil
                || [txt_email.text isEqualToString:@""])
            {
                [self updateAlertType:0];
            }
            else
            {
                [self updateAlertType:1];
            }
        }
        else
        {
            [self updateAlertType:1];
        }
        
        if (gDeviceType == DEVICE_IPHONE_35INCH)
        {
            checkIconBottomPadding.constant = 6.0f;
        }
        else if (gDeviceType == DEVICE_IPHONE_40INCH)
        {
            
        }
        else if (gDeviceType == DEVICE_IPHONE_47INCH)
        {
            checkIconBottomPadding.constant = 10.0f;
        }
        else
        {
            checkIconBottomPadding.constant = 9.0f;
        }
        
    }
    
    [self updateCatImageandJoin:NO];    
}

// If the textField drop the focus, then update the UI controls

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [txt_email layoutIfNeeded];
    [txt_password layoutIfNeeded];
    
    if ([textField isEqual:txt_email])
    {
        [txt_email setFont:FONT_LIGHT(maxFontSize)];
        
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
    else if ([textField isEqual:txt_password])
    {
        [self updateUIStatus:textField];
        
        isEditMode_Password = NO;
        
        if (textField.text.length == 0
            || textField.text == Nil
            || [textField.text isEqualToString:@""])
        {
            txt_password.attributedPlaceholder = confirmStr;
            
            [icon_password setImage:[UIImage imageNamed:PASS_GRAY]];
            [lineView_password setBackgroundColor:GRAY_COLOR];
        }
        else
        {
            [icon_password setImage:[UIImage imageNamed:PASS_RED]];
            [lineView_password setBackgroundColor:RED_COLOR];
            
            [check_icon_password setImage:Nil];
            [btn_edit_password setHidden:YES];
            
            [txt_password setFont:FONT_DOT(dotFontSize)];
            
            [textField setSecureTextEntry:YES];
        }
        
        if (gDeviceType == DEVICE_IPHONE_35INCH)
        {
            checkIconBottomPadding.constant = 6.0f;
        }
        else if (gDeviceType == DEVICE_IPHONE_40INCH)
        {
            
        }
        else if (gDeviceType == DEVICE_IPHONE_47INCH)
        {
            checkIconBottomPadding.constant = 10.0f;
        }
        else
        {
            checkIconBottomPadding.constant = 9.0f;
        }
    }
    
    if (txt_email.text.length > 0
        && txt_password.text.length > 0)
    {
        [self updateAlertType:2];
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
    if (textField.text.length > 0)
    {
        if ([textField isEqual:txt_email])
        {
            [txt_password becomeFirstResponder];
        }
        else if ([textField isEqual:txt_password])
        {
            [textField resignFirstResponder];
        }
        
        return YES;
    }
    else
    {
        txt_password.attributedPlaceholder = confirmStr;
        
        return NO;
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
                
                txt_password.attributedPlaceholder = confirmStr;
                
                [check_icon_password setImage:Nil];
                [btn_edit_password setHidden:YES];
            }
            
            [textField setSecureTextEntry:NO];
            
            NSString *updatedString = [textField.text stringByReplacingCharactersInRange:range withString:string];
            
            textField.text = updatedString;
            
            [textField setSecureTextEntry:YES];
            
            if (textField.text.length == 0)
            {
                [txt_password setFont:FONT_LIGHT(maxFontSize)];
                
                txt_password.attributedPlaceholder = confirmStr;
                
                [check_icon_password setImage:Nil];
                [btn_edit_password setHidden:YES];
            }
            else
            {
                if (isEditMode_Password)
                {
                    [txt_password setFont:FONT_LIGHT(maxFontSize)];
                    
                    [check_icon_password setImage:[UIImage imageNamed:CHECK_EYE_OPEN_RED]];
                }
                else
                {
                    [txt_password setFont:FONT_DOT(dotFontSize)];
                    [check_icon_password setImage:[UIImage imageNamed:CHECK_EYE_CLOSE_RED]];
                }
                
                if (gDeviceType == DEVICE_IPHONE_35INCH)
                {
                    checkIconBottomPadding.constant = 6.0f;
                }
                else if (gDeviceType == DEVICE_IPHONE_40INCH)
                {
                    
                }
                else if (gDeviceType == DEVICE_IPHONE_47INCH)
                {
                    checkIconBottomPadding.constant = 10.0f;
                }
                else
                {
                    checkIconBottomPadding.constant = 9.0f;
                }
                
                [btn_edit_password setHidden:NO];
            }
            
            return NO;
        }
        
    }
    else
    {
        [txt_email setFont:FONT_LIGHT(maxFontSize)];
    }
    return YES;
}

#pragma mark - CCHLinkAttributeName Delegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    NSString* openPath = [URL absoluteString];
    
    DLog(@"%@", openPath);
    
    if ([openPath isEqualToString:SIGNIN_Problem_link])
    {
        FaeProblemVC* problemVC = [[FaeProblemVC alloc] initWithNibName:@"FaeProblemVC" bundle:Nil];
        
        [self.navigationController pushViewController:problemVC animated:YES];
    }
    
    if ([[UIApplication sharedApplication] canOpenURL:URL])
    {
        [[UIApplication sharedApplication] openURL:URL];
    }
    
    return NO;
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
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    double delayInSeconds = 0.5;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
        
        joinTryCount = joinTryCount + 1;
        
        [self updateAlertType:((joinTryCount % 7) + 3)];
    });
}

// Edit Password
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
            
            [check_icon_password setImage:[UIImage imageNamed:CHECK_EYE_CLOSE_RED]];
            
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
            
            [check_icon_password setImage:[UIImage imageNamed:CHECK_EYE_OPEN_RED]];
        }
        
        if (gDeviceType == DEVICE_IPHONE_35INCH)
        {
            checkIconBottomPadding.constant = 6.0f;
        }
        else if (gDeviceType == DEVICE_IPHONE_40INCH)
        {
            
        }
        else if (gDeviceType == DEVICE_IPHONE_47INCH)
        {
            checkIconBottomPadding.constant = 10.0f;
        }
        else
        {
            checkIconBottomPadding.constant = 9.0f;
        }
        
        isEditMode_Password = !isEditMode_Password;
        
        [btn_edit_password setHidden:NO];
    }
}

- (IBAction)onSwipeLeft:(id)sender
{
    if (focused_Profile_Idx == 0)
    {
        
    }
    else if (focused_Profile_Idx < _swipeScroll.pages.count)
    {
        [_swipeScroll scrollToPageWithIndex:(focused_Profile_Idx - 1) animated:YES];
    }
    
    [self updateSwipeButtons];
}

- (IBAction)onSwipeRight:(id)sender
{
    if (focused_Profile_Idx < _swipeScroll.pages.count)
    {
        [_swipeScroll scrollToPageWithIndex:(focused_Profile_Idx + 1) animated:YES];
    }
    
    [self updateSwipeButtons];
}

- (IBAction)onBtnSelector:(id)sender
{
    UIButton* sendBtn = (UIButton* )sender;
    
    DLog(@"%d", (int)sendBtn.tag);
    
    if (focused_Profile_Idx > 0)
    {
        [[FaeAppDelegate sharedDelegate] ShowAlert:kApplicationName
                                    messageContent:[NSString stringWithFormat:@"Beta Tester%d",(int) focused_Profile_Idx]];
    }
    
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)src_scrollView
{
    if ([src_scrollView isEqual:_swipeScroll.scrollView])
    {
        CGFloat pageWidth = src_scrollView.frame.size.width;
        
        int page = floor((src_scrollView.contentOffset.x - pageWidth / 2.0) / pageWidth) + 1;
        
        focused_Profile_Idx = page;
        
        if (src_scrollView.contentOffset.x == 0)
        {
            UIView* containerView = (UIView*)[_swipeScroll.pages objectAtIndex:focused_Profile_Idx];
            
            if ([containerView.subviews count] == 1)
            {
                UIView* pageViewContainer = [containerView.subviews firstObject];
                
                for (UIView* subView in pageViewContainer.subviews)
                {
                    if ([subView isKindOfClass:[UIImageView class]])
                    {
                        if (subView.tag ==  2000)
                        {
                            image_status = (UIImageView* )subView;
                            
                            break;
                        }
                    }
                }
            }
        }
        
        [self updateSwipeButtons];
    }
    else
    {
        src_scrollView.contentOffset = CGPointMake(src_scrollView.contentOffset.x, 0);
    }
    
}

@end
