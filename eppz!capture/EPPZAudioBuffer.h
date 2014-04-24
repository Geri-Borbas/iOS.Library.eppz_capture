//
//  EPPZAudioBuffer.h
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

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>


/*!
 
 struct AudioBuffer // A structure to hold a buffer of audio data.
 {
    UInt32  mNumberChannels; // The number of interleaved channels in the buffer.
    UInt32  mDataByteSize; // The number of bytes in the buffer pointed at by mData.
    void*   mData; // A pointer to the buffer of audio data.
 };
 
*/


@interface EPPZAudioBuffer : NSObject

    <NSCoding>


@property (nonatomic) UInt32 mNumberChannels;
@property (nonatomic) UInt32 mDataByteSize;
@property (nonatomic, strong) NSData *mData;

+(instancetype)audioBufferFromAudioBufferStruct:(AudioBuffer) audioBuffer;
-(AudioBuffer)audioBufferStruct;


@end
