#import "Box2D.h"
#import "cocos2d.h"
#import "CCDraggableSprite.h"

#ifndef FIXED_TIMESTEP
#define FIXED_TIMESTEP (1.0f/60.0f)
#endif

class PhysicsSystem
{
    
protected:
    
	float fixedTimestepAccumulator_;
	float fixedTimestepAccumulatorRatio_;
	float velocityIterations_, positionIterations_;
	b2World* world_;
    
public:
    
	b2World* getWorld(void);
    void setWorld(b2World* world);
	void update (float dt);
	void singleStep_ (float dt);
	void smoothStates_ ();
	void resetSmoothStates_ ();
    void registerAnimationCallBack (id target, SEL selector);
    
    id targetLayer;
    SEL selectorLayer;
    
	//PhysicsSystem(float theInitialFixedTimeStepAccumulator, float theInitialFixedTimeStepAccumulatorRatio);
	PhysicsSystem(void);
	//virtual ~PhysicsSystem(void);
	~PhysicsSystem(void);
    
};
