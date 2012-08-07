//
//  CCSpriteExtension.m
//  CocosLib
//
//  Created by Goffredo Marocchi on 6/2/11.
//  Copyright (c) 2011 AddictiveColors. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the
//  following conditions are met:
//
//      Redistributions of source code must retain the above copyright notice, this list of conditions and the following
//      disclaimer.
//      Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
//      disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
//  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL COPYRIGHT HOLDERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
//  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
        NSString * errStr = nil;
        errStr = [NSString stringWithFormat:@"error... sprite \"%@\" == nil", nameOrFile];
        NSAssert(loadedSprite != nil, errStr);
    }
    
    return loadedSprite;
}
@end