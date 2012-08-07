/*
 *  Handy.h
 *  MyNextGame
 *
 *  Created by macbook on 11/10/10.
 *  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
 *
 */

#define RAND1 ((float)rand()/(float)RAND_MAX)
#define RAND11 (2.0f*(float)rand()/(float)RAND_MAX-1.0f)
#define RANDSQ1 (pow(RAND1*2,2)*0.25f)
#define RANDPOSRECT(__rect__) ccp((__rect__).origin.x+RAND1*(__rect__).size.width,(__rect__).origin.y+RAND1*(__rect__).size.height)
#define RANDSIGN ((RAND1<0.5f)?-1:1)
#define RANDSEGMENT(__min__,__max__) (__min__+(__max__-__min__)*RAND1)
#define RANDSEGMENTSIGN(__min__,__max__) (RANDSIGN*RANDSEGMENT(__min__,__max__))

#define RANDNSARRAY(__array__) ((__array__.count>0)?([__array__ objectAtIndex:(int)(RAND1*(float)__array__.count)]):nil)

#define NORMEDVECTOR(__radian__) ccp(cos(__radian__),sin(__radian__))
#define RANDNORMEDVECTOR NORMEDVECTOR(RANDSEGMENT(0,2*M_PI))