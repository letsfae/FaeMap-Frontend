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

#import "JSQMessagesComposerTextViewCustom.h"

#import <QuartzCore/QuartzCore.h>

#import "NSString+JSQMessages.h"


@implementation JSQMessagesComposerTextViewCustom



#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
//    [super drawRect:rect];

    if ([self.text length] == 0 && self.placeHolder) {
        [self.placeHolderTextColor set];

        [self.placeHolder drawInRect:CGRectInset(rect, 7.0f, 7.0f)
                      withAttributes:[self jsq_placeholderTextAttributes]];
    }
}

#pragma mark - Utilities

- (NSDictionary *)jsq_placeholderTextAttributes
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = self.textAlignment;

    return @{ NSFontAttributeName : self.font,
              NSForegroundColorAttributeName : self.placeHolderTextColor,
              NSParagraphStyleAttributeName : paragraphStyle };
}
@end
