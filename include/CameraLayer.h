//
//  CameraLayer.h
//
//  Created by Allan Kerr on 2012-08-03.
//
//

#import "CCLayer.h"

@interface CameraLayer : CCLayer
{
@protected
    BOOL rotate_;
    BOOL following_;
    BOOL cameraEnabled_;
    
@private
    CGSize winSize;
    CCNode *target;
}
@property (readwrite, nonatomic, assign) BOOL rotate;
@property (readonly, nonatomic, assign) BOOL following;
@property (readwrite, nonatomic, assign) BOOL cameraEnabled;
- (void)follow:(CCNode *)target rotate:(BOOL)rotate;
- (void)stopFollow;
@end