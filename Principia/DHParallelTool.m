//
//  DHParallelTool.m
//  Euclid
//
//  Created by David Hallgren on 2014-08-06.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHGeometricTools.h"
#import "DHMath.h"

@implementation DHParallelTool{
    CGPoint _touchPointInViewStart;
    DHParallelLine* _tempParaLine;
    DHPoint* _tempPoint;
    DHPoint* _tempIntersectionPoint;
    NSString* _tooltipTempUnfinished;
    NSString* _tooltipTempFinished;
    NSString* _toolTipPartial;
}
- (id)init
{
    self = [super init];
    if (self) {
        _tooltipTempUnfinished = @"Drag to a point that the parallel line should pass through";
        _tooltipTempFinished = @"Release to create parallel line";
        _toolTipPartial = @"Tap a point that the parallel line should pass through";
    }
    return self;
}
- (NSString*)initialToolTip
{
    return @"Tap a line you wish to make a line parallel to";
}
- (void)touchBegan:(UITouch*)touch
{
    _touchPointInViewStart = [touch locationInView:touch.view];
    
    CGPoint touchPointInView = [touch locationInView:touch.view];
    CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
    CGFloat geoViewScale = [[self.delegate geoViewTransform] scale];
    NSArray *geoObjects = self.delegate.geometryObjects;
    
    if (self.line == nil) {
        DHLineObject* line = FindLineClosestToPoint(touchPoint, geoObjects, kClosestTapLimit / geoViewScale);
        if (line) {
            self.line = line;
            line.highlighted = YES;
            [self.delegate toolTipDidChange:_tooltipTempUnfinished];
            _tempPoint = [[DHPoint alloc] initWithPosition:touchPoint];
            _tempParaLine = [[DHParallelLine alloc] initWithLine:self.line andPoint:_tempPoint];
            _tempParaLine.temporary = YES;
            [self.delegate addTemporaryGeometricObjects:@[_tempParaLine]];
            [touch.view setNeedsDisplay];
        }
    } else {
        _tempPoint = [[DHPoint alloc] initWithPosition:touchPoint];
        _tempParaLine = [[DHParallelLine alloc] initWithLine:self.line andPoint:_tempPoint];
        _tempParaLine.temporary = YES;
        [self.delegate addTemporaryGeometricObjects:@[_tempParaLine]];
        [self.delegate toolTipDidChange:_tooltipTempUnfinished];
        
        DHPoint* point = FindPointClosestToPoint(touchPoint, geoObjects, kClosestTapLimit / geoViewScale);
        if (!point) {
            point = FindClosestUniqueIntersectionPoint(touchPoint, geoObjects,geoViewScale);
            if (point && point.label.length == 0) {
                _tempIntersectionPoint = point;
                [self.delegate addTemporaryGeometricObjects:@[_tempIntersectionPoint]];
            }
        }
        if (point) {
            _tempParaLine.temporary = NO;
            _tempParaLine.point = point;
            point.highlighted = YES;
            [self.delegate toolTipDidChange:_tooltipTempFinished];
        }
        
        [touch.view setNeedsDisplay];
    }
}
- (void)touchMoved:(UITouch*)touch
{
    CGPoint touchPointInView = [touch locationInView:touch.view];
    CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
    CGFloat geoViewScale = [[self.delegate geoViewTransform] scale];
    NSArray *geoObjects = self.delegate.geometryObjects;
    
    if (_tempIntersectionPoint) {
        [self.delegate removeTemporaryGeometricObjects:@[_tempIntersectionPoint]];
        _tempIntersectionPoint = nil;
    }
    if (_tempParaLine) {
        _tempParaLine.point.highlighted = NO;
        _tempPoint.position = touchPoint;
        _tempParaLine.point = _tempPoint;
        
        DHPoint* point = FindPointClosestToPoint(touchPoint, geoObjects, kClosestTapLimit / geoViewScale);
        if (!point) {
            point = FindClosestUniqueIntersectionPoint(touchPoint, geoObjects,geoViewScale);
            if (point && point.label.length == 0) {
                _tempIntersectionPoint = point;
                [self.delegate addTemporaryGeometricObjects:@[_tempIntersectionPoint]];
            }
        }
        // If still no point, see if there is a point close to the line and snap to it
        if (!point) {
            point = FindPointClosestToLine(_tempParaLine, nil, self.delegate.geometryObjects, 8/geoViewScale);
        }
        
        if (point) {
            _tempParaLine.temporary = NO;
            _tempParaLine.point = point;
            point.highlighted = YES;
            [self.delegate toolTipDidChange:_tooltipTempFinished];
        } else {
            _tempParaLine.temporary = YES;
            [self.delegate toolTipDidChange:_tooltipTempUnfinished];
        }
        [touch.view setNeedsDisplay];
    }
}
- (void)touchEnded:(UITouch*)touch
{
    CGPoint touchPointInView = [touch locationInView:touch.view];
    NSMutableArray* objectsToAdd = [[NSMutableArray alloc] initWithCapacity:2];
    
    if (_tempParaLine) {
        _tempParaLine.highlighted = NO;
        if (_tempParaLine.point == _tempPoint) {
            if(DistanceBetweenPoints(_touchPointInViewStart, touchPointInView) > kClosestTapLimit) {
                [self reset];
            } else {
                [self.delegate toolTipDidChange:_toolTipPartial];
            }
        } else {
            [objectsToAdd addObject:_tempParaLine];
            if (_tempIntersectionPoint) {
                [objectsToAdd addObject:_tempIntersectionPoint];
            }
            [self reset];
        }
    }
    [self resetTemporaryObjects];
    
    if (objectsToAdd.count > 0) {
        [self.delegate addGeometricObjects:objectsToAdd];
    }
    [touch.view setNeedsDisplay];
    
}
- (BOOL)active
{
    if (self.line) {
        return YES;
    }
    
    return NO;
}
- (void)reset
{
    [self resetTemporaryObjects];
    
    self.line.highlighted = NO;
    self.line = nil;
    [self.delegate toolTipDidChange:self.initialToolTip];
    self.associatedTouch = 0;
}
- (void)resetTemporaryObjects
{
    if (_tempIntersectionPoint) {
        [self.delegate removeTemporaryGeometricObjects:@[_tempIntersectionPoint]];
        _tempIntersectionPoint = nil;
    }
    if (_tempParaLine) {
        _tempParaLine.point.highlighted = NO;
        [self.delegate removeTemporaryGeometricObjects:@[_tempParaLine]];
        _tempParaLine = nil;
        _tempPoint = nil;
    }
}
- (void)dealloc
{
    [self resetTemporaryObjects];
    
    self.line.highlighted = NO;
}@end
