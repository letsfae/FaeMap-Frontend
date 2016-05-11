//
//  FaeStartupVC.m
//  Fae
//
//  Created by Liu on 3/1/16.
//  Copyright (c) 2016 Aorinix Technologies Inc. All rights reserved.
//

#import "FaeStartupVC.h"
#import "Constant.h"
#import "FaeAppDelegate.h"
#import "Global.h"
#import "FaeWelcomeVC.h"

@interface FaeStartupVC ()

@end

@implementation FaeStartupVC

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (gDeviceType == DEVICE_IPHONE_35INCH)
    {
        [splashImg setImage:[UIImage imageNamed:@"splash@2x.png"]];
    }
    else if (gDeviceType == DEVICE_IPHONE_40INCH)
    {
        [splashImg setImage:[UIImage imageNamed:@"splash-568h@2x.png"]];
    }
    else if (gDeviceType == DEVICE_IPHONE_47INCH)
    {
        [splashImg setImage:[UIImage imageNamed:@"splash-667h@2x.png"]];
    }
    else if (gDeviceType == DEVICE_IPHONE_55INCH)
    {
        [splashImg setImage:[UIImage imageNamed:@"splash-736h@3x.png"]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    double delayInSeconds = 1.5f;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        FaeWelcomeVC* welcomeVC = [[FaeWelcomeVC alloc] initWithNibName:@"FaeWelcomeVC" bundle:Nil];
        
        [UIView transitionWithView:self.navigationController.view
                          duration:0.75
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [self.navigationController pushViewController:welcomeVC animated:NO];
                        } 
                        completion:nil];
        

        
    });
}


@end
