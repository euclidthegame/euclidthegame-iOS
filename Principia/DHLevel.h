//
//  DHLevel.h
//  Principia
//
//  Created by David Hallgren on 2014-06-24.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DHGeometricObjects.h"

@protocol DHLevel <NSObject>

- (NSString*)levelTitle;
- (NSString*)levelDescription;
- (void)setUpLevel:(NSMutableArray*)geometricObjects;
- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects;

@end
