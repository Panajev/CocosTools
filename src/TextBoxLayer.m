//
//  TextBoxLayer.m
//  TextBoxLayerSample
//
//  Created by Fabio Rodella on 1/19/11.
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

#import "TextBoxLayer.h"

#ifdef __CC_PLATFORM_IOS

// ** external stuff I haven't cleaned up yet!

#define kMasterFontName			@"Helvetica"
#define kMasterFontBigSize		24
#define kMasterFontBig			[UIFont fontWithName:kMasterFontName size:kMasterFontBigSize]
#define kCombatDialogCharacter	@"dialogSound"

inline void PlaySound(NSString* inSoundName) { /* play a character sound here if that's your thing */ }

// ** end external stuff

@implementation TextBoxLayer

@synthesize delegate;

- (id) initWithColor:(UIColor *)color width:(CGFloat)w height:(CGFloat)h padding:(CGFloat)padding speed:(CGFloat)ts text:(NSString *)txt useTTF:(BOOL)ttfFlag{
    
    ttfMode = ttfFlag;
    int numComponents = CGColorGetNumberOfComponents(color.CGColor);
    
    CGFloat r = 0, g = 0, b = 0, a = 1;
    
    if (numComponents == 4)
    {
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        r = components[0];
        g = components[1];
        b = components[2];
        a = components[3];
    }
    
    ccColor4B col = ccc4((GLubyte) r * 255 , (GLubyte) g * 255, (GLubyte) b * 255, (GLubyte) a * 255);
    
	if ((self = [super initWithColor:col width:w + (padding * 2) height:h + (padding * 2)])) {
        
        self.isTouchEnabled = YES;
		
        textSpeed = ts;
        countDownTimer = textSpeed; // Arm the countdown timer.
		ended = NO;
		currentPageIndex = 0;
        
        if(ttfMode) {
            linesPerPage = h / (kMasterFontBig.lineHeight * [CCDirector sharedDirector].contentScaleFactor);
            txt = [txt stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
            txt = [txt stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
        }
        else {
            CCBMFontConfiguration *conf = FNTConfigLoadFile(TEXT_FONT_FILE);
            linesPerPage = h / conf->commonHeight_ * [CCDirector sharedDirector].contentScaleFactor;
        }
		
		NSArray *words = [txt componentsSeparatedByString:@" "];
		
		NSMutableString *wrappedText = [NSMutableString string];
		
		lines = [[NSMutableArray alloc] init];
		
        int wc = 0;
        
		for (NSString *word in words) {
            
            NSString *eval = nil;
            
            if (wc == 0) {
                eval = word;
            } else {
                eval = [wrappedText stringByAppendingFormat:@" %@", word];
            }
            
			int size = [self calculateStringSize:eval];
			
			// See if the text so far plus the new word fits the rect
			if (size > w) {
				
				// If not, closes this line and starts a new one
				[lines addObject:[NSString stringWithString:wrappedText]];
				[wrappedText setString:word];
			} else {
                if (wc > 0) {
                    [wrappedText appendString:@" "];
                }
				[wrappedText appendString:word];
			}
            
            wc++;
		}
        
		[lines addObject:[NSString stringWithString:wrappedText]];
		
		totalPages = ceil((float)[lines count] / linesPerPage);
		
		text = txt;
        
        if(ttfMode) {
            textLabelTTF = [CCLabelTTF labelWithString:[self nextPage]
                                            dimensions:CGSizeMake(w - (padding * 2), h - (padding * 2))
                                            hAlignment:UITextAlignmentLeft
                                         lineBreakMode:UILineBreakModeWordWrap
                                              fontName:kMasterFontName
                                              fontSize:kMasterFontBigSize];
            textLabelTTF.anchorPoint = ccp(0,1);
            textLabelTTF.position = ccp(padding, h + padding);
            textLabelTTF.opacity = 0;
            [self addChild:textLabelTTF];
        }
        else {
            textLabel = [CCLabelBMFont labelWithString:[self nextPage] fntFile:TEXT_FONT_FILE];
            textLabel.anchorPoint = ccp(0,1);
            textLabel.position = ccp(padding, h + padding);
            
            // Hides all characters in the label
            for (CCNode *node in textLabel.children) {
                CCSprite *charSpr = (CCSprite *)node;
                charSpr.opacity = 0;
            }
            [self addChild:textLabel];
        }
		
	}
	return self;
}


- (void)update:(ccTime)dt {
    static int newLineOffset = 0;
    
    if(ttfMode) {
        progress += (dt * TEXT_SPEED_TTF);
        
        int visible = progress;
        
        if (visible > currentPageCharCount) {
            progress = visible = currentPageCharCount;
        }
        
        NSString *newTxt = [currentPage substringToIndex:visible];
        if (![newTxt isEqualToString:textLabelTTF.string] && [newTxt length] > 0) {
            PlaySound(kCombatDialogCharacter);
        }
        textLabelTTF.string = newTxt;
        textLabelTTF.opacity = 255;
    }
    else {
        if(progress > currentPageCharCount - 1) {
            newLineOffset = 0;
            return;
        }
        
        countDownTimer = countDownTimer - dt;
        
        if(countDownTimer < 0) {
            if ([currentPage characterAtIndex:progress + newLineOffset] == '\n') {
                newLineOffset++;
            }
            
            CCSprite *charSpr = (CCSprite *) [textLabel getChildByTag:progress + newLineOffset];
            charSpr.opacity = 255;
            
            progress++;
            
            countDownTimer = textSpeed;
        }
        
        if(progress > currentPageCharCount - 1) {
            if ([delegate respondsToSelector:@selector(textBox:didFinishAllTextOnPage:)]) {
                [delegate textBox:(id<TextBox>) self didFinishAllTextOnPage:currentPageIndex];
            }
        }
    }
}

- (NSString *)nextPage {
	progress = 0;
	
	currentPage = [NSMutableString string];
	
	currentPageCharCount = 0;
	
	int line = currentPageIndex * linesPerPage;
	
	int i = 0;
	while (i < linesPerPage && line < [lines count]) {
		[currentPage appendFormat:@"%@\n", [lines objectAtIndex:line]];
		currentPageCharCount += [[lines objectAtIndex:line] length];
		i++;
		line++;
	}
	currentPageIndex++;
	
	return currentPage;
}

- (int)calculateStringSize:(NSString *)txt {
    
    if(ttfMode) {
        return [txt sizeWithFont:kMasterFontBig].width;
    }
    else {
        
        CCBMFontConfiguration *conf = FNTConfigLoadFile(TEXT_FONT_FILE);
        
        int totalSize = 0;
        
        for (int i = 0; i < [txt length] / [CCDirector sharedDirector].contentScaleFactor; i++) {
            
            int c = [txt characterAtIndex:i];
            tFontDefHashElement *def = NULL;
            HASH_FIND_INT(conf->fontDefDictionary_,&c,def);
            if(def != NULL) {
                totalSize += def->fontDef.xAdvance;
            }
        }
        
        return totalSize;
        
    }
}

-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	if (progress < currentPageCharCount) {
		
        if(!ttfMode) {
            for (CCNode *node in textLabel.children) {
                CCSprite *charSpr = (CCSprite *)node;
                charSpr.opacity = 255;
            }
        }
		progress = currentPageCharCount;
		if(progress > currentPageCharCount - 1) {
			if ([delegate respondsToSelector:@selector(textBox:didFinishAllTextOnPage:)]) {
				[delegate textBox:(id<TextBox>) self didFinishAllTextOnPage:currentPageIndex];
			}
		}
		
	} else {
        
		if (currentPageIndex < totalPages) {
			[textLabel setString:[self nextPage]];
			
			for (CCNode *node in textLabel.children) {
				CCSprite *charSpr = (CCSprite *)node;
				charSpr.opacity = 0;
			}
			
			if ([delegate respondsToSelector:@selector(textBox:didMoveToPage:)]) {
				[delegate textBox:(id<TextBox>) self didMoveToPage:currentPageIndex];
			}
			
		} else {
			
			if (!ended) {
				ended = YES;
                
				if ([delegate respondsToSelector:@selector(textBox:didFinishAllTextWithPageCount:)]) {
					[delegate textBox:(id<TextBox>) self didFinishAllTextWithPageCount:totalPages];
				}
			}
		}
	}
}

@end

#endif
