//
//  WorldPhysics.m
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

#import "WorldPhysics.h"
#import "GeneralDefines.h"
#import "OSDefines.h"
#import "LogDefines.h"

@implementation WorldPhysics
{
    CGPoint convertRatio;
    float LH_PTM_RATIO;
}
SINGLETON_GCD(WorldPhysics);

@synthesize sharedWorld=_sharedWorld, sharedGround=_sharedGround, sharedLH, sharedPhysics=_sharedPhysics;

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
    if (_sharedWorld == NULL) { 
        _sharedWorld = new b2World(gravity); 
    }
    _sharedWorld->SetGravity(gravity);
    
    _sharedPhysics = new PhysicsSystem();
    _sharedPhysics->setWorld(_sharedWorld);

    return _sharedWorld;
}

- (b2World*) createWorldFTS {
    // Define the gravity vector.
    LH_PTM_RATIO = 32.0f;
    [self updateConversionRatio];
    
    if (sharedLH != nil) {
        //_sharedWorld = ;
        return NULL;
    }
    
    b2Vec2 gravity(0.0f, -9.8f);
    // Construct a world object, which will hold and simulate the rigid bodies.
    if (_sharedWorld == NULL) { 
        _sharedWorld = new b2World(gravity); 
    }
    _sharedWorld->SetGravity(gravity);
    _sharedWorld->SetAutoClearForces(false);
    
    _sharedPhysics = new PhysicsSystem();
    _sharedPhysics->setWorld(_sharedWorld);
    
    return _sharedWorld;
}

- (void) destroyWorld {
    //if(_sharedWorld != NULL) {
    //    delete _sharedWorld;
    //}
	//_sharedWorld = NULL;
    if (_sharedWorld == NULL) {
        return;
    }
    else if (_sharedWorld->IsLocked()) {
        CMLog(@"locked world... %s", __PRETTY_FUNCTION__);
        return;
    }

    _sharedWorld->ClearForces();
    
    for (b2Body* b = _sharedWorld->GetBodyList(); b; b = b->GetNext())
	{
        if(b != NULL) {
            b->SetUserData(NULL);
            _sharedWorld->DestroyBody(b);
        }
    }
    
    for (b2Joint* j = _sharedWorld->GetJointList(); j; j = j->GetNext())
	{
        if(j != NULL) {
            _sharedWorld->DestroyJoint(j);
        }
    }
    SAFE_DELETE(_sharedWorld);
    SAFE_DELETE(_sharedPhysics);
    [self createWorldFTS];
}

- (b2Body*) generateScreenBoundaries {
    if (sharedLH != nil) {
        _sharedGround = (__bridge b2Body*)[(id)sharedLH performSelector:@selector(createWorldBoundaries)];
        return NULL;
    }
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    //creating the ground shape/body
    b2BodyDef _groundBodyDef;
    _groundBodyDef.position.Set(0, 0);
    _sharedGround = _sharedWorld->CreateBody(&_groundBodyDef);
    
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
    _sharedGround->CreateFixture(&loopShapeDef_ground);
    
    return _sharedGround;
}

- (void) setGravityVec:(b2Vec2)gravityVec {
    _sharedWorld->SetGravity(gravityVec);
    if (_sharedPhysics != NULL) {
        _sharedPhysics->setWorld(_sharedWorld);
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
