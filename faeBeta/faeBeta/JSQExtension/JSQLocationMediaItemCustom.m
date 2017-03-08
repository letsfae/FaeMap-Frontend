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

#import "JSQLocationMediaItemCustom.h"
#import <JSQMessagesViewController/JSQMessagesMediaPlaceholderView.h>
#import "JSQMessagesMediaViewBubbleImageMaskerCustom.h"


@interface JSQLocationMediaItemCustom ()
@property (nonatomic, strong) UIImage *snap;
@property (nonatomic, strong) NSString *text;
@end


@implementation JSQLocationMediaItemCustom

#pragma mark - Initialization

- (instancetype)initWithLocation:(CLLocation *)location snapImage:(UIImage *)snap
{
    self = [super init];
    _text = @"";
    if (self) {
        [self setLocation:location snapImage: snap withCompletionHandler:nil];
    }
    return self;

}

- (instancetype)initWithLocation:(CLLocation *)location snapImage:(UIImage *)snap text:(NSString *)comment
{
    self = [super init];
    _text = comment;
    _addressLine1 = [[UILabel alloc] initWithFrame:CGRectMake(92, 17, 189, 22)];
    _addressLine2 = [[UILabel alloc] initWithFrame:CGRectMake(92, 37, 189, 16)];
    _addressLine3 = [[UILabel alloc] initWithFrame:CGRectMake(92, 55, 189, 16)];
    if (self) {
        [self setLocation:location snapImage: snap withCompletionHandler:nil];
    }
    return self;
}

- (void)clearCachedMediaViews
{
    [super clearCachedMediaViews];
    _cachedMapImageView = nil;
}

#pragma mark - Setters

- (void)setLocation:(CLLocation *)location snapImage:(UIImage *)snap
{
    [self setLocation:location snapImage:snap withCompletionHandler:nil];
}

- (void)setAppliesMediaViewMaskAsOutgoing:(BOOL)appliesMediaViewMaskAsOutgoing
{
    [super setAppliesMediaViewMaskAsOutgoing:appliesMediaViewMaskAsOutgoing];
    _cachedMapSnapshotImage = nil;
    _cachedMapImageView = nil;
}

- (void)setCachedSnapImage:(UIImage *)cachedSnapImage
{
    self.cachedMapSnapshotImage = cachedSnapImage;
}

#pragma mark - Map snapshot

- (void)setLocation:(CLLocation *)location snapImage:(UIImage *)snap withCompletionHandler:(JSQLocationMediaItemCompletionBlock)completion
{
    self.cachedMapSnapshotImage = snap;
    [self setLocation:location region:MKCoordinateRegionMakeWithDistance(location.coordinate, 500.0, 500.0) withCompletionHandler:completion];
}

- (void)setLocation:(CLLocation *)location region:(MKCoordinateRegion)region withCompletionHandler:(JSQLocationMediaItemCompletionBlock)completion
{
    //_location = [CLLocation init];
    //_location.coordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
    _location = [location copy];
    //    _cachedMapSnapshotImage = nil;
    _cachedMapImageView = nil;
    
    if (_location == nil) {
        return;
    }
    
    [self createMapViewSnapshotForLocation:_location
                          coordinateRegion:region
                     withCompletionHandler:completion];
}

- (void)createMapViewSnapshotForLocation:(CLLocation *)location
                        coordinateRegion:(MKCoordinateRegion)region
                   withCompletionHandler:(JSQLocationMediaItemCompletionBlock)completion
{
    NSParameterAssert(location != nil);
    
    //    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    //    options.region = region;
    //    options.size = [self mediaViewDisplaySize];
    //    options.scale = [UIScreen mainScreen].scale;
    //
    //    MKMapSnapshotter *snapShotter = [[MKMapSnapshotter alloc] initWithOptions:options];
    //
    //    [snapShotter startWithQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    //              completionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
    //                  if (snapshot == nil) {
    //                      NSLog(@"%s Error creating map snapshot: %@", __PRETTY_FUNCTION__, error);
    //                      return;
    //                  }
    //
    //                  MKAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:nil];
    //                  CGPoint coordinatePoint = [snapshot pointForCoordinate:location.coordinate];
    //                  UIImage *image = snapshot.image;
    //
    //                  coordinatePoint.x += pin.centerOffset.x - (CGRectGetWidth(pin.bounds) / 2.0);
    //                  coordinatePoint.y += pin.centerOffset.y - (CGRectGetHeight(pin.bounds) / 2.0);
    //
    //                  UIGraphicsBeginImageContextWithOptions(image.size, YES, image.scale);
    //                  {
    //                      [image drawAtPoint:CGPointZero];
    //                      [pin.image drawAtPoint:coordinatePoint];
    ////                      self.cachedMapSnapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    //                  }
    //                  UIGraphicsEndImageContext();
    //
    //                  if (completion) {
    //                      dispatch_async(dispatch_get_main_queue(), completion);
    //                  }
    //              }];
}

#pragma mark - MKAnnotation

- (CLLocationCoordinate2D)coordinate
{
    return self.location.coordinate;
}

#pragma mark - JSQMessageMediaData protocol

