//
//  DHLevelPlayground.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-13.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelPlayground.h"


@implementation DHLevelPlayground

- (NSString*)subTitle
{
    return @"Playground";
}

- (NSString*)levelDescription
{
    return (@"Play");
}

- (DHToolsAvailable)availableTools
{
    return (DHAllToolsAvailable);
}

- (NSUInteger)minimumNumberOfMoves
{
    return 10;
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{

}

- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects
{
    return NO;
}


@end


