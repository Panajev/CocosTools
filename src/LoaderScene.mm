//
//  LoaderScene.m
//  OminoDelleTasche
//
//  Created by Goffredo Marocchi on 1/22/12.
//  Copyright (c) 2012 IGGS. All rights reserved.
//

#import "LoaderScene.h"

// Import the interfaces
#import "GeneralDefines.h"
#import "MathHelper.h"
#import "OSDefines.h"
#import "OpenGLES_Tools.h"
#include "Box2D/Box2D.h"
#import "WorldPhysics.h"
#import "MusicManager.h"
#import "CCSpriteExtensions.h"

///////////////////////

// HelloWorld implementation
@implementation LoaderScene

+(id) sceneWithBackground:(NSString*)fileName {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
	CCScene *scene = [CCScene node];
    
    float MID_SCREEN_X_ = ([CCDirector sharedDirector].winSize.width/2.0f);
    float MID_SCREEN_Y_  = ([CCDirector sharedDirector].winSize.height/2.0f);
	
	// 'layer' is an autorelease object.
	LoaderScene *layer = [LoaderScene node];
    
    CCSprite * loader = [CCSprite spriteWithSpriteFrameNameOrFile:fileName];
	[loader setPosition:ccp(MID_SCREEN_X_,MID_SCREEN_Y_)];
    [layer addChild:loader z:1];
    
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}


// initialize your instance here
-(id) init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
    
    
	if( (self=[super init])) {
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = NO;
        
        //CGSize winSize = [CCDirector sharedDirector].winSize;
        
        //this method does not do anything, it is meant to show a small sample for your subclass
        /*
        delegate = (OminoAppDelegate*)[[UIApplication sharedApplication] delegate];
        progressBorder = [CCSprite spriteWithFile: @ "progressbarborder.png"];
        [progressBorder setPosition:ccp(winSize.width/2.0f, winSize.height*0.10f)];
        [self addChild: progressBorder z:2]; 
        progressBar = [CCProgressTimer progressWithSprite:[CCSprite spriteWithFile:@"progressbar.png"]];
        progressBar.type = kCCProgressTimerTypeBar;
        
        progressBar.barChangeRate=ccp(1,0); 
        progressBar.midpoint=ccp(0.0,0.0f);
        
        [progressBorder addChild:progressBar z:3];
        [progressBar setAnchorPoint: ccp(0,0)];
        
        CCProgressTo *progressTo = [CCProgressTo actionWithDuration:1.0f percent:5.0f];
        [progressBar runAction:progressTo];
        
        [self scheduleOnce: @selector(tick) delay:1.0f];
         */
		
	}
	return self;
}

- (void) tick {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
    
    //this method does not do anything, it is meant to show a small sample for your subclass
    
    /*for (int i = 0; i <10; i++) {
        CCProgressTo *progressTo = [CCProgressTo actionWithDuration:1.0f percent:100.0f/(10.0f*i)];
        NSString * trackName = [NSString stringWithFormat:@"PageMusic/track%d.aac",i];
        [[MusicManager sharedInstance] preloadMusic:trackName];
        MARK;
        [progressBar runAction:[progressTo copy]];
    }
    
    NSString * trackName = [NSString stringWithFormat:@"PageMusic/track%d.aac", [delegate pageID]];
    [[MusicManager sharedInstance] preloadMusic:trackName];
    
    CCProgressTo *progressComplete = [CCProgressTo actionWithDuration:0.4f percent:100.0f];
    [progressBar runAction:progressComplete];
    [progressBar runAction:[CCCallFunc actionWithTarget:delegate selector:@selector(appLoadingFinished)]]; 
    */
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc {   
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
    
	[super dealloc];
}

@end
