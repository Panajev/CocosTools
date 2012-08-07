//
//  CameraLayer.m
//
//  Created by Allan Kerr on 2012-08-03.
//
//

#import "CameraLayer.h"
#import "CCNode.h"
#import "CCGrid.h"
#import "CCDirector.h"
#import "CCActionManager.h"
#import "CCCamera.h"
#import "CCScheduler.h"
#import "ccConfig.h"
#import "ccMacros.h"
#import "Support/CGPointExtension.h"
#import "Support/ccCArray.h"
#import "Support/TransformUtils.h"
#import "ccMacros.h"
#import "CCGLProgram.h"

// externals
#import "kazmath/GL/matrix.h"

#ifdef __CC_PLATFORM_IOS
#import "Platforms/iOS/CCDirectorIOS.h"
#endif

@implementation CameraLayer
@synthesize rotate = rotate_;
@synthesize following = following_;
@synthesize cameraEnabled = cameraEnabled_;

- (void)setCameraEnabled:(BOOL)cameraEnabled
{
    float scaleFactor = CC_CONTENT_SCALE_FACTOR();
    CGSize contentSizeSpritePixels = contentSize_;
    contentSizeSpritePixels.width *= scaleFactor;
    contentSizeSpritePixels.height *= scaleFactor;
    
    if (cameraEnabled != cameraEnabled_)
    {
        cameraEnabled_ = cameraEnabled;
        if (cameraEnabled_)
        {
            anchorPoint_ = ccp(contentSizeSpritePixels.width * anchorPoint_.x, contentSizeSpritePixels.height * anchorPoint_.y);
            //anchorPoint_ = ccp(contentSizeInPixels_.width * anchorPoint_.x, contentSizeInPixels_.height * anchorPoint_.y);
        }
        else
        {
            anchorPoint_ = ccp(contentSizeSpritePixels.width * anchorPoint_.x, contentSizeSpritePixels.height * anchorPoint_.y);
            //anchorPoint_ = ccp(contentSizeInPixels_.width * anchorPoint_.x, contentSizeInPixels_.height * anchorPoint_.y);
        }
    }
}

- (void)setRotation:(float)rotation
{
    if (!following_ || (following_ && !rotate_))
    {
        super.rotation = rotation;
    }
}

- (void)setPosition:(CGPoint)position
{
    if (!following_)
    {
        super.position = position;
    }
}

- (void)setAnchorPoint:(CGPoint)point
{
	if (!CGPointEqualToPoint(point, anchorPoint_))
    {
        float scaleFactor = CC_CONTENT_SCALE_FACTOR();
        CGSize contentSizeSpritePixels = contentSize_;
        contentSizeSpritePixels.width *= scaleFactor;
        contentSizeSpritePixels.height *= scaleFactor;
        
		anchorPoint_ = point;
        if (cameraEnabled_)
        {
            anchorPoint_ = ccp(winSize.width * anchorPoint_.x, winSize.height * anchorPoint_.y );
        }
        else
        {
            anchorPoint_ = ccp(contentSizeSpritePixels.width * anchorPoint_.x, contentSizeSpritePixels.height * anchorPoint_.y );
        }
		isTransformDirty_ = isInverseDirty_ = YES;
#if CC_NODE_TRANSFORM_USING_AFFINE_MATRIX
		isTransformGLDirty_ = YES;
#endif
	}
}

- (id)init
{
    if (self = [super init])
    {
        cameraEnabled_ = YES;
        winSize = [CCDirector sharedDirector].winSize;
    }
    return self;
}

- (void)follow:(CCNode *)target_ rotate:(BOOL)rotate
{
    cameraEnabled_ = YES;
    rotate_ = rotate;
    
    target = target_;
    [self schedule:@selector(following:)];
}

- (void)following:(ccTime)dt
{
    self.position = target.position;
    if (rotate_)
    {
        self.rotation = target.rotation;
    }
}

- (void)stopFollow
{
    [self unschedule:@selector(following:)];
}

- (CGAffineTransform)cameraTransform
{
    transform_ = CGAffineTransformIdentity;
    if (scaleX_ != 1 || scaleY_ != 1)
    {
        transform_ = CGAffineTransformScale(transform_, scaleX_, scaleY_);
    }
    if (!CGPointEqualToPoint(anchorPoint_, CGPointZero))
    {
        transform_ = CGAffineTransformTranslate(transform_, anchorPoint_.x / scaleX_, anchorPoint_.y / scaleY_);
    }
    if (skewX_ != 0 || skewY_ != 0)
    {
        CGAffineTransform skew = CGAffineTransformMake(1.0f, tanf(CC_DEGREES_TO_RADIANS(skewY_)), tanf(CC_DEGREES_TO_RADIANS(skewX_)), 1.0f, 0.0f, 0.0f);
        transform_ = CGAffineTransformConcat(skew, transform_);
    }
    if (rotation_ != 0)
    {
        transform_ = CGAffineTransformRotate(transform_, CC_DEGREES_TO_RADIANS(rotation_));
    }
    if (!CGPointEqualToPoint(position_, CGPointZero))
    {
        transform_ = CGAffineTransformTranslate(transform_, -position_.x, -position_.y);
    }
    return transform_;
}

- (void)transform
{
    if (cameraEnabled_)
    {
        kmMat4 transform4x4;
        
        if (isTransformDirty_)
        {
            CGAffineTransform t = [self cameraTransform];
            CGAffineToGL(&t, transform4x4.mat);
            
            // Update Z vertex manually
            transform4x4.mat[14] = vertexZ_;
            
            kmGLMultMatrix( &transform4x4 );
            isTransformDirty_ = NO;
        }
        kmGLMultMatrix( &transform4x4 );
    }
    else
    {
        [super transform];
    }
}

- (CGPoint)convertToNodeSpace:(CGPoint)worldPoint
{
    if (cameraEnabled_)
    {
        CGPoint scaledAnchor = ccp(anchorPoint_.x / scaleX_, anchorPoint_.y / scaleY_);
        CGPoint scaledPoint = ccp(worldPoint.x / scaleX_, worldPoint.y / scaleY_);
        return ccpAdd(ccpSub(position_, scaledAnchor), scaledPoint);
    }
    return [super convertToNodeSpace:worldPoint];
}


@end