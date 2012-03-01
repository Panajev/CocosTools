/*
 * CCControlSlider
 *
 * Copyright 2011 Yannick Loriot.
 * http://yannickloriot.com
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "CCControlSlider.h"

@interface CCControlSlider () 
@property (nonatomic, retain) CCMenuItem *thumbSprite;
@property (nonatomic, retain) CCSprite *progressSprite;
@property (nonatomic, retain) CCSprite *backgroundSprite;

/** Factorize the event dispath into these methods. */
- (void)sliderBegan:(CGPoint)location;
- (void)sliderMoved:(CGPoint)location;
- (void)sliderEnded:(CGPoint)location;

/** Returns the value for the given location. */
- (float)valueForLocation:(CGPoint)location;

@end

@implementation CCControlSlider
@synthesize thumbSprite         = thumbSprite_;
@synthesize progressSprite      = progressSprite_;
@synthesize backgroundSprite    = backgroundSprite_;
@synthesize value               = value_;
@synthesize minimumValue        = minimumValue_;
@synthesize maximumValue        = maximumValue_;

- (void)dealloc
{
    [thumbSprite_ release], thumbSprite_ = nil;
    [progressSprite_ release], progressSprite_ = nil;
    [backgroundSprite_ release], backgroundSprite_ = nil;
    
    [super dealloc];
}

+ (id)sliderWithBackgroundFile:(NSString *)backgroundname progressFile:(NSString *)progressname thumbFile:(NSString *)thumbname
{
    // Prepare background for slider
	CCSprite *backgroundSprite      = [CCSprite spriteWithFile:backgroundname];
	
    // Prepare progress for slider
    CCSprite *progressSprite        = [CCSprite spriteWithFile:progressname];
    
	// Prepare thumb (menuItem) for slider
	CCSprite *thumbNormal           = [CCSprite spriteWithFile:thumbname];
	CCSprite *thumbSelected         = [CCSprite spriteWithFile:thumbname];
	thumbSelected.color             = ccGRAY;
	
	CCMenuItemSprite *thumbMenuItem = [CCMenuItemSprite itemWithNormalSprite:thumbNormal selectedSprite:thumbSelected];
    
	return [self sliderWithBackgroundSprite:backgroundSprite 
                             progressSprite:progressSprite
                              thumbMenuItem:thumbMenuItem];
}

+ (id)sliderWithBackgroundSprite:(CCSprite *)backgroundSprite progressSprite:(CCSprite *)pogressSprite thumbMenuItem:(CCMenuItem *)thumbItem
{
	return [[[self alloc] initWithBackgroundSprite:backgroundSprite
                                    progressSprite:pogressSprite
                                     thumbMenuItem:thumbItem] autorelease];
}

// Designated init
- (id)initWithBackgroundSprite:(CCSprite *)backgroundSprite progressSprite:(CCSprite *)progressSprite thumbMenuItem:(CCMenuItem *)thumbItem  
{  
	if ((self = [super init]))  
	{
        NSAssert(backgroundSprite, @"Background sprite must be not nil");
        NSAssert(progressSprite, @"Progress sprite must be not nil");
        NSAssert(thumbItem, @"Thumb item must be not nil");
        
        self.isRelativeAnchorPoint      = YES;
        
        self.backgroundSprite           = backgroundSprite;
        self.progressSprite             = progressSprite;
        self.thumbSprite                = thumbItem;
        
        // Defines the content size
        CGRect maxRect                  = CGRectUnion([backgroundSprite_ boundingBox], [thumbSprite_ boundingBox]);
        self.contentSize                = CGSizeMake(maxRect.size.width, maxRect.size.height);
        
		// Add the slider background 
        backgroundSprite_.anchorPoint   = ccp (0.5f, 0.5f);
		backgroundSprite_.position      = ccp(self.contentSize.width / 2, self.contentSize.height / 2);
		[self addChild:backgroundSprite_];
        
        // Add the progress bar
        progressSprite_.anchorPoint     = ccp (0.0f, 0.5f);
        progressSprite_.position        = ccp (0.0f, self.contentSize.height / 2);
        [self addChild:progressSprite_];
		
		// Add the slider thumb  
		thumbSprite_.position           = ccp(0, self.contentSize.height / 2);  
		[self addChild:thumbSprite_];
        
        // Init default values
        minimumValue_                   = 0.0f;
        maximumValue_                   = 1.0f;
        self.value                      = minimumValue_;
	}  
	return self;  
}  

