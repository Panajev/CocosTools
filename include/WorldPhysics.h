//
//  WorldPhysics.h
//  OminoDelleTasche
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

#import <Foundation/Foundation.h>
//#import "SynthesizeSingleton.h"
#import "SynthesizeSingletonGCD.h"
#import "PhysicsSystem.h"

#import "Box2D.h"

@class LevelHelperLoader;

@interface WorldPhysics : NSObject {
    PhysicsSystem * _sharedPhysics;
    b2World* _sharedWorld;
    b2Body* _sharedGround;
}
SINGLETON_GCD_HEADERS(WorldPhysics);

@property (nonatomic,readonly) b2World* sharedWorld;
@property (nonatomic,readonly) b2Body* sharedGround;
@property (nonatomic,weak) LevelHelperLoader* sharedLH;
@property (nonatomic,readonly) PhysicsSystem* sharedPhysics;

- (b2World*) createWorld;
- (b2World*) createWorldFTS;

- (void) destroyWorld;
- (b2Body*) generateScreenBoundaries;
- (void) setGravityVec:(b2Vec2)gVec;

- (void) updateConversionRatio;
- (void) setMeterRatio:(float)ratio;
- (float) meterRatio;
- (float) pixelsToMeterRatio;
- (float) pointsToMeterRatio;
- (b2Vec2) pixelToMeters:(CGPoint)point;
- (b2Vec2) pointsToMeters:(CGPoint)point;
- (CGPoint) metersToPoints:(b2Vec2)vec;
- (CGPoint) metersToPixels:(b2Vec2)vec;

@end
