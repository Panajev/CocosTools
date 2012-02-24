//
//  UISprite.m
//  CocosTools
//
//  Created by Goffredo Marocchi on 2/16/12.
//  Copyright (c) 2012 IGGS. All rights reserved.
//

#import "UISprite.h"
#import "MathHelper.h"

@implementation UISprite
@synthesize pressed, touchHash, collisionRadiusExtended;

-(id)init {
    self = [super init];
    if (self != nil) {
		pressed = NO;
    }
    return self;
}

-(void)dealloc {
    [super dealloc];
}

- (bool)checkTouchWithPoint:(CGPoint)point {
	if(CGRectContainsPoint([self rect], point)){
		return YES;
	}else{
		return NO;
	}
}

- (CGRect) rect {
	//We set our scale mod to make sprite easier to press.
	//This also lets us press 2 sprites with 1 touch if they are sufficiently close.
	float scaleMod = 1.5f;
	float w = [self contentSize].width * [self scale] * scaleMod;
	float h = [self contentSize].height * [self scale] * scaleMod;
	CGPoint point = CGPointMake([self position].x - (w/2), [self position].y - (h/2));
	
	return CGRectMake(point.x, point.y, w, h); 
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView: [touch view]];
	point = [[CCDirector sharedDirector] convertToGL: point];
    
	//We use circle collision for our buttons
	if(CGCircleContainsPoint(self.rect.size.width/2,self.position, point)){		
        touchStarted = YES;
		touchHash = [touch hash];
		[self processTouch:point];
	}
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (collisionRadiusExtended) {
        if (!touchStarted) {
            return;
        }
    }
    
	UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView: [touch view]];
	point = [[CCDirector sharedDirector] convertToGL: point];
	
	if(CGCircleContainsPoint(self.rect.size.width/2,self.position, point) || 
       collisionRadiusExtended){
		if(touchHash == [touch hash]){		//If we moved on this sprite
			[self processTouch:point];
		}else if(!pressed){					//If a new touch moves onto this sprite
			touchHash = [touch hash];
			[self processTouch:point];
		}
	}else if(touchHash == [touch hash]){	//If we moved off of this sprite
		[self processRelease];
	}
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self ccTouchesCancelled:touches withEvent:event];
}

- (void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];	
	CGPoint point = [touch locationInView: [touch view]];
	point = [[CCDirector sharedDirector] convertToGL: point];
	
	if(touchHash == [touch hash]){	//If the touch which pressed this sprite ended we release
		[self processRelease];
        touchStarted = NO;
	}
} 

- (void)processTouch:(CGPoint)point {
	pressed = YES;
}

- (void)processRelease {
	pressed = NO;
}

@end