- (void)setValue:(float)value
{
	// set new value with sentinel
    if (value < minimumValue_)
    {
		value = minimumValue_;
    }
	
    if (value > maximumValue_) 
    {
		value = maximumValue_;
    }

    value_                      = value;
	
	// Update thumb position for new value
    float percent               = (value_ - minimumValue_) / (maximumValue_ - minimumValue_);
    
    CGPoint pos                 = thumbSprite_.position;
    pos.x                       = percent * backgroundSprite_.contentSize.width;
    thumbSprite_.position       = pos;
    
    // Stretches content proportional to newLevel
    CGRect textureRect          = progressSprite_.textureRect;
    textureRect                 = CGRectMake(textureRect.origin.x, textureRect.origin.y, pos.x, textureRect.size.height);
    progressSprite_.textureRect = textureRect;
	
    [self sendActionsForControlEvents:CCControlEventValueChanged];    
}

- (void)setMinimumValue:(float)minimumValue
{
    minimumValue_       = minimumValue;
    
    if (minimumValue_ >= maximumValue_)
    {
        maximumValue_   = minimumValue_ + 1.0f;
    }
    
    self.value          = maximumValue_;
}

- (void)setMaximumValue:(float)maximumValue
{
    maximumValue_       = maximumValue;
    
    if (maximumValue_ <= minimumValue_)
    {
        minimumValue_   = maximumValue_ - 1.0f;
    }
    
    self.value          = minimumValue_;
}

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

- (CGPoint)locationFromTouch:(UITouch *)touch
{
    CGPoint touchLocation   = [touch locationInView:[touch view]];                      // Get the touch position
    touchLocation           = [[CCDirector sharedDirector] convertToGL:touchLocation];  // Convert the position to GL space
    touchLocation           = [self convertToNodeSpace:touchLocation];                  // Convert to the node space of this class
    
    if (touchLocation.x < 0)
    {
        touchLocation.x     = 0;
    } else if (touchLocation.x > backgroundSprite_.contentSize.width)
    {
        touchLocation.x     = backgroundSprite_.contentSize.width;
    }
    
    return touchLocation;
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (![self isTouchInside:touch])
    {
        return NO;
    }
    
    CGPoint location = [self locationFromTouch:touch];
    
    [self sliderBegan:location];
    
    return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [self locationFromTouch:touch];
	
    [self sliderMoved:location];
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self sliderEnded:CGPointZero];
}

#endif

#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED

- (CGPoint)locationFromEvent:(NSEvent *)event
{
	CGPoint eventLocation   = [[CCDirector sharedDirector] convertEventToGL:event];
    eventLocation           = [self convertToNodeSpace:eventLocation];
    
    if (eventLocation.x < 0)
    {
        eventLocation.x = 0;
    } else if (eventLocation.x > backgroundSprite_.contentSize.width)
    {
        eventLocation.x = backgroundSprite_.contentSize.width;
    }
    
	return eventLocation;
}

- (BOOL)ccMouseDown:(NSEvent*)event
{
    if (![self isMouseInside:event])
    {
        return NO;
    }
	
    CGPoint location = [self locationFromEvent:event];
    
    [self sliderBegan:location];
    
    return YES;
}


- (BOOL)ccMouseDragged:(NSEvent*)event
{
	if (!self.thumbSprite.isSelected)
    {
		return NO;
    }
	
    CGPoint location = [self locationFromEvent: event];
	
    [self sliderMoved:location];
	
	return YES;
}

- (BOOL)ccMouseUp:(NSEvent*)event
{
    [self sliderEnded:CGPointZero];
	
	return NO;
}

#endif

#pragma mark -
#pragma mark CCControlSlider Public Methods

#pragma mark CCControlSlider Private Methods

- (void)sliderBegan:(CGPoint)location
{
    [thumbSprite_ selected];
    
    self.value = [self valueForLocation:location];
}

- (void)sliderMoved:(CGPoint)location
{
    self.value = [self valueForLocation:location];
}

- (void)sliderEnded:(CGPoint)location
{
    if (thumbSprite_.isSelected)
    {
		[thumbSprite_ unselected];
        
        self.value = [self valueForLocation:thumbSprite_.position];
    }
}

- (float)valueForLocation:(CGPoint)location
{
    float percent = location.x / backgroundSprite_.contentSize.width;
    return minimumValue_ + percent * (maximumValue_ - minimumValue_);
}

@end
