//
//  TextBoxView.m
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

#import "TextBoxView.h"


@implementation TextBoxView

@synthesize delegate;

- (id) initWithColor:(UIColor *)color width:(CGFloat)w height:(CGFloat)h padding:(CGFloat)padding speed:(CGFloat)ts text:(NSString *)txt {
    
    if ((self = [super initWithFrame:CGRectMake(0, 0, w + (padding * 2), h + (padding * 2))])) {
        self.backgroundColor = color;
        
        width = w;
        height = h;
        
        textSpeed = ts;
        currentPage = 0;
        text = txt;
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(padding, padding, w, h)];
        label.text = @"";
        label.backgroundColor = [UIColor clearColor];
        label.numberOfLines = 0;
        [self addSubview:label];
        
        NSArray *words = [txt componentsSeparatedByString:@" "];
        
        NSString *curText = [words objectAtIndex:0];
        int i = 1;
        
        pages = [[NSMutableArray alloc] init];
        
        while (i < [words count]) {
            
            NSString *nextText = [curText stringByAppendingFormat:@" %@",[words objectAtIndex:i]];
            CGSize size = [nextText sizeWithFont:label.font constrainedToSize:CGSizeMake(w, 99999) lineBreakMode:UILineBreakModeWordWrap];
            
            if (size.height > h) {
                [pages addObject:curText];
                curText = [words objectAtIndex:i];
            } else {
                curText = nextText;
            }
            i++;
        }
        [pages addObject:curText];
    }
    return self;
}



- (void)update:(float)dt {
	
    NSString *page = [pages objectAtIndex:currentPage];
    
	progress += (dt * textSpeed);
	
	int visible = progress;
    if (visible > [page length]) {
        visible = [page length];
    }
    
    NSString *newTxt = [page substringToIndex:visible];
    
    label.text = newTxt;
    label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, width, height);
    [label sizeToFit];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    NSString *page = [pages objectAtIndex:currentPage];
    
    int visible = progress;
    if (visible >= [page length]) {
        
        if (currentPage == [pages count] - 1) {
            if ([delegate respondsToSelector:@selector(textBox:didFinishAllTextWithPageCount:)]) {
                [delegate textBox:(id<TextBox>) self didFinishAllTextWithPageCount:[pages count]];
            }
        } else {
            currentPage++;
            progress = 0;
            
            if ([delegate respondsToSelector:@selector(textBox:didMoveToPage:)]) {
				[delegate textBox:(id<TextBox>) self didMoveToPage:currentPage];
			}
        }
        
    } else {
        progress = [page length];
    }
}

@end
