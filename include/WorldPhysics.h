//
//  WorldPhysics.h
//  OminoDelleTasche
//
//  Created by Goffredo Marocchi on 6/2/11.
//  Copyright 2011 IGGS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"

#import "Box2D.h"

#import "PhysicsSystem.h"

@class LevelHelperLoader;

@interface WorldPhysics : NSObject {
    CGPoint convertRatio;
    float LH_PTM_RATIO;
}
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(WorldPhysics);

@property (assign) b2World* sharedWorld;
@property (assign) b2Body* sharedGround;
@property (assign) LevelHelperLoader* sharedLH;
@property (assign) PhysicsSystem* sharedPhysics;

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
