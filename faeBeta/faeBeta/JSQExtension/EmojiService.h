//
//  NSObject+EmojiService.h
//  faeBeta
//
//  Created by YAYUAN SHI on 11/16/16.
//  Copyright © 2016 fae. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EmojiService : NSObject 

+ (NSAttributedString *)translateString: (NSString *)string isOutGoing:(BOOL)isOutGoing;
+ (NSString *)shrinkString: (NSString *)string;


@end
