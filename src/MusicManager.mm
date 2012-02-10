//
//  MusicManager.m
//  OminoDelleTasche
//
//  Created by Goffredo Marocchi on 1/19/12.
//  Copyright (c) 2012 IGGS. All rights reserved.
//

#import "MusicManager.h"
#import "SimpleAudioEngine.h"
#import "CDXPropertyModifierAction.h"
#import "CCActionManager.h"
#import "OSDefines.h"

@implementation MusicManager
SYNTHESIZE_SINGLETON_FOR_CLASS(MusicManager);

@synthesize isBackgroundMusicPlaying=isBackgroundMusicPlaying_, mute=mute_;

-(void) resumeMusic {
    [self setUpAudioEngines];
    [sAudioEngine resumeBackgroundMusic];
}

-(void) pauseMusic {
    [sAudioEngine pauseBackgroundMusic];
}


-(void) setUpAudioManager {
	state_ = kGSAudioManagerInitialising;
    
	//Set up the mixer rate for sound engine. This must be done before the audio manager is initialised.
	//For performance Apple recommends having all your samples at the same sample rate and setting the mixer rate to the same value.
	[CDSoundEngine setMixerSampleRate:CD_SAMPLE_RATE_HIGH];
    
	//Initialise audio manager asynchronously as it can take a few seconds
	//The FXPlusMusicIfNoOtherAudio mode will check if the user is playing music and disable background music playback if
	//that is the case.
	[CDAudioManager initAsynchronously:kAMM_FxPlusMusicIfNoOtherAudio];
    volumeLevel = 1.0f;
    
}

-(void) setUpAudioEngines {
    setupHasRun = NO;
    sAudioEngine = [SimpleAudioEngine sharedEngine];
    cdAudioMgr = [CDAudioManager sharedManager];
    mute_ = NO;
    isBackgroundMusicPlaying_ = NO;
    
    if (soundFX) {
        SAFE_RELEASE(soundFX);
    }
    soundFX = [[NSMutableDictionary alloc] initWithCapacity:MAX_SOUND_FX];
    
    if (soundFX_ID) {
        SAFE_RELEASE(soundFX_ID);
    }
    soundFX_ID = [[NSMutableDictionary alloc] initWithCapacity:MAX_SOUND_FX];
    
    [self setUpAudioManager];
}

-(void) preloadMusic:(NSString*) filename {
    [sAudioEngine preloadBackgroundMusic:filename];
}
-(void) actionComplete:(id)filename{
    [sAudioEngine setBackgroundMusicVolume:1.0f];
    [sAudioEngine playBackgroundMusic:(NSString*)filename];
}

-(void) playMusic:(NSString*) filename {
	if (![sAudioEngine isBackgroundMusicPlaying]) {
		[sAudioEngine setBackgroundMusicVolume:1.0f];
		[sAudioEngine rewindBackgroundMusic];
		[sAudioEngine playBackgroundMusic:filename];
	} else {
        [CDXPropertyModifierAction fadeBackgroundMusic:0.6f finalVolume:0.0f curveType:kIT_SCurve shouldStop:YES];
        [self performSelector:@selector(actionComplete:) withObject:filename afterDelay:0.8f];
	}
    
    if(mute_ == YES) {
        if(musicTrackEnqueued != filename) {
            [musicTrackEnqueued release];
            [filename retain];
            musicTrackEnqueued = filename;
        }
    }
}

-(void) stopMusic {
    [self fadeOutMusic];
    [sAudioEngine stopBackgroundMusic];
    isBackgroundMusicPlaying_ = NO;
}

-(void) setVolume:(CGFloat)volume {
    [sAudioEngine setBackgroundMusicVolume:volume];
    volumeLevel = volume;
}
-(CGFloat) volume {
    return volumeLevel;
}

-(void) preloadSFX:(NSString*) filename {
    [sAudioEngine preloadEffect:filename];
}
-(void) playSFX:(NSString*) filename {
    sAudioEngine.effectsVolume=1.0f;
    ALuint sid =  [sAudioEngine playEffect:filename];
    [soundFX setObject:[NSNumber numberWithFloat:0.0f] forKey:filename];
    [soundFX_ID setObject:[NSNumber numberWithUnsignedInt:sid] forKey:filename];
    soundFXEnqueued = filename;
}

-(void) playSFX:(NSString*) filename length:(CGFloat)time {
    if(![soundFX objectForKey:filename]) {
        sAudioEngine.effectsVolume=1.0f;
        ALuint sid = [sAudioEngine playEffect:filename];
        [soundFX setObject:[NSNumber numberWithFloat:time] forKey:filename];
        [soundFX_ID setObject:[NSNumber numberWithUnsignedInt:sid] forKey:filename];
        [self performSelector:@selector(removeSound:) withObject:filename afterDelay:time];
        soundFXEnqueued = filename;
    }
}

-(void) playSFX:(NSString*) filename length:(CGFloat)time gain:(CGFloat)g {
    if(![soundFX objectForKey:filename]) {
        sAudioEngine.effectsVolume=1.0f;
        ALuint sid = [sAudioEngine playEffect:filename pitch:1.0f pan:0.0f gain:g];
        [soundFX setObject:[NSNumber numberWithFloat:time] forKey:filename];
        [soundFX_ID setObject:[NSNumber numberWithUnsignedInt:sid] forKey:filename];
        [self performSelector:@selector(removeSound:) withObject:filename afterDelay:time];
        soundFXEnqueued = filename;
    }
}

-(void) stopLastSFX {
    NSNumber * sid = nil;
    sid = [soundFX_ID objectForKey:soundFXEnqueued];
    if(sid) {
        [sAudioEngine stopEffect:[sid unsignedIntValue]];
    }
    
    [self removeSound:soundFXEnqueued];
}

-(void) stopSFX:(NSString*)filename {
    NSNumber * sid = nil;
    sid = [soundFX_ID objectForKey:filename];
    if(sid) {
        [sAudioEngine stopEffect:[sid unsignedIntValue]];
    }
    
    [self removeSound:filename];
}

-(void) stopSFX {
    NSLog(@"Stop SFX...");
    for (NSString * s in [soundFX_ID allKeys]) {
        if (s != nil) { 
            [sAudioEngine stopEffect:[[soundFX_ID objectForKey:s] unsignedIntValue]];
        }
    }
    
    [soundFX removeAllObjects];
    [soundFX_ID removeAllObjects];
}

- (void) removeSound:(NSString*) filename {
    [soundFX removeObjectForKey:filename];
    [soundFX_ID removeObjectForKey:filename];
}

-(void) removePreloadedData {
    for (NSString * s in [soundFX allKeys]) {
        if (s != nil) { 
            [sAudioEngine unloadEffect:s];
        }
    }
    [soundFX removeAllObjects];
    [soundFX_ID removeAllObjects]; 
}

-(void) fadeOutMusic {
	[CDXPropertyModifierAction fadeBackgroundMusic:1.0f finalVolume:0.0f curveType:kIT_SCurve shouldStop:YES];
}

-(void) toggleMute {
    mute_ = ! mute_;
    [sAudioEngine setMute:mute_];
    [cdAudioMgr setMute:mute_];
    
    if(mute_ == NO && musicTrackEnqueued != nil) {
        [self playMusic:musicTrackEnqueued];
        SAFE_RELEASE(musicTrackEnqueued);
    }
}

@end
