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
@end


@implementation JSQLocationMediaItemCustom

#pragma mark - Initialization

- (instancetype)initWithLocation:(CLLocation *)location snapImage:(UIImage *)snap
{
    self = [super init];
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
    if (self.location == nil || self.cachedMapSnapshotImage == nil) {
        return nil;
    }
    
    if (self.cachedMapImageView == nil) {
        CGSize size = [self mediaViewDisplaySize];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:self.cachedMapSnapshotImage];
        imageView.frame = CGRectMake(0, 0, size.width, size.height);
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        
        [JSQMessagesMediaViewBubbleImageMaskerCustom applyBubbleImageMaskToMediaView:imageView isOutgoing:self.appliesMediaViewMaskAsOutgoing];
        self.cachedMapImageView = imageView;
    }
    return self.cachedMapImageView;
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
    JSQLocationMediaItemCustom *copy = [[[self class] allocWithZone:zone] initWithLocation:self.location snapImage: _snap];
    copy.appliesMediaViewMaskAsOutgoing = self.appliesMediaViewMaskAsOutgoing;
    return copy;
}

@end
