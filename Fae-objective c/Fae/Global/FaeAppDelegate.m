//
//  FaeAppDelegate.m
//  Fae
//
//  Created by Liu on 2/25/16.
//  Copyright (c) 2016 Aorinix Technologies Inc. All rights reserved.
//

#import "FaeAppDelegate.h"
#import "FaeStartupVC.h"
#import "Constant.h"
#import "Global.h"

@implementation FaeAppDelegate

+ (FaeAppDelegate*)sharedDelegate
{
    return (FaeAppDelegate*)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Setting for Status bar and Navigation Bar
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
	[[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
	[[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1]];
    
	NSDictionary *attributes = @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:20.0f],
								  NSForegroundColorAttributeName: [UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1]};
    
	[[UINavigationBar appearance] setTitleTextAttributes:attributes];
    
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Initialize Global variables
    
    gScreenSize = self.window.frame.size;
    gScaleFactor = 1.0f;  // Base value is iPhone6+ : 5.5inch screen
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        gDeviceType = DEVICE_IPAD;
    }
    else if (self.window.frame.size.height == 568)
    {
        gDeviceType = DEVICE_IPHONE_40INCH;
        
        gScaleFactor = 320.0f /414.0f;        
    }
    else if (self.window.frame.size.height == 667 && self.window.frame.size.width == 375)
    {
        gDeviceType = DEVICE_IPHONE_47INCH;
        
        gScaleFactor = 375.0f /414.0f;
    }
    else if (self.window.frame.size.height == 736 && self.window.frame.size.width == 414)
    {
        gDeviceType = DEVICE_IPHONE_55INCH;
        
        gScaleFactor = 1.0f;
    }
    else if ((self.window.frame.size.height == 1024) || (self.window.frame.size.height == 768))
    {
        gDeviceType = DEVICE_IPAD;
    }
    
    else
    {
        gDeviceType = DEVICE_IPHONE_35INCH;
    }
    
    float iosversion = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    if ( iosversion >= 7.0f)
    {
        gIOSVersion = IOS_7;
    }
    else if (iosversion >= 6.0f && iosversion < 7.0f)
    {
        gIOSVersion = IOS_6;
    }
    else if (iosversion >= 5.0f && iosversion < 6.0f)
    {
        gIOSVersion = IOS_5;
    }
    else if (iosversion >= 4.0f && iosversion < 5.0f)
    {
        gIOSVersion = IOS_4;
    }
    
    gDeviceOrientation = UIInterfaceOrientationPortrait;
    
    // End Utility
    
    self.startupVC = [[FaeStartupVC alloc] initWithNibName:@"FaeStartupVC" bundle:nil];
    
    self.rootVC = [[UINavigationController alloc] initWithRootViewController:self.startupVC];
    
    [self.rootVC setNavigationBarHidden:YES];
    
    self.window.rootViewController = self.rootVC;
    
    [self.window makeKeyAndVisible];
        
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    DLog(@"Will Save Global Information to Parse");
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark -
#pragma mark - Utility Function

- (void)ShowAlert:(NSString*)title messageContent:(NSString *)content
{
    UIAlertView* confirm = [[UIAlertView alloc] initWithTitle:title
                                                      message:nil
                                                     delegate:nil
                                            cancelButtonTitle:Nil
                                            otherButtonTitles:@"Ok", nil];
    
	confirm.message = [NSString stringWithFormat:@"%@", content];
	
    confirm.delegate = self;
    
	[confirm show];
    
}

- (void)autoHide:(UIAlertView*)alert
{
    [alert dismissWithClickedButtonIndex:-1 animated:YES];
}

- (void) AutoHiddenAlert:(NSString*)title messageContent:(NSString *)content
{
    UIAlertView *autoAlert = [[UIAlertView alloc] initWithTitle:title
                                                        message:content
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    
    [autoAlert show];
    
    double delayInSeconds = 2.0;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [self autoHide:autoAlert];
    });
}

- (BOOL)isValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (BOOL) isValidPassword:(NSString*)checkString
{
    NSString* const pattern = @"^.*(?=.{8,})(?=.*[a-z])(?=.*[A-Z]).*$";
    NSRegularExpression* regex = [[NSRegularExpression alloc] initWithPattern:pattern options:0 error:nil];
    NSRange range = NSMakeRange(0, [checkString length]);
    return [regex numberOfMatchesInString:checkString options:0 range:range] > 0;
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (NSInteger)countOfStoredAccounts
{
    // This is the temporary value
    
    return 1;
}

@end
