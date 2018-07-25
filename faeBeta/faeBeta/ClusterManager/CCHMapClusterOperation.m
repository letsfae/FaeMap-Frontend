//
//  CCHMapClusterOperation.m
//  CCHMapClusterController
//
//  Copyright (C) 2014 Claus Höfele
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "CCHMapClusterOperation.h"

#import "CCHMapTree.h"
#import "CCHMapClusterAnnotation.h"
#import "CCHMapClusterControllerUtils.h"
#import "CCHMapClusterer.h"
#import "CCHMapAnimator.h"
#import "CCHMapClusterControllerDelegate.h"

#define fequal(a, b) (fabs((a) - (b)) < __FLT_EPSILON__)

@interface CCHMapClusterOperation()

@property (nonatomic) MKMapView *mapView;
@property (nonatomic) double cellMapSize;
@property (nonatomic) double marginFactor;
@property (nonatomic) MKMapRect mapViewVisibleMapRect;
@property (nonatomic) MKCoordinateRegion mapViewRegion;
@property (nonatomic) CGFloat mapViewWidth;
@property (nonatomic, copy) NSArray *mapViewAnnotations;
@property (nonatomic) BOOL reuseExistingClusterAnnotations;
@property (nonatomic) double maxZoomLevelForClustering;
@property (nonatomic) NSUInteger minUniqueLocationsForClustering;

@property (nonatomic, getter = isExecuting) BOOL executing;
@property (nonatomic, getter = isFinished) BOOL finished;

@end

@implementation CCHMapClusterOperation

@synthesize executing = _executing;
@synthesize finished = _finished;

- (instancetype)initWithMapView:(MKMapView *)mapView cellSize:(double)cellSize marginFactor:(double)marginFactor reuseExistingClusterAnnotations:(BOOL)reuseExistingClusterAnnotation maxZoomLevelForClustering:(double)maxZoomLevelForClustering minUniqueLocationsForClustering:(NSUInteger)minUniqueLocationsForClustering
{
    self = [super init];
    if (self) {
        _mapView = mapView;
        _cellMapSize = [self.class cellMapSizeForCellSize:cellSize withMapView:mapView];
        _marginFactor = marginFactor;
        _mapViewVisibleMapRect = mapView.visibleMapRect;
        _mapViewRegion = mapView.region;
        _mapViewWidth = mapView.bounds.size.width;
        _mapViewAnnotations = mapView.annotations;
        _reuseExistingClusterAnnotations = reuseExistingClusterAnnotation;
        _maxZoomLevelForClustering = maxZoomLevelForClustering;
        _minUniqueLocationsForClustering = minUniqueLocationsForClustering;
        
        _executing = NO;
        _finished = NO;
    }
    
    return self;
}

+ (double)cellMapSizeForCellSize:(double)cellSize withMapView:(MKMapView *)mapView
{
    // World size is multiple of cell size so that cells wrap around at the 180th meridian
    double cellMapSize = CCHMapClusterControllerMapLengthForLength(mapView, mapView.superview, cellSize);
    cellMapSize = CCHMapClusterControllerAlignMapLengthToWorldWidth(cellMapSize);
    
    return cellMapSize;
}

+ (MKMapRect)gridMapRectForMapRect:(MKMapRect)mapRect withCellMapSize:(double)cellMapSize marginFactor:(double)marginFactor
{
    // Expand map rect and align to cell size to avoid popping when panning
    MKMapRect gridMapRect = MKMapRectInset(mapRect, -marginFactor * mapRect.size.width, -marginFactor * mapRect.size.height);
    gridMapRect = CCHMapClusterControllerAlignMapRectToCellSize(gridMapRect, cellMapSize);
    
    return gridMapRect;
}

