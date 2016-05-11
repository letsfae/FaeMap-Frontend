//
//  FaeAppDelegate.h
//  Fae
//
//  Created by Liu on 2/25/16.
//  Copyright (c) 2016 Aorinix Technologies Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FaeStartupVC;

@interface FaeAppDelegate : UIResponder <UIApplicationDelegate>

+ (FaeAppDelegate*)sharedDelegate;

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController    *rootVC;
@property (strong, nonatomic) FaeStartupVC              *startupVC;

// Utility Functions

- (void) ShowAlert:(NSString*)title
    messageContent:(NSString *)content;

- (void) AutoHiddenAlert:(NSString*)title
          messageContent:(NSString *)content;

- (BOOL) isValidEmail:(NSString *)checkString;
- (BOOL) isValidPassword:(NSString*)checkString;
- (UIImage *)imageWithColor:(UIColor *)color;

- (NSInteger)countOfStoredAccounts;

@end
