//
//  UISprite.m
//  CocosTools
//
//  Created by Goffredo Marocchi on 2/16/12.
//  Copyright (c) 2012 AddictiveColors. All rights reserved.
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