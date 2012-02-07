#import "PhysicsSystem.h"

const float FIXED_TIMESTEP = 1.0f / 60.f;

PhysicsSystem::PhysicsSystem (): fixedTimestepAccumulator_ (0), fixedTimestepAccumulatorRatio_ (0),velocityIterations_(8), positionIterations_(1)
{
	// ...
}

b2World* PhysicsSystem::getWorld(void) {
	return world_;
}

void PhysicsSystem::setWorld(b2World* world) {
	world_ = world;
}

PhysicsSystem::~PhysicsSystem (void) {
	CCLOG(@"DESTRUCTING PHYSICS...");
}

void PhysicsSystem::update (float dt)
{
	// Maximum number of steps, to avoid degrading to an halt.
	const int MAX_STEPS = 5;
    
	fixedTimestepAccumulator_ += dt;
	const int nSteps = static_cast<int> (
										 std::floor (fixedTimestepAccumulator_ / FIXED_TIMESTEP)
										 );
	// To avoid rounding errors, touches fixedTimestepAccumulator_ only
	// if needed.
	if (nSteps > 0)
	{
		fixedTimestepAccumulator_ -= nSteps * FIXED_TIMESTEP;
	}
    
	assert (
			"Accumulator must have a value lesser than the fixed time step" &&
			fixedTimestepAccumulator_ < FIXED_TIMESTEP + FLT_EPSILON
			);
	fixedTimestepAccumulatorRatio_ = fixedTimestepAccumulator_ / FIXED_TIMESTEP;
    
	// This is similar to clamp "dt":
	//	dt = std::min (dt, MAX_STEPS * FIXED_TIMESTEP)
	// but it allows above calculations of fixedTimestepAccumulator_ and
	// fixedTimestepAccumulatorRatio_ to remain unchanged.
	const int nStepsClamped = std::min (nSteps, MAX_STEPS);
	for (int i = 0; i < nStepsClamped; ++ i)
	{
		// In singleStep_() the CollisionManager could fire custom
		// callbacks that uses the smoothed states. So we must be sure
		// to reset them correctly before firing the callbacks.
		resetSmoothStates_ ();
		singleStep_ (FIXED_TIMESTEP);
	}
    
	world_->ClearForces ();
    
	// We "smooth" positions and orientations using
	// fixedTimestepAccumulatorRatio_ (alpha).
	smoothStates_ ();
}

void PhysicsSystem::singleStep_ (float dt)
{
	// ...
    
	//updateControllers_ (dt);
	world_->Step (dt, velocityIterations_, positionIterations_);
	//consumeContacts_ ();
    
	// ...
}

void PhysicsSystem::smoothStates_ ()
{
	b2Vec2 newSmoothedPosition;
    
	const float oneMinusRatio = 1.f - fixedTimestepAccumulatorRatio_;
    
	for (b2Body * b = world_->GetBodyList (); b != NULL; b = b->GetNext ())
	{
		if (b->GetType () == b2_staticBody)
		{
			continue;
		}
        
		CCDraggableSprite *c   = (CCDraggableSprite*) b->GetUserData();
		newSmoothedPosition = fixedTimestepAccumulatorRatio_ * b->GetPosition () + oneMinusRatio * c.previousPosition;
        
		c.smoothedPosition = newSmoothedPosition;
        
		c.smoothedAngle =
		fixedTimestepAccumulatorRatio_ * b->GetAngle () +
		oneMinusRatio * c.previousAngle;
        
	}
}

void PhysicsSystem::resetSmoothStates_ ()
{
	b2Vec2 newSmoothedPosition;
    
	for (b2Body * b = world_->GetBodyList (); b != NULL; b = b->GetNext ())
	{
		if (b->GetType () == b2_staticBody)
		{
			continue;
		}
        
		CCDraggableSprite *c   = (CCDraggableSprite*) b->GetUserData();
        
		newSmoothedPosition = b->GetPosition ();
        
		c.smoothedPosition = newSmoothedPosition;
		c.previousPosition = newSmoothedPosition;
		c.smoothedAngle = b->GetAngle ();
		c.previousAngle = b->GetAngle();
	}
}