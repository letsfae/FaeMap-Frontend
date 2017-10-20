//
//  JSQPlaceMediaItemCustom.m
//  faeBeta
//
//  Created by Jichao on 2017/8/23.
//  Copyright © 2017 fae. All rights reserved.
//

#import "JSQPlaceCollectionMediaItemCustom.h"
#import <JSQMessagesViewController/JSQMessagesMediaPlaceholderView.h>
#import "JSQMessagesMediaViewBubbleImageMaskerCustom.h"
#import "faeBeta-Swift.h"

@interface JSQPlaceCollectionMediaItemCustom()
@property (nonatomic, strong) UIImage *snap;
@property (nonatomic, strong) NSString *text;
@end


@implementation JSQPlaceCollectionMediaItemCustom

#pragma mark - Initialization

- (instancetype)initWithItemID:(long)itemID type: (NSString *)itemType snapImage:(UIImage *)snap text:(NSString *)comment
{
    self = [super init];
    //_place = [place copy];
    _itemID = itemID;
    _itemType = itemType;
    _text = comment;
    _lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(92, 27, 195, 22)];
    _lblSubtitle = [[UILabel alloc] initWithFrame:CGRectMake(92, 49, 195, 16)];
    if (self) {
        [self setCachedSnapImage: snap];
    }
    return self;
}

- (void)clearCachedMediaViews
{
    [super clearCachedMediaViews];
    _cachedSnapImageView = nil;
}

#pragma mark - Setters

- (void)setCachedSnapImage:(UIImage *)cachedSnapImage
{
    self.cachedSnapshotImage = cachedSnapImage;
}

- (void)setAppliesMediaViewMaskAsOutgoing:(BOOL)appliesMediaViewMaskAsOutgoing
{
    [super setAppliesMediaViewMaskAsOutgoing:appliesMediaViewMaskAsOutgoing];
    _cachedSnapshotImage = nil;
    _cachedSnapImageView = nil;
}

#pragma mark - JSQMessageMediaData protocol

- (UIView *)mediaView
{
    if (self.itemID < 0) {
        return nil;
    }
    
    CGFloat height = 0;
    //BRYAN: Not empty and not location
    //if (![_text isEqualToString:@""] && ![_text isEqualToString:@"[Place]"]) {
    if (![_text isEqualToString:@""]) {
        height = [_text boundingRectWithSize:CGSizeMake(273, CGFLOAT_MAX) options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin) attributes:@{ NSFontAttributeName : [UIFont fontWithName:@"Avenir Next" size:17.5]} context:nil].size.height;
    }
    //UIView *locationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 92)];
    
    UIView *uiviewPlaceCollection = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, height == 0 ? 92 : 92 + 15 + height)];
    
    uiviewPlaceCollection.backgroundColor = [UIColor whiteColor];
    
    if (height != 0) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 96, 271, height)];
        _textLabel.font = [UIFont fontWithName:@"Avenir Next" size : 17.5];
        _textLabel.text = _text;
        _textLabel.textColor = [UIColor colorWithRed: 107 / 255.0 green: 105 / 255.0 blue: 105 / 255.0 alpha: 1.0];
        _textLabel.numberOfLines = 0;
        [uiviewPlaceCollection addSubview:_textLabel];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 90, 271, 1)];
        line.backgroundColor = [UIColor colorWithRed: 234 / 255.0 green: 234 / 255.0 blue: 234 / 255.0 alpha: 1.0];
        
        [uiviewPlaceCollection addSubview:line];
    }
    
    _lblTitle.font = [UIFont fontWithName:@"AvenirNext-Medium" size : 16];
    _lblTitle.text = _title;
    _lblTitle.textColor = [UIColor colorWithRed: 89 / 255.0 green: 89 / 255.0 blue: 89 / 255.0 alpha: 1.0];
    
    _lblSubtitle.font = [UIFont fontWithName:@"AvenirNext-Medium" size : 12];
    _lblSubtitle.text = _subtitle;
    _lblSubtitle.textColor = [UIColor colorWithRed: 107 / 255.0 green: 105 / 255.0 blue: 105 / 255.0 alpha: 1.0];
    
    [uiviewPlaceCollection addSubview: _lblTitle];
    [uiviewPlaceCollection addSubview: _lblSubtitle];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.cachedSnapshotImage];
    
    imageView.frame = CGRectMake(16, 16, 63, 63);
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    
    [uiviewPlaceCollection addSubview:imageView];
    
    [JSQMessagesMediaViewBubbleImageMaskerCustom applyBubbleImageMaskToMediaView:uiviewPlaceCollection isOutgoing:self.appliesMediaViewMaskAsOutgoing];
    self.cachedSnapImageView = uiviewPlaceCollection;
    
    //printf("done creating media view");
    
    return uiviewPlaceCollection;
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
    
    JSQPlaceCollectionMediaItemCustom *item = (JSQPlaceCollectionMediaItemCustom *)object;
    
    return self.itemID = item.itemID && [self.itemType isEqual:item.itemType];
}

- (NSUInteger)hash
{
    return super.hash ^ self.itemID ^ self.itemType.hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: id=%ld, type=%@, appliesMediaViewMaskAsOutgoing=%@>",
            [self class], self.itemID, self.itemType, @(self.appliesMediaViewMaskAsOutgoing)];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        //_place = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(place))];
        _itemID = [aDecoder decodeIntegerForKey:@"itemID"];
        _itemType = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(itemType))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    //[aCoder encodeObject:self.place forKey:NSStringFromSelector(@selector(place))];
    [aCoder encodeInteger:self.itemID forKey:(@"itemID")];
    [aCoder encodeObject:self.itemType forKey:NSStringFromSelector(@selector(itemType))];
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
