//
//  CCSpriteExtended.h
//  OminoDelleTasche
//
//  Created by Goffredo Marocchi on 1/7/12.
//  Copyright (c) 2012 IGGS. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"

@interface CCSpriteExtended : CCSprite {
    float _previousAngle;
	float _smoothedAngle;
	b2Vec2 _previousPosition;
	b2Vec2 _smoothedPosition;
}

@property (nonatomic) float32 previousAngle;
@property (nonatomic) float32 smoothedAngle;
@property (nonatomic) b2Vec2 previousPosition;
@property (nonatomic) b2Vec2 smoothedPosition;

@end
