/*
 * CCControlSaturationBrightnessPicker.m
 *
 * Copyright 2012 Stewart Hamilton-Arrandale.
 * http://creativewax.co.uk
 *
 * Modified by Yannick Loriot.
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

#import "CCControlSaturationBrightnessPicker.h"
#import "Utils.h"

@interface CCControlSaturationBrightnessPicker ()

- (void)updateSliderPosition:(CGPoint)sliderPosition;
- (BOOL)checkSliderPosition:(CGPoint)location;

@end

@implementation CCControlSaturationBrightnessPicker
@synthesize saturation  = saturation_;
@synthesize brightness  = brightness_;

- (void)dealloc
{
    [self removeAllChildrenWithCleanup:YES];
    
    background  = nil;
    overlay     = nil;
    shadow      = nil;
    slider      = nil;
    
	[super dealloc];
}

- (id)initWithTarget:(id)target withPos:(CGPoint)pos
{
    if ((self = [super init]))
    {
		// Add sprites
        background      = [Utils addSprite:@"colourPickerBackground.png" toTarget:target withPos:pos andAnchor:ccp(0, 0)];
        overlay         = [Utils addSprite:@"colourPickerOverlay.png" toTarget:target withPos:pos andAnchor:ccp(0, 0)];
        shadow          = [Utils addSprite:@"colourPickerShadow.png" toTarget:target withPos:pos andAnchor:ccp(0, 0)];
        slider          = [Utils addSprite:@"colourPicker.png" toTarget:target withPos:pos andAnchor:ccp(0.5f, 0.5f)];
        
        startPos        = pos;	// starting position of the colour picker
        boxPos          = 35;	// starting position of the virtual box area for picking a colour
        boxSize         = 150;	// the size (width and height) of the virtual box for picking a colour from
    }
    return self;
}


#pragma mark - 
#pragma mark CCControlPicker Public Methods

- (void)updateWithHSV:(HSV)hsv
{
    HSV hsvTemp;
    hsvTemp.s = 1;
    hsvTemp.h = hsv.h;
    hsvTemp.v = 1;
    
    RGBA rgb    = [CCColourUtils RGBfromHSV:hsvTemp];
    
    [background setColor:ccc3(rgb.r * 255.0f, rgb.g * 255.0f, rgb.b * 255.0f)];
}

- (void)updateDraggerWithHSV:(HSV)hsv
{
    // Set the position of the slider to the correct saturation and brightness
    CGPoint pos	= CGPointMake(
                              startPos.x + boxPos + (boxSize*(1 - hsv.s)),
                              startPos.y + boxPos + (boxSize*hsv.v));
    
    // update
    [self updateSliderPosition:pos];
}

#pragma mark CCControlPicker Private Methods

- (void)updateSliderPosition:(CGPoint)sliderPosition
{
    // Clamp the position of the icon within the circle
    
    // Get the center point of the bkgd image
    float centerX           = startPos.x + background.boundingBox.size.width*.5;
    float centerY           = startPos.y + background.boundingBox.size.height*.5;
    
    // Work out the distance difference between the location and center
    float dx                = sliderPosition.x - centerX;
    float dy                = sliderPosition.y - centerY;
    float dist              = sqrtf(dx * dx + dy * dy);
    
    // Update angle by using the direction of the location
    float angle             = atan2f(dy, dx);
    
    // Set the limit to the slider movement within the colour picker
    float limit             = background.boundingBox.size.width*.5;
    
    // Check distance doesn't exceed the bounds of the circle
    if (dist > limit)
    {
        sliderPosition.x    = centerX + limit * cosf(angle);
        sliderPosition.y    = centerY + limit * sinf(angle);
    }
    
    // Set the position of the dragger
    slider.position         = sliderPosition;
    
    
    // Clamp the position within the virtual box for colour selection
    if (sliderPosition.x < startPos.x + boxPos)						sliderPosition.x = startPos.x + boxPos;
    else if (sliderPosition.x > startPos.x + boxPos + boxSize - 1)	sliderPosition.x = startPos.x + boxPos + boxSize - 1;
    if (sliderPosition.y < startPos.y + boxPos)						sliderPosition.y = startPos.y + boxPos;
    else if (sliderPosition.y > startPos.y + boxPos + boxSize)		sliderPosition.y = startPos.y + boxPos + boxSize;
    
    // Use the position / slider width to determin the percentage the dragger is at
    self.saturation         = 1 - ABS((startPos.x + boxPos - sliderPosition.x)/boxSize);
    self.brightness         = ABS((startPos.y + boxPos - sliderPosition.y)/boxSize);
}

-(BOOL)checkSliderPosition:(CGPoint)location
{
    // Clamp the position of the icon within the circle
    
    // get the center point of the bkgd image
    float centerX           = startPos.x + background.boundingBox.size.width*.5;
    float centerY           = startPos.y + background.boundingBox.size.height*.5;
    
    // work out the distance difference between the location and center
    float dx                = location.x - centerX;
    float dy                = location.y - centerY;
    float dist              = sqrtf(dx*dx+dy*dy);
    
    // check that the touch location is within the bounding rectangle before sending updates
	if (dist <= background.boundingBox.size.width*.5)
    {
        [self updateSliderPosition:location];
        
        // send CCControl callback
        [self sendActionsForControlEvents:CCControlEventValueChanged];
        
        return YES;
    }
    return NO;
}


#pragma mark -
#pragma mark CCTargetedTouch Delegate Methods

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	// Get the touch location
	CGPoint touchLocation   = [self touchLocation:touch];
	
    // check the touch position on the slider
	return [self checkSliderPosition:touchLocation];
}

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	// Get the touch location
	CGPoint touchLocation   = [self touchLocation:touch];
	
    // check the touch position on the slider
	[self checkSliderPosition:touchLocation];
}

#elif __MAC_OS_X_VERSION_MAX_ALLOWED

- (BOOL)ccMouseDown:(NSEvent *)event
{
    // Get the event location
	CGPoint eventLocation   = [self eventLocation:event];
	
    // Check the touch position on the slider
    [self checkSliderPosition:eventLocation];
    
    return NO;
}

- (BOOL)ccMouseDragged:(NSEvent *)event
{
	// Get the event location
	CGPoint eventLocation   = [self eventLocation:event];
	
    // Check the touch position on the slider
    return [self checkSliderPosition:eventLocation];
}

#endif

@end
