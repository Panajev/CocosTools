//
//  MusicManager.h
//  OminoDelleTasche
//
//  Created by Goffredo Marocchi on 1/19/12.
//  Copyright (c) 2012 AddictiveColors. All rights reserved.
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
#include <CoreGraphics/CoreGraphics.h>
#import "SynthesizeSingleton.h"

@class SimpleAudioEngine, CDAudioManager, CDSoundSource, CCLayer;

typedef enum {
	kGSUninitialised,
	kGSAudioManagerInitialising,
	kGSAudioManagerInitialised,
	kGSLoadingSounds,
	kGSOkay,//only use when in this state
	kGSFailed
} tGameSoundState;

#define MAX_SOUND_FX (16)

@interface MusicManager : NSObject {
    tGameSoundState state_;
    SimpleAudioEngine *sAudioEngine;
    CDAudioManager *cdAudioMgr;
    BOOL isBackgroundMusicPlaying_;
    BOOL setupHasRun;
    CGFloat volumeLevel;
    BOOL mute_;
    NSString * musicTrackEnqueued;
    NSString * soundFXEnqueued;
    
    NSMutableDictionary * soundFX;
    NSMutableDictionary * soundFX_ID;
    NSMutableDictionary * soundSources;
    CCLayer* cocosLayer;
}

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(MusicManager);

@property (assign) BOOL isBackgroundMusicPlaying;
@property (assign) BOOL mute;
-(void) setUpAudioManager;
-(void) setUpAudioEngines;
-(void) preloadMusic:(NSString*) filename;
-(void) preloadSFX:(NSString*) filename;
-(void) resumeMusic;
-(void) pauseMusic;
-(void) playMusic:(NSString*) filename;
-(void) stopMusic;
-(void) playSFX:(NSString*) filename;
-(void) playSFX:(NSString*) filename gain:(CGFloat)g;
-(CDSoundSource*) playSFX:(NSString*) filename gain:(CGFloat)g overlap:(BOOL)flag;
-(void) stopSFX:(NSString*)filename;
-(void) stopSFX;
-(void) pauseSFX:(NSString*)filename;
-(void) setVolume:(CGFloat)volume;
-(CGFloat) volume;
-(void) removePreloadedData;
-(void) fadeOutMusic;
-(void) toggleMute;
-(void) registerLayer:(CCLayer*)layer;

@end
