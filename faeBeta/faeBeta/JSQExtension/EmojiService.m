//
//  NSObject+EmojiService.m
//  faeBeta
//
//  Created by YAYUAN SHI on 11/16/16.
//  Copyright © 2016 fae. All rights reserved.
//

#import "EmojiService.h"
#import "faeBeta-Swift.h"

@implementation EmojiService

+ (NSAttributedString *)translateString: (NSString *)string isOutGoing:(BOOL)isOutGoing
{
    NSArray *emojiNames =
    @[@"Happy", @"LOL", @"WarmSmile", @"Hehe", @"Smile", @"CrySmile", @"CoverSmile", @"Love", @"Huehue", @"Beauty", @"Wink", @"LoveLove", @"Slurp", @"Kiss", @"Bye", @"WarmBye", @"Heyy", @"Sly", @"Clapclap", @"Cash", @"Stare", @"Blush", @"WowStare", @"Awkward", @"Surprise", @"Scared", @"Opposite", @"Unhappy", @"Sigh", @"welp", @"Sad", @"mmm", @"Please", @"Crying", @"Tears", @"holdtears", @"Waterfall", @"Shush", @"Sick", @"Dizzy", @"DizzyCold", @"Cold", @"Gross", @"Puke", @"Sleepy", @"Yawn", @"Sleeping", @"Snore", @"Slap", @"Pound", @"Burnt", @"Ignore", @"Tantrum", @"Scold", @"Angry", @"Mad", @"Hmm", @"Processing", @"Hesitate", @"Dontknow", @"Wat", @"Thinking", @"Whistle", @"Shhh", @"Hmph", @"Hmph2", @"Speechless", @"Uhh", @"Boo", @"Embarass", @"Awkward2", @"Shy", @"Pick Nose", @"Smirk", @"Soldier", @"TooCool", @"Warrior", @"CreepSun", @"CreepMoon", @"HappyDevil", @"UnhappyDevil", @"Doge", @"Piggy" ,@"Alpaca", @"PoopFace", @"Skull", @"Sunglass", @"SmilingSun", @"Night", @"Poop"];
    
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
    NSDictionary *textAttributes = @{@"NSFontAttributeName": [UIFont fontWithName:@"AvenirNext-Regular"
                                                                             size:16.0f],
                                     @"NSForegroundColorAttributeName": isOutGoing ? [UIColor whiteColor] : [UIColor _2499090]
                                     };
    int first = 0;
    for (int i = 0; i < [string length] ; i++) {
        
        char c = [string characterAtIndex:i];
        if(c == '['){
            if(first < i){
                NSString *beforeString = [string substringWithRange:NSMakeRange(first, i - first)];
                [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString: beforeString attributes:textAttributes]];
                first = i;
            }
            int j = i + 1;
            while(j < [string length]){
                char d = [string characterAtIndex:j];
                if(d == ']'){
                    NSString *name = [string substringWithRange:NSMakeRange(i + 1, j - i - 1)];
                    if ([emojiNames containsObject:(name)] ){
                        
                        NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
                        textAttachment.image = [UIImage imageNamed:name];
                        textAttachment.bounds = CGRectMake(0, -5, 21.5, 21);
                        
                        NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
                        
                        [attributedString appendAttributedString:attrStringWithImage];
                        i = j;
                        first = i+1;
                    }
                    break;
                }
                j++;
            }
        }
    }
    if(first < [string length]){
        NSString *beforeString = [string substringWithRange:NSMakeRange(first, [string length] - first)];
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString: beforeString attributes:textAttributes]];
    }
    
    return attributedString;
}

+ (NSString *)shrinkString: (NSString *)string
{
    NSArray *emojiNames =
    @[@"Happy", @"LOL", @"WarmSmile", @"Hehe", @"Smile", @"CrySmile", @"CoverSmile", @"Love", @"Huehue", @"Beauty", @"Wink", @"LoveLove", @"Slurp", @"Kiss", @"Bye", @"WarmBye", @"Heyy", @"Sly", @"Clapclap", @"Cash", @"Stare", @"Blush", @"WowStare", @"Awkward", @"Surprise", @"Scared", @"Opposite", @"Unhappy", @"Sigh", @"welp", @"Sad", @"mmm", @"Please", @"Crying", @"Tears", @"holdtears", @"Waterfall", @"Shush", @"Sick", @"Dizzy", @"DizzyCold", @"Cold", @"Gross", @"Puke", @"Sleepy", @"Yawn", @"Sleeping", @"Snore", @"Slap", @"Pound", @"Burnt", @"Ignore", @"Tantrum", @"Scold", @"Angry", @"Mad", @"Hmm", @"Processing", @"Hesitate", @"Dontknow", @"Wat", @"Thinking", @"Whistle", @"Shhh", @"Hmph", @"Hmph2", @"Speechless", @"Uhh", @"Boo", @"Embarass", @"Awkward2", @"Shy", @"Pick Nose", @"Smirk", @"Soldier", @"TooCool", @"Warrior", @"CreepSun", @"CreepMoon", @"HappyDevil", @"UnhappyDevil", @"Doge", @"Piggy" ,@"Alpaca", @"PoopFace", @"Skull", @"Sunglass", @"SmilingSun", @"Night", @"Poop"];
    
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
    NSDictionary *textAttributes = @{@"NSFontAttributeName": [UIFont fontWithName:@"AvenirNext-Regular"
                                                                             size:16.0f]};
    int first = 0;
    for (int i = 0; i < [string length] ; i++) {
        
        char c = [string characterAtIndex:i];
        if(c == '['){
            if(first < i){
                NSString *beforeString = [string substringWithRange:NSMakeRange(first, i - first)];
                [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString: beforeString attributes:textAttributes]];
                first = i;
            }
            int j = i + 1;
            while(j < [string length]){
                char d = [string characterAtIndex:j];
                if(d == ']'){
                    NSString *name = [string substringWithRange:NSMakeRange(i + 1, j - i - 1)];
                    if ([emojiNames containsObject:(name)] ){
                        
                        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString: [NSString stringWithFormat:@"||||||"] attributes:textAttributes]];

                        i = j;
                        first = i+1;
                    }
                    break;
                }
                j++;
            }
        }
    }
    if(first < [string length]){
        NSString *beforeString = [string substringWithRange:NSMakeRange(first, [string length] - first)];
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString: beforeString attributes:textAttributes]];
    }
    
    
    return [attributedString string];
}



@end
