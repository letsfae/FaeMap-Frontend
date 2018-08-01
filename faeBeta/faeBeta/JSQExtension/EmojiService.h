//
//  NSObject+EmojiService.h
//  faeBeta
//
//  Created by YAYUAN SHI on 11/16/16.
//  Copyright © 2016 fae. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 A class to provide some basic function
 */
@interface EmojiService : NSObject 


/**
 This is a tool to help translate a string to an attributed string with emoji attachment

 @param string the origin string
 @param isOutGoing if the message string is outgoing. This will influence the text color
 @return an attributed string with emoji attachments inside
 */
+ (NSAttributedString *)translateString: (NSString *)string textColor:(UIColor *)textColor;

/**
 A method to translate a string with emoji symbol inside to another string that has the same length. This method is used to generate a replacement string to calculate the size of the message bubble

 @param string the origin string
 @return a string with some placeholder for the emoji.
 */
+ (NSString *)shrinkString: (NSString *)string;

@end
