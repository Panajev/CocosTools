//
//  DraggableSprite.mm
//  Pagina3
//
//  Created by Goffredo Marocchi on 4/25/11.
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

#import "CCDraggableSprite.h"
#import "WorldPhysics.h"
#import "CCSpriteExtended.h"

@implementation CCDraggableSprite

@synthesize box2dBody, oldPos, originalY, swallowTouches, disableTouches;

-(BOOL)isPointInsideSprite:(CGPoint)pos {
    float maxX = texture_.contentSize.width/self.scale;
    float maxY = texture_.contentSize.height/self.scale;
    
    //NSLog(@"maxX = %.2f, pos.x = %.2f", maxX, pos.x);
    
    if(pos.x < 0 || pos.y < 0 || 
       pos.x > maxX || pos.y > maxY) {
        return NO;
    }
    else { 
        return YES;
    }
}

#ifdef __CC_PLATFORM_IOS
-(BOOL)isTouchInsideSprite:( UITouch* )touch {
    CGPoint pos;
    pos = [ touch locationInView: [ touch view ] ];
    pos = [ [ CCDirector sharedDirector ] convertToGL:pos ];
    pos = [self convertToNodeSpace:pos];
    
    return [self isPointInsideSprite:pos];
}

- (BOOL)containsTouchLocation:(UITouch *)touch
{
    return [self isTouchInsideSprite:touch];
}
#else
-(BOOL)isTouchInsideSprite:( NSEvent* )touch {
    CGPoint location = [(CCDirectorMac*)[CCDirector sharedDirector] convertEventToGL:touch];
    location = [self convertToNodeSpace:location];
    
    return [self isPointInsideSprite:location];
}

-(BOOL)containsTouchLocation:(NSEvent *)touch {
    return [self isTouchInsideSprite:touch];
}
#endif


+(id) spriteWithSpriteFrameNameOrFile:(NSString*)filename {
    id temp = [[self alloc] initWithFile:filename];
    return (temp);
}

-(id) initWithFile:(NSString*) filename {
	if ((self = [super initWithFile:filename]) ) {
        disableTouches = NO;
		state = kSpriteStateUngrabbed;
		oldPos = self.position;
        collisionDetected = NO;
	}
	
	return self;
}


+(id) spriteWithTexture:(CCTexture2D*)texture rect:(CGRect)rectangle {
    return [[self alloc] initWithTexture:texture rect:rectangle];
}
-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rectangle {
	
	if ((self = [super initWithTexture:texture rect:rectangle]) ) {
        disableTouches = NO;
		state = kSpriteStateUngrabbed;
		oldPos = self.position;
        collisionDetected = NO;
	}
	
	return self;
}

-(void) onEnterTransitionDidFinish
{
#ifdef __CC_PLATFORM_IOS
    CCDirector *director =  (CCDirector*)[CCDirector sharedDirector];
    [[director touchDispatcher] removeDelegate:self];
	[[director touchDispatcher] addTargetedDelegate:self priority:0  swallowsTouches:YES];
#else
    [[[CCDirector sharedDirector] eventDispatcher] removeMouseDelegate:self];
    [[[CCDirector sharedDirector] eventDispatcher] addMouseDelegate:self priority:-1];
#endif
    
    //CMLog(@"...%s...", __PRETTY_FUNCTION__);
	[super onEnterTransitionDidFinish];
}

- (void)onExit
{
#ifdef __CC_PLATFORM_IOS
    CCDirector *director =  (CCDirector*)[CCDirector sharedDirector];
	[[director touchDispatcher] removeDelegate:self];
#else
    [[[CCDirector sharedDirector] eventDispatcher] removeMouseDelegate:self];
#endif
	[super onExit];
}	

#ifdef __CC_PLATFORM_IOS
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if([self containsTouchLocation:touch] && disableTouches != NO) {
        state = kSpriteStateGrabbed;
        return YES;
    }
    return NO;
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	//NSAssert(state == kBoxStateGrabbed, @"Paddle - Unexpected state!");
    if (disableTouches != NO) {
        state = kSpriteStateUngrabbed;
    }
}
#else
-(BOOL) ccMouseDown:(NSEvent*)event {
    if([self containsTouchLocation:event] && disableTouches != NO) {
        state = kSpriteStateGrabbed;
        return YES;
    }
    return NO;
}

-(BOOL) ccMouseUp:(NSEvent*)event {
    //NSAssert(state == kBoxStateGrabbed, @"Paddle - Unexpected state!");
    if (disableTouches != NO) {
        state = kSpriteStateUngrabbed;
        return YES;
    }
    
    return NO;
}
#endif

@end

