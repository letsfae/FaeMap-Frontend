//
//  JSQPlaceMediaItemCustom.h
//  faeBeta
//
//  Created by Jichao on 2017/8/23.
//  Copyright © 2017 fae. All rights reserved.
//

#import <JSQMessagesViewController/JSQMediaItem.h>

/**
 *  The `JSQLocationMediaItem` class is a concrete `JSQMediaItem` subclass that implements the `JSQMessageMediaData` protocol
 *  and represents a location media message. An initialized `JSQLocationMediaItem` object can be passed
 *  to a `JSQMediaMessage` object during its initialization to construct a valid media message object.
 *  You may wish to subclass `JSQLocationMediaItem` to provide additional functionality or behavior.
 */
//@interface JSQLocationMediaItemCustom : JSQMediaItem <JSQMessageMediaData, MKAnnotation, NSCoding, NSCopying>

@interface JSQPlaceCollectionMediaItemCustom : JSQMediaItem <JSQMessageMediaData, NSCoding, NSCopying>

@property long itemID;
@property (nonatomic, retain, readwrite) NSString *itemType;

/**
 *  The coordinate of the location property.
 */
@property (nonatomic, retain, readwrite) UIView *cachedSnapImageView;

@property (nonatomic, retain, readwrite) UIImage *cachedSnapshotImage;

@property (nonatomic, retain, readwrite) NSString *title;
@property (nonatomic, retain, readwrite) NSString *subtitle;

@property (nonatomic, retain, readwrite) UILabel *lblTitle;
@property (nonatomic, retain, readwrite) UILabel *lblSubtitle;

@property (nonatomic, retain, readwrite) UILabel *textLabel;
/**
 *  Initializes and returns a location media item object having the given location.
 *
 *  @param location The location for the media item. This value may be `nil`.
 *
 *  @return An initialized `JSQLocationMediaItem` if successful, `nil` otherwise.
 *
 *  @discussion If the location data must be dowloaded from the network,
 *  you may initialize a `JSQLocationMediaItem` object with a `nil` location.
 *  Once the location data has been retrieved, you can then set the location property
 *  using `setLocation: withCompletionHandler:`
 */

- (instancetype)initWithItemID:(long)itemID type:(NSString *)itemType snapImage:(UIImage *)snap text:(NSString *)comment;

@end

