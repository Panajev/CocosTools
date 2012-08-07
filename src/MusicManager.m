//
//  MusicManager.m
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

#import "MusicManager.h"
#import "SimpleAudioEngine.h"
#import "CDXPropertyModifierAction.h"
#import "CCActionManager.h"
#import "OSDefines.h"
#import "SysTools.h"

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
        //SAFE_RELEASE(soundFX);
    }
    soundFX = [[NSMutableDictionary alloc] initWithCapacity:MAX_SOUND_FX];
    
    if (soundFX_ID) {
        //SAFE_RELEASE(soundFX_ID);
    }
    soundFX_ID = [[NSMutableDictionary alloc] initWithCapacity:MAX_SOUND_FX];
    
    if (soundSources) {
        //SAFE_RELEASE(soundSources);
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
-(void) playSFX:(NSString*)filename {
    [self playSFX:filename gain:1 overlap:YES];
}
-(void) playSFX:(NSString*) filename overlap:(BOOL)flag{
    [self playSFX:filename gain:1 overlap:flag];
}

-(void) playSFX:(NSString*) filename gain:(CGFloat)g {
    [self playSFX:filename gain:1 overlap:YES].gain=g;
}

-(CDSoundSource*) playSFX:(NSString*) filename gain:(CGFloat)g  overlap:(BOOL)flag {
    sAudioEngine.effectsVolume=1.0f;
    
    CDSoundSource * soundSource = [sAudioEngine soundSourceForFile:filename];
    CDSoundSource * oldSource = [soundSources objectForKey:filename];
    
    if(oldSource != nil && flag == NO) {
        if(!oldSource.isPlaying) {
            //[soundSource stop];
            [soundSources removeObjectForKey:filename];
        }
        else {
            return oldSource;
        }
    }
    else if (oldSource) {
        //NSLog(@"Play new sound source, overlap = YES.");
        [oldSource play];
        return oldSource;
    }
    
    [soundSource play];
    //NSLog(@"Play new sound source.");
    [soundSources setObject:soundSource forKey:filename];
    
    return soundSource;
}

-(void) stopSFX:(NSString*)filename {
    CDSoundSource * soundSource = [soundSources objectForKey:filename];
    [soundSource stop];
    [soundSources removeObjectForKey:filename];
    //NSLog(@"Stop SFX:...");
}

-(void) stopSFX {
    for (NSString * s in soundSources) {
        if (s != nil) { 
            //NSLog(@"Stop SFX...");
            CDSoundSource * soundSource = (CDSoundSource*)[soundSources objectForKey:s];
            [soundSource stop];
        }
    }
    
    [soundSources removeAllObjects];
}

-(void) pauseSFX:(NSString*)filename {
    CDSoundSource * soundSource = [soundSources objectForKey:filename];
    [soundSource pause];
}

-(void) removePreloadedData {
    for (NSString * s in soundSources) {
        if (s != nil) { 
            //NSLog(@"Stop SFX...");
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
        //SAFE_RELEASE(musicTrackEnqueued);
    }
}

-(void) registerLayer:(CCLayer*)layer {
    cocosLayer = layer;
}

@end