- (void)start
{
    self.executing = YES;
    double zoomLevelToDisableSmallerCellRect = 14.5;
    double zoomLevel = CCHMapClusterControllerZoomLevelForRegion(self.mapViewRegion.center.longitude, self.mapViewRegion.span.longitudeDelta, self.mapViewWidth);
    BOOL disableClustering = (zoomLevel > self.maxZoomLevelForClustering);
    if (self.forPlacePin) {
        disableClustering = (zoomLevel > 18);
    }
    if (self.isClusteringDisabled) {
        disableClustering = true;
    }
    BOOL shouldUseFullCellRect = zoomLevel >= zoomLevelToDisableSmallerCellRect || self.isFullMapRectEnabled || !self.forPlacePin;
    BOOL respondsToSelector = [_clusterControllerDelegate respondsToSelector:@selector(mapClusterController:willReuseMapClusterAnnotation:fullAnnotationSet:findSelectedPin:)];
    //printf("[zoom level] %.3f\n", zoomLevel);
    // For each cell in the grid, pick one cluster annotation to show
    MKMapRect gridMapRect = [self.class gridMapRectForMapRect:self.mapViewVisibleMapRect withCellMapSize:self.cellMapSize marginFactor:self.marginFactor];
    NSMutableSet *clusters = [NSMutableSet set];
    CCHMapClusterControllerEnumerateCells(gridMapRect, _cellMapSize, ^(MKMapRect cellMapRect, MKMapRect fullCellMapRect) {
        NSSet *allAnnotationsInCell;
        NSSet *allAnnotationsInCellInFull;
        if (shouldUseFullCellRect) {
            allAnnotationsInCell = [self->_allAnnotationsMapTree annotationsInMapRect:fullCellMapRect];
            allAnnotationsInCellInFull = allAnnotationsInCell;
        } else {
            allAnnotationsInCell = [self->_allAnnotationsMapTree annotationsInMapRect:cellMapRect];
            allAnnotationsInCellInFull = [self->_allAnnotationsMapTree annotationsInMapRect:fullCellMapRect];
        }
        if (allAnnotationsInCell.count > 0) {
            BOOL annotationSetsAreUniqueLocations;
            NSArray *annotationSets;
            NSArray *annotationSetsInFull;
            if (disableClustering) {
                // Create annotation for each unique location because clustering is disabled
                annotationSets = CCHMapClusterControllerAnnotationSetsByUniqueLocations(allAnnotationsInCell, NSUIntegerMax);
                annotationSetsAreUniqueLocations = YES;
                if (shouldUseFullCellRect) {
                    annotationSetsInFull = annotationSets;
                } else {
                    annotationSetsInFull = CCHMapClusterControllerAnnotationSetsByUniqueLocations(allAnnotationsInCellInFull, NSUIntegerMax);
                }
            } else {
                NSUInteger max = self->_minUniqueLocationsForClustering > 1 ? self->_minUniqueLocationsForClustering - 1 : 1;
                annotationSets = CCHMapClusterControllerAnnotationSetsByUniqueLocations(allAnnotationsInCell, max);
                if (shouldUseFullCellRect) {
                    annotationSetsInFull = annotationSets;
                } else {
                    annotationSetsInFull = CCHMapClusterControllerAnnotationSetsByUniqueLocations(allAnnotationsInCellInFull, max);
                }
                if (annotationSets) {
                    // Create annotation for each unique location because there are too few locations for clustering
                    annotationSetsAreUniqueLocations = YES;
                } else {
                    // Create one annotation for entire cell
                    annotationSets = @[allAnnotationsInCell];
                    annotationSetsInFull = @[allAnnotationsInCellInFull];
                    annotationSetsAreUniqueLocations = NO;
                }
            }
            
            CLLocationCoordinate2D selectedAnnotationCoordinate = CLLocationCoordinate2DMake(0, 0);
            BOOL selectedAnnotationFound = NO;
            NSSet *annotationSetInFull;
            for (NSSet *annotationSet in annotationSetsInFull) {
                annotationSetInFull = annotationSet;
                if (annotationSetsAreUniqueLocations) {
                    selectedAnnotationFound = NO;
                } else {
                    IsSelectedCoordinate returnVal = [self->_clusterer mapClusterController:self->_clusterController coordinateForAnnotations:annotationSet inMapRect:fullCellMapRect];
                    if (returnVal.isSelected) {
                        selectedAnnotationFound = YES;
                        selectedAnnotationCoordinate = returnVal.coordinate;
                        break;
                    }
                }
            }
            //int count = 0;
            for (NSSet *annotationSet in annotationSets) {
                //printf("annotationSet count: %d\n",count);
                //count = count + 1;
                CLLocationCoordinate2D coordinate;
                BOOL isSelected = NO;
                if (annotationSetsAreUniqueLocations) {
                    coordinate = [annotationSet.anyObject coordinate];
                } else if (selectedAnnotationFound) {
                    coordinate = selectedAnnotationCoordinate;
                    isSelected = YES;
                } else {
                    IsSelectedCoordinate returnVal = [self->_clusterer mapClusterController:self->_clusterController coordinateForAnnotations:annotationSet inMapRect:cellMapRect];
                    coordinate = returnVal.coordinate;
                    isSelected = returnVal.isSelected;
                }
                
                NSMutableSet *visibleAnnotationsInCell = [NSMutableSet setWithSet:[self->_visibleAnnotationsMapTree annotationsInMapRect:fullCellMapRect]];
                CCHMapClusterAnnotation *annotationForCell;
                if (self->_reuseExistingClusterAnnotations) {
                    // Check if an existing cluster annotation can be reused
                    for (CCHMapClusterAnnotation *visibleAnnotation in visibleAnnotationsInCell) {
                        BOOL coordinateMatches = fequal(coordinate.latitude, visibleAnnotation.coordinate.latitude) && fequal(coordinate.longitude, visibleAnnotation.coordinate.longitude);
                        if (coordinateMatches) {
                            annotationForCell = visibleAnnotation;
                            break;
                        }
                    }
                }
                
                if (annotationForCell == nil) {
                    // Create new cluster annotation
                    annotationForCell = [[CCHMapClusterAnnotation alloc] init];
                    annotationForCell.mapClusterController = self->_clusterController;
                    annotationForCell.delegate = self->_clusterControllerDelegate;
                    annotationForCell.annotations = annotationSet;
                    annotationForCell.coordinate = coordinate;
                    if (self.shouldAddNewClusterAnnotation) {
                        [clusters addObject:annotationForCell];
                    }
                } else {
                    // For an existing cluster annotation, this will implicitly update its annotation view
//                    BOOL hasPreviousRepresentative = NO;
//                    if ([annotationForCell.annotations containsObject:annotationForCell.representative]) {
//                        hasPreviousRepresentative = YES;
//                    }
//
                    if (self.isZoomingOut || !self.forPlacePin || self.isForcedRefresh) {
                        if (!self.isVisibleAnnotationRemovingBlocked) {
                            if (self.shouldAddNewClusterAnnotation) {
                                [visibleAnnotationsInCell removeObject:annotationForCell];
                            }
                        }
                    }
                    annotationForCell.annotations = annotationSet;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (annotationSetsAreUniqueLocations) {
                            annotationForCell.coordinate = coordinate;
                        }
//                        else if ([annotationForCell.annotations containsObject:annotationForCell.representative]) {
//                            //printf("[annotationForCell] contains representative\n");
//                            annotationForCell.coordinate = annotationForCell.representative.coordinate;
//                        }
                        if (respondsToSelector) {
                            [self->_clusterControllerDelegate mapClusterController:self->_clusterController willReuseMapClusterAnnotation:annotationForCell fullAnnotationSet:annotationSetInFull findSelectedPin:isSelected];
                        }
                    });
                    // if is zooming out or panning
                    // or is user cluster manager
                    // or is forced refresh trigerred
                    if (self.isZoomingOut || !self.forPlacePin || self.isForcedRefresh) {
                        if (!self.isVisibleAnnotationRemovingBlocked) {
                            if (self.shouldAddNewClusterAnnotation) {
                                [clusters addObject:annotationForCell];
                            }
                        }
                    }
                }
            }
        }
    });
    
    // Figure out difference between new and old clusters
    NSSet *annotationsBeforeAsSet = CCHMapClusterControllerClusterAnnotationsForAnnotations(self.mapViewAnnotations, self.clusterController);
    NSMutableSet *annotationsToKeep = [NSMutableSet setWithSet:annotationsBeforeAsSet];
    [annotationsToKeep intersectSet:clusters];
    NSMutableSet *annotationsToAddAsSet = [NSMutableSet setWithSet:clusters];
    [annotationsToAddAsSet minusSet:annotationsToKeep];
    NSArray *annotationsToAdd = [annotationsToAddAsSet allObjects];
    NSMutableSet *annotationsToRemoveAsSet = [NSMutableSet setWithSet:annotationsBeforeAsSet];
    if (self.isZoomingOut || !self.forPlacePin || self.isForcedRefresh) {
        if (!self.isVisibleAnnotationRemovingBlocked) {
            [annotationsToRemoveAsSet minusSet:clusters];
        } else {
            [annotationsToRemoveAsSet minusSet:annotationsBeforeAsSet];
        }
    } else {
        [annotationsToRemoveAsSet minusSet:annotationsBeforeAsSet];
    }
    NSArray *annotationsToRemove = [annotationsToRemoveAsSet allObjects];

    // Show cluster annotations on map
    [_visibleAnnotationsMapTree removeAnnotations:annotationsToRemove];
    [_visibleAnnotationsMapTree addAnnotations:annotationsToAdd];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mapView addAnnotations:annotationsToAdd];
        [self.animator mapClusterController:self.clusterController willRemoveAnnotations:annotationsToRemove withCompletionHandler:^{
            [self.mapView removeAnnotations:annotationsToRemove];
            self.executing = NO;
            self.finished = YES;
        }];
    });
}

- (void)setExecuting:(BOOL)executing
{
    [self willChangeValueForKey:@"isExecuting"];
    _executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)setFinished:(BOOL)finished
{
    [self willChangeValueForKey:@"isFinished"];
    _finished = YES;
    [self didChangeValueForKey:@"isFinished"];
}

@end
