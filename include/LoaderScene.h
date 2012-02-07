//
//  LoaderScene.h
//  OminoDelleTasche
//
//  Created by Goffredo Marocchi on 1/22/12.
//  Copyright (c) 2012 IGGS. All rights reserved.
//

#import "cocos2d/cocos2d.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CoreGraphicsExt.h"
#import "CCSpriteExtensions.h"


@interface LoaderScene : CCLayer
{
    //id * delegate; //add your own delegate in your subclass
    CCProgressTimer* progressBar;
    CCSprite* progressBorder;
}

+ (id) sceneWithBackground:(NSString*)fileName;
- (void) tick;

@end

