//
//  DraggableSprite.m
//  Pagina3
//
//  Created by Goffredo Marocchi on 4/25/11.
//  Copyright 2011 IGGS. All rights reserved.
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


+(id) spriteWithSpriteFrameNameOrFile:(NSString*)filename {
    id temp = [[self alloc] initWithFile:filename];
    return ([temp autorelease]);
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
    return [[[self alloc] initWithTexture:texture rect:rectangle] autorelease];
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
	CCDirectorIOS *director =  (CCDirectorIOS*)[CCDirector sharedDirector];
    [[director touchDispatcher] removeDelegate:self];
	[[director touchDispatcher] addTargetedDelegate:self priority:0  swallowsTouches:YES];
    
    //CMLog(@"...%s...", __PRETTY_FUNCTION__);
	[super onEnterTransitionDidFinish];
}

- (void)onExit
{
	CCDirectorIOS *director =  (CCDirectorIOS*)[CCDirector sharedDirector];
	[[director touchDispatcher] removeDelegate:self];
	[super onExit];
}	

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

@end
