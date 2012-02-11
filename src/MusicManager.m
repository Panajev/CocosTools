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
    
    if (soundSources) {
        SAFE_RELEASE(soundSources);
    }
    soundSources = [[NSMutableDictionary alloc] initWithCapacity:MAX_SOUND_FX];
    
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
    [soundSources setObject:[sAudioEngine soundSourceForFile:filename] forKey:filename];
}
-(CDSoundSource*) playSFX:(NSString*) filename {
    sAudioEngine.effectsVolume=1.0f;
    CDSoundSource * soundSource = [sAudioEngine soundSourceForFile:filename];
    if(!soundSource.isPlaying) {
        CDSoundSource * oldSource = [soundSources objectForKey:filename];
        [oldSource stop];
        
        [soundSource rewind];
        [soundSource play];
        [soundSources setObject:soundSource forKey:filename];
    }
    
    return soundSource;
}

-(void) playSFX:(NSString*) filename gain:(CGFloat)g {
    [self playSFX:filename].gain=g;
}

-(void) stopSFX:(NSString*)filename {
    CDSoundSource * soundSource = [soundSources objectForKey:filename];
    [soundSource stop];
    [soundSources removeObjectForKey:filename];
}

-(void) stopSFX {
    for (NSString * s in soundSources) {
        if (s != nil) { 
            NSLog(@"Stop SFX...");
            CDSoundSource * soundSource = (CDSoundSource*)[soundSources objectForKey:s];
            [soundSource stop];
        }
    }
    
    [soundSources removeAllObjects];
}

-(void) removePreloadedData {
    for (NSString * s in soundSources) {
        if (s != nil) { 
            NSLog(@"Stop SFX...");
            CDSoundSource * soundSource = (CDSoundSource*)[soundSources objectForKey:s];
            [soundSource stop];
        }
    }
    [soundSources removeAllObjects];
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
