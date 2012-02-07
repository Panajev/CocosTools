//
//  WorldPhysics.m
//  OminoDelleTasche
//
//  Created by Goffredo Marocchi on 6/2/11.
//  Copyright 2011 IGGS. All rights reserved.
//

#import "WorldPhysics.h"
#import "GeneralDefines.h"
#import "OSDefines.h"
#import "LogDefines.h"

@implementation WorldPhysics
SYNTHESIZE_SINGLETON_FOR_CLASS(WorldPhysics);

@synthesize sharedWorld, sharedGround, sharedLH, sharedPhysics;

- (b2World*) createWorld {
    // Define the gravity vector.
    LH_PTM_RATIO = 32.0f;
    [self updateConversionRatio];
    
    if (sharedLH != nil) {
        //sharedWorld = ;
        return NULL;
    }
    
    b2Vec2 gravity(0.0f, -9.8f);
    // Construct a world object, which will hold and simulate the rigid bodies.
    if (sharedWorld == NULL) { 
        sharedWorld = new b2World(gravity); 
    }
    sharedWorld->SetGravity(gravity);
    
    sharedPhysics = new PhysicsSystem();
    sharedPhysics->setWorld(sharedWorld);

    return sharedWorld;
}

- (b2World*) createWorldFTS {
    // Define the gravity vector.
    LH_PTM_RATIO = 32.0f;
    [self updateConversionRatio];
    
    if (sharedLH != nil) {
        //sharedWorld = ;
        return NULL;
    }
    
    b2Vec2 gravity(0.0f, -9.8f);
    // Construct a world object, which will hold and simulate the rigid bodies.
    if (sharedWorld == NULL) { 
        sharedWorld = new b2World(gravity); 
    }
    sharedWorld->SetGravity(gravity);
    sharedWorld->SetAutoClearForces(false);
    
    sharedPhysics = new PhysicsSystem();
    sharedPhysics->setWorld(sharedWorld);
    
    return sharedWorld;
}

- (void) destroyWorld {
    //if(sharedWorld != NULL) {
    //    delete sharedWorld;
    //}
	//sharedWorld = NULL;
    if (sharedWorld == NULL) {
        return;
    }
    else if (sharedWorld->IsLocked()) {
        CMLog(@"locked world... %s", __PRETTY_FUNCTION__);
        return;
    }

    sharedWorld->ClearForces();
    
    for (b2Body* b = sharedWorld->GetBodyList(); b; b = b->GetNext())
	{
        if(b != NULL) {
            b->SetUserData(NULL);
            sharedWorld->DestroyBody(b);
        }
    }
    
    for (b2Joint* j = sharedWorld->GetJointList(); j; j = j->GetNext())
	{
        if(j != NULL) {
            sharedWorld->DestroyJoint(j);
        }
    }
    SAFE_DELETE(sharedWorld);
    SAFE_DELETE(sharedPhysics);
    [self createWorldFTS];
}

- (b2Body*) generateScreenBoundaries {
    if (sharedLH != nil) {
        sharedGround = (b2Body*)[sharedLH performSelector:@selector(createWorldBoundaries)];
        return NULL;
    }
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    //creating the ground shape/body
    b2BodyDef _groundBodyDef;
    _groundBodyDef.position.Set(0, 0);
    sharedGround = sharedWorld->CreateBody(&_groundBodyDef);
    
    b2ChainShape _groundShape;
    b2FixtureDef loopShapeDef_ground;
    
    b2Vec2 groundVertex1 = [self pointsToMeters:ccp(0.0f, 0.0f)];
    b2Vec2 groundVertex2 = [self pointsToMeters:ccp(winSize.width, 0.0f)];
    b2Vec2 groundVertex3 = [self pointsToMeters:ccp(winSize.width, winSize.height)];
    b2Vec2 groundVertex4 = [self pointsToMeters:ccp(0.0f, winSize.height)];
    
    b2Vec2 _groundVertices[]={groundVertex1, groundVertex2,
                                groundVertex3, groundVertex4};
    _groundShape.CreateLoop(_groundVertices, 4);
    loopShapeDef_ground.shape = &_groundShape;
    sharedGround->CreateFixture(&loopShapeDef_ground);
    
    return sharedGround;
}

- (void) setGravityVec:(b2Vec2)gravityVec {
    sharedWorld->SetGravity(gravityVec);
    if (sharedPhysics != NULL) {
        sharedPhysics->setWorld(sharedWorld);
    }
}

-(void) updateConversionRatio
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    //float safeFrameDiagonal = sqrtf(1024.0f* 1024.0f + 768.0f*768.0f);
    //float winDiagonal = sqrtf(winSize.width* winSize.width + winSize.height*winSize.height);
    //float PTM_conversion = winDiagonal/safeFrameDiagonal;
    
    convertRatio.x = winSize.width/1024.0f;
    convertRatio.y = winSize.height/768.0f;
    LH_PTM_RATIO = 32.0f;
}

-(void) setMeterRatio:(float)ratio //default is 32.0f
{
    LH_PTM_RATIO = ratio;
    [[WorldPhysics sharedInstance] updateConversionRatio];
}
-(float) meterRatio
{
    return LH_PTM_RATIO;
}

-(float) pixelsToMeterRatio
{
    return LH_PTM_RATIO*convertRatio.x;
}

-(float) pointsToMeterRatio
{
    return LH_PTM_RATIO;
}

-(b2Vec2) pixelToMeters:(CGPoint)point
{
    return b2Vec2(point.x / [self pixelsToMeterRatio], point.y / [self pixelsToMeterRatio]);
}

-(b2Vec2) pointsToMeters:(CGPoint)point
{
    return b2Vec2(point.x / LH_PTM_RATIO, point.y / LH_PTM_RATIO);
}

-(CGPoint) metersToPoints:(b2Vec2)vec
{
    return CGPointMake(vec.x*LH_PTM_RATIO, vec.y*LH_PTM_RATIO);
}

-(CGPoint) metersToPixels:(b2Vec2)vec
{
    return ccpMult(CGPointMake(vec.x, vec.y), [self pixelsToMeterRatio]);
}

@end
