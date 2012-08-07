//
//  CCProgressBar.m
//  iMoonlightsHD
//
//  Created by macbook on 10/08/11.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the
//  following conditions are met:
//
//      Redistributions of source code must retain the above copyright notice, this list of conditions and the following
//      disclaimer.
//      Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
//      disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
//  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL COPYRIGHT HOLDERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
//  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "CCProgressBar.h"

#import "ccConfig.h"
#import "Support/CGPointExtension.h"
#import "CCSpriteScale9.h"

@interface CCProgressBar (Private)
-(void)update;
@end


@implementation CCProgressBar
-(id)initWithBgSprite:(CCSpriteScale9*)b andFgSprite:(CCSpriteScale9*)f andSize:(CGSize)s andMargin:(CGSize)m {
	self = [super init];
	if (self != nil) {
		bg=b;
		fg=f;
		progress=0.0f;
		[self addChild:b];
		[self addChild:f];
		margin=m;
		[self setContentSize:s];
		self.anchorPoint=ccp(0.5f,0.5f);
		animAngle=0;
	}
	return self;
}
+(id)progressBarWithBgSprite:(CCSpriteScale9*)b andFgSprite:(CCSpriteScale9*)f andSize:(CGSize)s andMargin:(CGSize)m {
	return [[self alloc] initWithBgSprite:b andFgSprite:f andSize:s andMargin:m];
}
-(void)update {
	[bg adaptiveScale9:contentSize_];
	CGSize s=contentSize_;
    s.height=(s.height-2*margin.height);
	s.width=s.height+(s.width-2*margin.width-s.height)*progress;
	
	//if (s.width<s.height) s.width=s.height;
	[fg adaptiveScale9:s];
	bg.position=ccp(bg.contentSize.width*bg.scaleX*0.5f,bg.contentSize.height*bg.scaleY*0.5f);
	
	float minX=margin.width+fg.contentSize.width*fg.scaleX*0.5f;
	float maxX=bg.contentSize.width*bg.scaleX-minX;
	fg.position=ccp((minX+maxX)*0.5f-cos(animAngle)*0.5f*(maxX-minX),margin.height+fg.contentSize.height*fg.scaleY*0.5f);
	//fg.position=ccp(margin.width+fg.contentSize.width*fg.scaleX*0.5f,margin.height+fg.contentSize.height*fg.scaleY*0.5f);
}
-(void)setProgress:(float)p {
	progress=p;
	if (progress<0.0f) progress=0.0f;
	else if (progress>1.0f) progress=1.0f;
	[self update];
}
-(void)setContentSize:(CGSize)s {
	[super setContentSize:s];
	[self update];
}
-(void)startAnimation {
	[self schedule:@selector(tick:)];
}
-(void)stopAnimation {
	[self unschedule:@selector(tick:)];
	animAngle=0;
}
-(void)tick:(ccTime)dt {
	animAngle+=dt*5;
	[self update];
}
-(void)setOpacity:(GLubyte)opacity {
    fg.opacity=opacity;
    bg.opacity=opacity;
}
@end