- (UIView *)mediaView
{
    printf("creating media view");
    
    CGFloat height = 0;
    if(![_text isEqualToString:@""] && ![_text isEqualToString:@"[Location]"]) {
        height = [_text boundingRectWithSize:CGSizeMake(273, CGFLOAT_MAX) options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin) attributes:@{ NSFontAttributeName : [UIFont fontWithName:@"Avenir Next" size:17.5]} context:nil].size.height;
    }
    //UIView *locationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 92)];
    
    UIView *locationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, height == 0 ? 92 : 92 + 15 + height)];
    
    locationView.backgroundColor = [UIColor whiteColor];
    
    if(height != 0) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 99, 273, height)];
        _textLabel.font = [UIFont fontWithName:@"Avenir Next" size : 17.5];
        _textLabel.text = _text;
        _textLabel.textColor = [UIColor colorWithRed: 107 / 255.0 green: 105 / 255.0 blue: 105 / 255.0 alpha: 1.0];
        _textLabel.numberOfLines = 0;
        [locationView addSubview:_textLabel];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(12, 92, 276, 1)];
        line.backgroundColor = [UIColor colorWithRed: 234 / 255.0 green: 234 / 255.0 blue: 234 / 255.0 alpha: 1.0];
        
        [locationView addSubview:line];
    }
    
    //_addressLine1 = [[UILabel alloc] initWithFrame:CGRectMake(92, 17, 189, 22)];
    _addressLine1.font = [UIFont fontWithName:@"AvenirNext-Medium" size : 16];
    _addressLine1.text = _address1;
    _addressLine1.textColor = [UIColor colorWithRed: 89 / 255.0 green: 89 / 255.0 blue: 89 / 255.0 alpha: 1.0];
    
    //_addressLine2 = [[UILabel alloc] initWithFrame:CGRectMake(92, 37, 189, 16)];
    _addressLine2.font = [UIFont fontWithName:@"AvenirNext-Medium" size : 12];
    _addressLine2.text = _address2;
    _addressLine2.textColor = [UIColor colorWithRed: 107 / 255.0 green: 105 / 255.0 blue: 105 / 255.0 alpha: 1.0];
    
    //_addressLine3 = [[UILabel alloc] initWithFrame:CGRectMake(92, 55, 189, 16)];
    _addressLine3.font = [UIFont fontWithName:@"AvenirNext-Medium" size : 12];
    _addressLine3.text = _address3;
    _addressLine3.textColor = [UIColor colorWithRed: 107 / 255.0 green: 105 / 255.0 blue: 105 / 255.0 alpha: 1.0];
    
    [locationView addSubview: _addressLine1];
    [locationView addSubview: _addressLine2];
    [locationView addSubview: _addressLine3];

    
    if (self.location == nil || self.cachedMapSnapshotImage == nil) {
        return nil;
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.cachedMapSnapshotImage];
        
    imageView.frame = CGRectMake(13, 13, 66, 66);
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
        
    [locationView addSubview:imageView];
        
    [JSQMessagesMediaViewBubbleImageMaskerCustom applyBubbleImageMaskToMediaView:locationView isOutgoing:self.appliesMediaViewMaskAsOutgoing];
    self.cachedMapImageView = locationView;
    
    printf("done creating media view");
    
    return locationView;
}

- (NSUInteger)mediaHash
{
    return self.hash;
}

- (CGSize) mediaViewDisplaySize
{
    if([_text isEqualToString:@""] || [_text isEqualToString:@"[Location]"]) {
        return CGSizeMake(300, 92);
    } else {
        CGFloat height = [_text boundingRectWithSize:CGSizeMake(273, CGFLOAT_MAX) options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin) attributes:@{ NSFontAttributeName : [UIFont fontWithName:@"Avenir Next" size:17.5]} context:nil].size.height;
        return CGSizeMake(300, 92 + 15 + height);
    }
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object]) {
        return NO;
    }
    
    JSQLocationMediaItemCustom *locationItem = (JSQLocationMediaItemCustom *)object;
    
    return [self.location isEqual:locationItem.location];
}

- (NSUInteger)hash
{
    return super.hash ^ self.location.hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: location=%@, appliesMediaViewMaskAsOutgoing=%@>",
            [self class], self.location, @(self.appliesMediaViewMaskAsOutgoing)];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        CLLocation *location = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(location))];
        [self setLocation:location snapImage: _snap withCompletionHandler:nil];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.location forKey:NSStringFromSelector(@selector(location))];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
//    if([_text isEqualToString:@""]) {
//        JSQLocationMediaItemCustom *copy = [[[self class] allocWithZone:zone] initWithLocation:self.location snapImage: _snap];
//        copy.appliesMediaViewMaskAsOutgoing = self.appliesMediaViewMaskAsOutgoing;
//        return copy;
//    }
//    JSQLocationMediaItemCustom *copy = [[[self class] allocWithZone:zone] initWithLocation:self.location snapImage: _snap text: _text];
//    copy.appliesMediaViewMaskAsOutgoing = self.appliesMediaViewMaskAsOutgoing;
    return nil;
}

@end
