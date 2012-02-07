//
//  DraggableSprite.h
//  Pagina3
//
//  Created by Goffredo Marocchi on 4/25/11.
//  Copyright 2011 IGGS. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "cocos2d.h"
#include "Box2D/Box2D.h"
#import "CCSprite.h"

#import "CoreGraphicsExt.h"
#import "GeneralDefines.h"
#import "CCSpriteExtended.h"

#include <assert.h>

typedef enum tagSpriteState {
	kSpriteStateGrabbed,
	kSpriteStateUngrabbed
} SpriteState;

class QueryCallback : public b2QueryCallback
{
public:
	QueryCallback(const b2Vec2& point)
	{
		m_point = point;
		m_fixture = NULL;
	}
    
	bool ReportFixture(b2Fixture* fixture)
	{
		b2Body* body = fixture->GetBody();
		if (body->GetType() == b2_dynamicBody)
		{
			bool inside = fixture->TestPoint(m_point);
			if (inside)
			{
				m_fixture = fixture;
                
				// We are done, terminate the query.
				return false;
			}
		}
        
		// Continue the query.
		return true;
	}
    
	b2Vec2 m_point;
	b2Fixture* m_fixture;
};


@interface CCDraggableSprite : CCSpriteExtended <CCTargetedTouchDelegate> {
    SpriteState state;
	CGPoint oldPos, newPos;
    float originalY;
    BOOL collisionDetected;
}

@property (nonatomic, assign) b2Body* box2dBody;
@property (nonatomic, assign) CGPoint oldPos;
@property (nonatomic, assign) float originalY;

@property (nonatomic, assign) BOOL swallowTouches;
@property (nonatomic, assign) BOOL disableTouches;

+(id) spriteWithTexture:(CCTexture2D*)texture rect:(CGRect)rectangle;

-(BOOL)containsTouchLocation:(UITouch *)touch;

@end
