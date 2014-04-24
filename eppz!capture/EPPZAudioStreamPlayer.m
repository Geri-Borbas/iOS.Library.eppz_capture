//
//  EPPZAudioStreamPlayer.m
//  eppz!kit
//
//  Created by Borbás Geri on 24/04/14.
//  Copyright (c) 2014 eppz! development, LLC.
//
//  follow http://www.twitter.com/_eppz
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "EPPZAudioStreamPlayer.h"


#ifndef min
#define min( a, b ) ( ((a) < (b)) ? (a) : (b) )
#endif


static OSStatus _status;
static EPPZAudioStreamPlayer* _self = nil;
static AudioUnitElement _outputBus = 0; // Output audio unit identifier


@interface EPPZAudioStreamPlayer ()


{
    OSStatus _status;
    AudioComponentInstance _audioUnit;
    AudioBuffer _temporaryBuffer;
}
@property (nonatomic, readonly) AudioComponentInstance audioUnit;
@property (nonatomic, readonly) AudioBuffer temporaryBuffer;


@end


@implementation EPPZAudioStreamPlayer
@synthesize audioUnit = _audioUnit;
@synthesize temporaryBuffer = _temporaryBuffer;


#pragma mark - Creation

-(instancetype)init
{
    if (self = [super init])
    { _self = self; } // Reference to be used in function implementations
    return self;
}

-(void)dealloc
{
    [self stop];
    
    // Tear down.
    AudioUnitUninitialize(_audioUnit);
	free(_temporaryBuffer.mData);
}


#pragma mark - Setup

void checkForError()
{
	if (_status)
    { printf("EPPZAudioStreamPlayer error: status (%d) \n", (int)_status); }
}

-(void)setupForFormat:(AudioStreamBasicDescription) format
{
	// Describe audio component.
	AudioComponentDescription desc;
	desc.componentType = kAudioUnitType_Output;
	desc.componentSubType = kAudioUnitSubType_RemoteIO;
	desc.componentFlags = 0;
	desc.componentFlagsMask = 0;
	desc.componentManufacturer = kAudioUnitManufacturer_Apple;
	
	// Get component.
	AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
	
	// Get audio units.
	_status = AudioComponentInstanceNew(inputComponent, &_audioUnit);
	checkForError();
	
	// Enable IO for playback.
	UInt32 flag = 1;
	_status = AudioUnitSetProperty(_audioUnit,
                                   kAudioOutputUnitProperty_EnableIO,
                                   kAudioUnitScope_Output,
                                   _outputBus,
                                   &flag,
                                   sizeof(flag));
	checkForError();
	
	// Apply format.
	_status = AudioUnitSetProperty(_audioUnit,
                                   kAudioUnitProperty_StreamFormat,
                                   kAudioUnitScope_Input,
                                   _outputBus,
                                   &format,
                                   sizeof(format));
	checkForError();
	
	// Set output callback.
	AURenderCallbackStruct callbackStruct;
	callbackStruct.inputProc = playbackCallback;
	callbackStruct.inputProcRefCon = (__bridge void*)(self);
	_status = AudioUnitSetProperty(_audioUnit,
                                   kAudioUnitProperty_SetRenderCallback,
                                   kAudioUnitScope_Global,
                                   _outputBus,
                                   &callbackStruct,
                                   sizeof(callbackStruct));
	checkForError();
		
	// Initialize.
	_status = AudioUnitInitialize(_audioUnit);
	checkForError();
}

-(void)start
{
	_status = AudioOutputUnitStart(_audioUnit);
	checkForError();
}

-(void)stop
{
	_status = AudioOutputUnitStop(_audioUnit);
	checkForError();
}


#pragma mark - User input

-(void)submitAudioBufferListForPlay:(AudioBufferList*) bufferList
{
	AudioBuffer firstBuffer = bufferList->mBuffers[0];
	
	// Size `temporaryBuffer` for the buffer size sent.
	if (_temporaryBuffer.mDataByteSize != firstBuffer.mDataByteSize)
    {
		free(_temporaryBuffer.mData);
		_temporaryBuffer.mDataByteSize = firstBuffer.mDataByteSize;
		_temporaryBuffer.mData = malloc(firstBuffer.mDataByteSize);
	}
	
	// Copy incoming audio data to `temporaryBuffer`.
    memcpy(_temporaryBuffer.mData, bufferList->mBuffers[0].mData, bufferList->mBuffers[0].mDataByteSize);
}


#pragma mark - Audio unit playback callback

static OSStatus playbackCallback(void *inRefCon,
								 AudioUnitRenderActionFlags *ioActionFlags,
								 const AudioTimeStamp *inTimeStamp,
								 UInt32 inBusNumber,
								 UInt32 inNumberFrames,
								 AudioBufferList *bufferList)
{
    // Enumerate buffers (though, we'll probably have only one).
	for (int index = 0; index < bufferList->mNumberBuffers; index++)
    {
		AudioBuffer eachBuffer = bufferList->mBuffers[index];
		
        if (NO)
        NSLog(@"Buffer %d has %d channels and wants %d bytes of data.",
              index,
              (unsigned int)eachBuffer.mNumberChannels,
              (unsigned int)eachBuffer.mDataByteSize);
		
		// Copy temporary buffer data to output buffer (don't copy more data then we have, or then fits).
		UInt32 sizeToWriteIntoTheQueue = min(eachBuffer.mDataByteSize, _self.temporaryBuffer.mDataByteSize);
        
        // Play!
		memcpy(eachBuffer.mData, _self.temporaryBuffer.mData, sizeToWriteIntoTheQueue);
		eachBuffer.mDataByteSize = sizeToWriteIntoTheQueue; // Indicate how much data we wrote in the buffer
	}
	
    return noErr;
}




@end
