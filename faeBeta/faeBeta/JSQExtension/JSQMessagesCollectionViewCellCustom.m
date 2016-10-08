//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQMessagesViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQMessagesViewController
//
//
//  License
//  Copyright (c) 2014 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "JSQMessagesCollectionViewCellCustom.h"

@implementation JSQMessagesCollectionViewCellCustom

#pragma mark - Collection view cell

- (void)prepareForReuse
{
    [super prepareForReuse];
}

-(BOOL) canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(copy:) ||( (self.contentType == Picture || self.contentType == Sticker) && action == @selector(customAction1:))) {
        return YES;
    }
    return NO;
}

- (void)customAction1: (id)sender{
    printf("custom");
}

@end
