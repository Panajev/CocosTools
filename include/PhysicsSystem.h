#import "Box2D.h"
#import "cocos2d.h"
#import "CCDraggableSprite.h"

const static float FIXED_TIME_STEP = 1.f/60.f;

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
    
	//PhysicsSystem(float theInitialFixedTimeStepAccumulator, float theInitialFixedTimeStepAccumulatorRatio);
	PhysicsSystem(void);
	//virtual ~PhysicsSystem(void);
	~PhysicsSystem(void);
    
};