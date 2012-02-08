//
//  MusicManager.h
//  OminoDelleTasche
//
//  Created by Goffredo Marocchi on 1/19/12.
//  Copyright (c) 2012 IGGS. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CoreGraphics/CoreGraphics.h>
#import "SynthesizeSingleton.h"

@class SimpleAudioEngine, CDAudioManager;

typedef enum {
	kGSUninitialised,
	kGSAudioManagerInitialising,
	kGSAudioManagerInitialised,
	kGSLoadingSounds,
	kGSOkay,//only use when in this state
	kGSFailed
} tGameSoundState;

@interface MusicManager : NSObject {
    tGameSoundState state_;
    SimpleAudioEngine *sAudioEngine;
    CDAudioManager *cdAudioMgr;
    BOOL isBackgroundMusicPlaying_;
    BOOL setupHasRun;
    CGFloat volumeLevel;
    BOOL mute_;
    NSString * musicTrackEnqueued;
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
-(void) setVolume:(CGFloat)volume;
-(CGFloat) volume;
-(void) removePreloadedData;
-(void) fadeOutMusic;
-(void) toggleMute;


@end
