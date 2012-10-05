//
//  DraggableSprite.h
//  Pagina3
//
//  Created by Goffredo Marocchi on 4/25/11.
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

#ifdef __CC_PLATFORM_IOS
@interface CCDraggableSprite : CCSpriteExtended <CCTargetedTouchDelegate> {
    SpriteState state;
	CGPoint oldPos, newPos;
    float originalY;
    BOOL collisionDetected;
}
#else
@interface CCDraggableSprite : CCSpriteExtended <CCMouseEventDelegate> {
    SpriteState state;
	CGPoint oldPos, newPos;
    float originalY;
    BOOL collisionDetected;
}
#endif

@property (nonatomic, assign) b2Body* box2dBody;
@property (nonatomic, assign) CGPoint oldPos;
@property (nonatomic, assign) float originalY;

@property (nonatomic, assign) BOOL swallowTouches;
@property (nonatomic, assign) BOOL disableTouches;

+(id) spriteWithTexture:(CCTexture2D*)texture rect:(CGRect)rectangle;

#ifdef __CC_PLATFORM_IOS
-(BOOL)containsTouchLocation:(UITouch *)touch;
#else
-(BOOL)containsTouchLocation:(NSEvent *)touch;
#endif


@end
