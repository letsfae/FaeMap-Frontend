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

#import <UIKit/UIKit.h>

#import <JSQMessagesViewController/JSQMessagesCollectionViewCell.h>

@class JSQMessagesCollectionViewCellCustom;

typedef enum CONTENT_TYPE CONTENT_TYPE;
enum CONTENT_TYPE {
    Text,
    Picture,
    Sticker,
    Location,
    Audio
};

@interface JSQMessagesCollectionViewCellCustom : JSQMessagesCollectionViewCell

@property CONTENT_TYPE contentType;

@end
