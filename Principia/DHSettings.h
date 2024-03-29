//
//  DHSettings.h
//  Euclid
//
//  Created by David Hallgren on 2014-07-17.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString* const kSettingKey_AllLevelsUnlocked = @"AllLevelsUnlocked";
static NSString* const kSettingKey_ShowWellDoneMessages = @"ShowWellDoneMessages";
static NSString* const kSettingKey_ShowProgressPercentage = @"ShowProgressPercentage";
static NSString* const kSettingKey_ShowHints = @"ShowHints";
static NSString* const kSettingKey_ObjectsInPlayground = @"ObjectsMadeInPlayground";
static NSString* const kSettingKey_EnableMagnifier = @"EnableMagnifier";

@interface DHSettings : NSObject

+ (BOOL)allLevelsUnlocked;
+ (void)setAllLevelsUnlocked:(BOOL)unlocked;

+ (BOOL)showWellDoneMessages;
+ (void)setShowWellDoneMessages:(BOOL)value;

+ (BOOL)showProgressPercentage;
+ (void)setShowProgressPercentage:(BOOL)value;

+ (BOOL)showHints;
+ (void)setShowHints:(BOOL)value;

+ (BOOL)magnifierEnabled;
+ (void)setMagnifierEnabled:(BOOL)value;

+ (NSUInteger)numberOfObjectsMadeInPlayground;
+ (void)setNumberOfObjectsMadeInPlayground:(NSUInteger)value;


@end
