//
//  DHLevelPerpendicularB.h
//  Euclid
//
//  Created by David Hallgren on 2014-07-04.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DHLevel.h"

@interface DHLevelPerpendicularB : DHLevel <DHLevel>

- (NSString*)levelDescription;
- (void)createInitialObjects:(NSMutableArray *)geometricObjects;
- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects;

@end