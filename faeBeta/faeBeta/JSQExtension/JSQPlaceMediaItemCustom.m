//
//  JSQPlaceMediaItemCustom.m
//  faeBeta
//
//  Created by Jichao on 2017/8/23.
//  Copyright © 2017 fae. All rights reserved.
//

#import "JSQPlaceMediaItemCustom.h"
#import <JSQMessagesViewController/JSQMessagesMediaPlaceholderView.h>
#import "JSQMessagesMediaViewBubbleImageMaskerCustom.h"
#import "faeBeta-Swift.h"

@interface JSQPlaceMediaItemCustom ()
@property (nonatomic, strong) UIImage *snap;
@property (nonatomic, strong) NSString *text;
@end


@implementation JSQPlaceMediaItemCustom

#pragma mark - Initialization

- (instancetype)initWithPlace:(PlacePin *)place snapImage:(UIImage *)snap text:(NSString *)comment
{
    self = [super init];
    //_place = [place copy];
    _place = place;
    _text = comment;
    _placeName = place.name;
    _placeAddress = [NSString stringWithFormat:@"%@, %@", place.address1, place.address2 ];
    _lblPlaceName = [[UILabel alloc] initWithFrame:CGRectMake(92, 27, 195, 22)];
    _lblPlaceAddress = [[UILabel alloc] initWithFrame:CGRectMake(92, 49, 195, 16)];
    if (self) {
        [self setCachedSnapImage:place snapImage: snap];
    }
    return self;
}

- (void)clearCachedMediaViews
{
    [super clearCachedMediaViews];
    _cachedPlaceImageView = nil;
}

#pragma mark - Setters

- (void)setCachedSnapImage:(PlacePin *)place snapImage:(UIImage *)cachedSnapImage
{
    self.cachedPlaceSnapshotImage = cachedSnapImage;
}

- (void)setAppliesMediaViewMaskAsOutgoing:(BOOL)appliesMediaViewMaskAsOutgoing
{
    [super setAppliesMediaViewMaskAsOutgoing:appliesMediaViewMaskAsOutgoing];
    _cachedPlaceSnapshotImage = nil;
    _cachedPlaceImageView = nil;
}

#pragma mark - JSQMessageMediaData protocol

- (UIView *)mediaView
{
    if (self.place == nil) {
        return nil;
    }
    
    CGFloat height = 0;
    //BRYAN: Not empty and not location
    if (![_text isEqualToString:@""] && ![_text isEqualToString:@"[Place]"]) {
        height = [_text boundingRectWithSize:CGSizeMake(273, CGFLOAT_MAX) options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin) attributes:@{ NSFontAttributeName : [UIFont fontWithName:@"Avenir Next" size:17.5]} context:nil].size.height;
    }
    //UIView *locationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 92)];
    
    UIView *placeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, height == 0 ? 92 : 92 + 15 + height)];
    
    placeView.backgroundColor = [UIColor whiteColor];
    
    if (height != 0) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 96, 271, height)];
        _textLabel.font = [UIFont fontWithName:@"Avenir Next" size : 17.5];
        _textLabel.text = _text;
        _textLabel.textColor = [UIColor colorWithRed: 107 / 255.0 green: 105 / 255.0 blue: 105 / 255.0 alpha: 1.0];
        _textLabel.numberOfLines = 0;
        [placeView addSubview:_textLabel];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 90, 271, 1)];
        line.backgroundColor = [UIColor colorWithRed: 234 / 255.0 green: 234 / 255.0 blue: 234 / 255.0 alpha: 1.0];
        
        [placeView addSubview:line];
    }
    
    _lblPlaceName.font = [UIFont fontWithName:@"AvenirNext-Medium" size : 16];
    _lblPlaceName.text = _placeName;
    _lblPlaceName.textColor = [UIColor colorWithRed: 89 / 255.0 green: 89 / 255.0 blue: 89 / 255.0 alpha: 1.0];
    
    _lblPlaceAddress.font = [UIFont fontWithName:@"AvenirNext-Medium" size : 12];
    _lblPlaceAddress.text = _placeAddress;
    _lblPlaceAddress.textColor = [UIColor colorWithRed: 107 / 255.0 green: 105 / 255.0 blue: 105 / 255.0 alpha: 1.0];
    
    [placeView addSubview: _lblPlaceName];
    [placeView addSubview: _lblPlaceAddress];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.cachedPlaceSnapshotImage];
    
    imageView.frame = CGRectMake(16, 16, 63, 63);
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    
    [placeView addSubview:imageView];
    
    [JSQMessagesMediaViewBubbleImageMaskerCustom applyBubbleImageMaskToMediaView:placeView isOutgoing:self.appliesMediaViewMaskAsOutgoing];
    self.cachedPlaceImageView = placeView;
    
    //printf("done creating media view");
    
    return placeView;
}

- (NSUInteger)mediaHash
{
    return self.hash;
}

- (CGSize) mediaViewDisplaySize
{
    if([_text isEqualToString:@""] || [_text isEqualToString:@"[Place]"]) {
        return CGSizeMake(300, 92);
    } else {
        CGFloat height = [_text boundingRectWithSize:CGSizeMake(291, CGFLOAT_MAX) options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin) attributes:@{ NSFontAttributeName : [UIFont fontWithName:@"Avenir Next" size:17.5]} context:nil].size.height;
        return CGSizeMake(300, 92 + 15 + height);
    }
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object]) {
        return NO;
    }
    
    JSQPlaceMediaItemCustom *placeItem = (JSQPlaceMediaItemCustom *)object;
    
    return [self.place isEqual:placeItem.place];
}

- (NSUInteger)hash
{
    return super.hash ^ self.place.hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: place=%@, appliesMediaViewMaskAsOutgoing=%@>",
            [self class], self.place, @(self.appliesMediaViewMaskAsOutgoing)];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _place = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(place))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.place forKey:NSStringFromSelector(@selector(place))];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    /*JSQPlaceMediaItemCustom *copy = [[JSQPlaceMediaItemCustom allocWithZone:zone] initWithPlace:self.place snapImage:self.cachedPlaceSnapshotImage text:self.text];
    copy.appliesMediaViewMaskAsOutgoing = self.appliesMediaViewMaskAsOutgoing;
    return copy;*/
    return nil;
}

@end
