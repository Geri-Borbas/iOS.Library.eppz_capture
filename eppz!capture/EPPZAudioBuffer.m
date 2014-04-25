//
//  EPPZAudioBuffer.m
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

#import "EPPZAudioBuffer.h"


@interface EPPZAudioBuffer ()


@property (nonatomic) UInt32 mNumberChannels; // The number of interleaved channels in the buffer.
@property (nonatomic) UInt32 mDataByteSize; // The number of bytes in the buffer pointed at by mData.
@property (nonatomic, strong) NSData *mData; // A pointer to the buffer of audio data.


@end


@implementation EPPZAudioBuffer


#pragma mark - Creation

+(instancetype)audioBufferFromAudioBufferStruct:(AudioBuffer) audioBuffer
{
    EPPZAudioBuffer *instance = [self new];
    [instance representAudioBufferStruct:audioBuffer];
    return instance;
}

-(void)representAudioBufferStruct:(AudioBuffer) audioBuffer
{
    self.mNumberChannels = audioBuffer.mNumberChannels;
    self.mDataByteSize = audioBuffer.mDataByteSize;
    self.mData = [NSData dataWithBytes:audioBuffer.mData length:(NSUInteger)audioBuffer.mDataByteSize];
}

-(AudioBuffer)audioBufferStruct
{
    AudioBuffer audioBuffer = (AudioBuffer){};
    audioBuffer.mNumberChannels = self.mNumberChannels;
    audioBuffer.mDataByteSize = self.mDataByteSize;
    audioBuffer.mData = (void*)self.mData.bytes;
    
    return audioBuffer;
}


#pragma mark - Archiving

-(void)encodeWithCoder:(NSCoder*) encoder
{
    [encoder encodeObject:[NSNumber numberWithUnsignedInt:self.mNumberChannels] forKey:@"mNumberChannels"];
    [encoder encodeObject:[NSNumber numberWithUnsignedInt:self.mDataByteSize] forKey:@"mDataByteSize"];
    [encoder encodeObject:self.mData forKey:@"mData"];
}

-(id)initWithCoder:(NSCoder*) decoder
{
    self.mNumberChannels = [[decoder decodeObjectForKey:@"mNumberChannels"] unsignedIntValue];
    self.mDataByteSize = [[decoder decodeObjectForKey:@"mDataByteSize"] unsignedIntValue];
    self.mData = [decoder decodeObjectForKey:@"mData"];
    
    return self;
}


@end
