//
//  TextBox.h
//  TextBoxLayerSample
//
//  Created by Fabio Rodella on 04/10/11.
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

#import <Foundation/Foundation.h>

#define TEXT_SPEED 60
#define TEXT_FONT_FILE @"arial16.fnt"

@protocol TextBox <NSObject>

- (id) initWithColor:(UIColor *)color 
			   width:(CGFloat)w 
			  height:(CGFloat)h 
			 padding:(CGFloat)padding
               speed:(CGFloat)ts
				text:(NSString *)txt;

- (void)update:(float)dt;

@end

@protocol TextBoxDelegate <NSObject>

- (void)textBox:(id<TextBox>)tbox didFinishAllTextWithPageCount:(int)pc;

@optional
- (void)textBox:(id<TextBox>)tbox didMoveToPage:(int)p;
- (void)textBox:(id<TextBox>)tbox didFinishAllTextOnPage:(int)p;
@end
