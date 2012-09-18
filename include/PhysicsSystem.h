#import "Box2D.h"
#import "cocos2d.h"

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
    id targetLayer;
    SEL selectorLayer;
    
public:
    PhysicsSystem(void);
	virtual ~PhysicsSystem(void);
    
	virtual b2World* getWorld(void);
    virtual void setWorld(b2World* world);
	virtual void update (float dt);
	virtual void singleStep_ (float dt);
	virtual void resetSmoothStates_ ();
    virtual void registerAnimationCallBack (id target, SEL selector);
    virtual float getFixedTimestep();
    virtual float getFixedTimestepAccumulator();
    virtual float getFixedTimestepAccumulatorRatio();
};
