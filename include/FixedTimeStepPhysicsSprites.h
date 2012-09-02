//
//  FixedTimeStepPhysicsSprites.h
//  CocosTools
//
//  Created by Goffredo Marocchi on 9/1/12.
//  Copyright (c) 2012 IGGS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Box2D.h"

@protocol FixedTimeStepPhysicsSprites <NSObject>

@property (nonatomic, assign) float32 previousAngle;
@property (nonatomic, assign) float32 smoothedAngle;
@property (nonatomic, assign) b2Vec2 previousPosition;
@property (nonatomic, assign) b2Vec2 smoothedPosition;

@end
