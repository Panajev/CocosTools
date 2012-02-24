//
//  UISprite.h
//  CocosTools
//
//  Created by Goffredo Marocchi on 2/16/12.
//  Copyright (c) 2012 IGGS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "CoreGraphicsExt.h"

@interface UISprite : CCSprite
{
@public
    bool pressed;			//Is this sprite pressed
    NSUInteger touchHash;	//Used to identify individual touches
    bool collisionRadiusExtended;
    bool touchStarted;
}

@property (readwrite, assign) bool collisionRadiusExtended;
@property (readwrite, assign) bool pressed;
@property (readwrite, assign) NSUInteger touchHash;

- (id)init;
- (bool)checkTouchWithPoint:(CGPoint)point;
- (CGRect)rect;
- (void)processTouch:(CGPoint)point;
- (void)processRelease;
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

@end

