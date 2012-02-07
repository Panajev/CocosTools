//
//  CCSpriteExtension.m
//  CocosLib
//
//  Created by Goffredo Marocchi on 6/2/11.
//  Copyright 2011 IGGS. All rights reserved.
//

#import "CCSpriteExtensions.h"
#import "LogDefines.h"

@implementation CCSprite (Xtensions)
+(id) spriteWithSpriteFrameNameOrFile:(NSString*)nameOrFile
{
    CCSprite * loadedSprite = nil;
    CCSpriteFrame* spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:nameOrFile];
    if (spriteFrame)
    {
        loadedSprite = [CCSprite spriteWithSpriteFrame:spriteFrame];
    }
    else {
        loadedSprite = [CCSprite spriteWithFile:nameOrFile];
    }
    
    if(loadedSprite == nil) {
        CMLog(@"error... sprite \"%@\" == nil", nameOrFile);
    }
    
    return loadedSprite;
}
@end