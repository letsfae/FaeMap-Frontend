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

#import "JSQVideoMediaItemCustom.h"

#import <JSQMessagesViewController/JSQMessagesMediaPlaceholderView.h>
#import "JSQMessagesMediaViewBubbleImageMaskerCustom.h"

#import <JSQMessagesViewController/UIImage+JSQMessages.h>


@interface JSQVideoMediaItemCustom ()

@property (strong, nonatomic) UIImageView *cachedVideoImageView;
@property (nonatomic) int videoDuration;

@end


@implementation JSQVideoMediaItemCustom

#pragma mark - Initialization

- (instancetype)initWithFileURL:(NSURL *)fileURL snapImage: (UIImage *)image duration:(int)duration isReadyToPlay:(BOOL)isReadyToPlay
{
    self = [super init];
    if (self) {
        _fileURL = [fileURL copy];
        _isReadyToPlay = isReadyToPlay;
        _cachedVideoImageView = nil;
        _snapImage = image;
        _videoDuration = duration;
    }
    return self;
}

- (void)clearCachedMediaViews
{
    [super clearCachedMediaViews];
    _cachedVideoImageView = nil;
}

#pragma mark - Setters

- (void)setFileURL:(NSURL *)fileURL
{
    _fileURL = [fileURL copy];
    _cachedVideoImageView = nil;
}

- (void)setIsReadyToPlay:(BOOL)isReadyToPlay
{
    _isReadyToPlay = isReadyToPlay;
    _cachedVideoImageView = nil;
}

- (void)setAppliesMediaViewMaskAsOutgoing:(BOOL)appliesMediaViewMaskAsOutgoing
{
    [super setAppliesMediaViewMaskAsOutgoing:appliesMediaViewMaskAsOutgoing];
    _cachedVideoImageView = nil;
}

#pragma mark - JSQMessageMediaData protocol

- (UIView *)mediaView
{
    if (self.fileURL == nil || !self.isReadyToPlay) {
        return nil;
    }
    
    if (self.cachedVideoImageView == nil) {
        CGSize size = [self mediaViewDisplaySize];
        UIImage *playIcon = [UIImage imageNamed:@"videoPlayButtonIcon"];
        
        UIImageView *imageView ;
        if(self.snapImage != nil){
            //UIGraphicsBeginImageContext(size);
            UIGraphicsBeginImageContextWithOptions(size, false, 20);
            [self.snapImage drawInRect:CGRectMake(0,0,size.width, size.height)];
            [playIcon drawInRect:CGRectMake(size.width / 2 - playIcon.size.width / 2, size.height / 2 - playIcon.size.height / 2 - 5,playIcon.size.width,playIcon.size.height)];
            //[playIcon drawInRect:CGRectMake(size.width / 2 - 25, size.height / 2 - 25 - 5,50,50)];
            UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
            
            UIGraphicsEndImageContext();
            imageView = [[UIImageView alloc] initWithImage:finalImage];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
        }
        else{
            imageView = [[UIImageView alloc] initWithImage:playIcon];
            imageView.backgroundColor = [UIColor blackColor];
        }

        UIView *videoIndicatorView = [[UIView alloc] initWithFrame:CGRectMake(0, size.height - 30.f, size.width, 30.0f)];
        videoIndicatorView.backgroundColor = [[UIColor alloc] initWithRed:58.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:0.8];
        
        UIImage *cameraIcon = [UIImage imageNamed:@"cameraIconFilled_white"];
        UIImageView* cameraIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(25, 8, 18, 12)];
        cameraIconImageView.image = cameraIcon;
        [videoIndicatorView addSubview:cameraIconImageView];
        
        NSString *secondString = (self.videoDuration % 60) < 9 ? [NSString stringWithFormat:@"0%d", self.videoDuration % 60 ] : [NSString stringWithFormat:@"%d", self.videoDuration % 60 ];
        NSString *minString = [NSString stringWithFormat:@"%d", self.videoDuration / 60 ];
        NSString *durationString = [NSString stringWithFormat:@"%@:%@", minString, secondString];
        UILabel * durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(51, 5, 36, 18)];
        durationLabel.attributedText = [[NSAttributedString alloc] initWithString:durationString attributes:@{ NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f] , NSForegroundColorAttributeName: [UIColor whiteColor]}];
        durationLabel.textAlignment = NSTextAlignmentLeft;
        [videoIndicatorView addSubview:durationLabel];
        
        imageView.frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
        [imageView addSubview:videoIndicatorView];
        imageView.contentMode = UIViewContentModeCenter;
        imageView.clipsToBounds = YES;
        [JSQMessagesMediaViewBubbleImageMaskerCustom applyBubbleImageMaskToMediaView:imageView isOutgoing:self.appliesMediaViewMaskAsOutgoing];
        self.cachedVideoImageView = imageView;
    }
    
    return self.cachedVideoImageView;
}

- (NSUInteger)mediaHash
{
    return self.hash;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object]) {
        return NO;
    }
    
    JSQVideoMediaItemCustom *videoItem = (JSQVideoMediaItemCustom *)object;
    
    return [self.fileURL isEqual:videoItem.fileURL]
            && self.isReadyToPlay == videoItem.isReadyToPlay;
}

- (NSUInteger)hash
{
    return super.hash ^ self.fileURL.hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: fileURL=%@, isReadyToPlay=%@, appliesMediaViewMaskAsOutgoing=%@>",
            [self class], self.fileURL, @(self.isReadyToPlay), @(self.appliesMediaViewMaskAsOutgoing)];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _fileURL = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(fileURL))];
        _isReadyToPlay = [aDecoder decodeBoolForKey:NSStringFromSelector(@selector(isReadyToPlay))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.fileURL forKey:NSStringFromSelector(@selector(fileURL))];
    [aCoder encodeBool:self.isReadyToPlay forKey:NSStringFromSelector(@selector(isReadyToPlay))];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    JSQVideoMediaItemCustom *copy = [[[self class] allocWithZone:zone] initWithFileURL:self.fileURL snapImage: self.snapImage duration:self.videoDuration isReadyToPlay:self.isReadyToPlay];
    copy.appliesMediaViewMaskAsOutgoing = self.appliesMediaViewMaskAsOutgoing;
    return copy;
}

@end
