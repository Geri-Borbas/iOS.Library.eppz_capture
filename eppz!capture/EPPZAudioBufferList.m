//
//  EPPZAudioBufferList.m
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

#import "EPPZAudioBufferList.h"


@interface EPPZAudioBufferList ()


@property (nonatomic) UInt32 mNumberBuffers; // The number of AudioBuffers in the mBuffers array.
@property (nonatomic, strong) NSArray *mBuffers; // A variable length array of AudioBuffers.


@end


@implementation EPPZAudioBufferList


#pragma mark - Creation

+(instancetype)audioBufferListFromAudioBufferListStruct:(AudioBufferList) audioBufferList
{
    EPPZAudioBufferList *instance = [self new];
    [instance representAudioBufferListStruct:audioBufferList];
    return instance;
}

-(void)representAudioBufferListStruct:(AudioBufferList) audioBufferList
{
    self.mNumberBuffers = audioBufferList.mNumberBuffers;
    
    NSMutableArray *mBuffers = [NSMutableArray new]; // Mutable
    for (int index = 0; index < audioBufferList.mNumberBuffers; index++)
    {
        AudioBuffer eachAudioBufferStruct = audioBufferList.mBuffers[index];
        EPPZAudioBuffer *eachAudioBuffer = [EPPZAudioBuffer audioBufferFromAudioBufferStruct:eachAudioBufferStruct];
        [mBuffers addObject:eachAudioBuffer];
    }
    self.mBuffers = [NSArray arrayWithArray:mBuffers]; // Immutable
}

-(AudioBufferList)audioBufferListStruct
{    
    AudioBufferList audioBufferList = (AudioBufferList){};
    audioBufferList.mNumberBuffers = self.mNumberBuffers;
    
    // Fill up buffers.
    int index = 0;
    for (EPPZAudioBuffer *eachAudioBuffer in self.mBuffers)
    {
        audioBufferList.mBuffers[index] = [eachAudioBuffer audioBufferStruct];
        index++;
    }
     
    return audioBufferList;
}


#pragma mark - Archiving

-(void)encodeWithCoder:(NSCoder*) encoder
{
    [encoder encodeObject:[NSNumber numberWithUnsignedInt:self.mNumberBuffers] forKey:@"mNumberBuffers"];
    [encoder encodeObject:self.mBuffers forKey:@"mBuffers"];
}

-(id)initWithCoder:(NSCoder*) decoder
{
    self.mNumberBuffers = [[decoder decodeObjectForKey:@"mNumberBuffers"] unsignedIntValue];
    self.mBuffers = [decoder decodeObjectForKey:@"mBuffers"];
    
    return self;
}


@end
