//
//  EPPZAudioOutputStreamer.m
//  eppz!capture
//
//  Created by Carnation on 29/04/14.
//  Copyright (c) 2014 eppz! development, LLC. All rights reserved.
//

#import "EPPZAudioOutputStreamer.h"
#import "TDAudioStream.h"


@interface EPPZAudioOutputStreamer ()
@property (nonatomic) BOOL headerSent;
@property (nonatomic, strong) NSMutableArray *audioBufferListObjectQueue;
@end


@implementation EPPZAudioOutputStreamer


-(void)enqueueSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    if ([self.audioStream hasSpaceAvailable])
    {
        // Send infinite length WAV header.
        if (self.headerSent == NO)
        {
            NSData *headerData = [self createWAVHeaderFromSampleBuffer:sampleBuffer];
            UInt32 bytesWritten = [self.audioStream writeData:(uint8_t*)headerData.bytes maxLength:headerData.length];
            NSLog(@"header size: %u written: %u", (unsigned int)headerData.length, (unsigned int)bytesWritten);
            self.headerSent = YES; // Flag.
        }
        
        // Get audio buffer(s).
        CMBlockBufferRef blockBuffer;
        AudioBufferList audioBufferList;
        OSStatus error = CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sampleBuffer,
                                                                                 NULL,
                                                                                 &audioBufferList,
                                                                                 sizeof(AudioBufferList),
                                                                                 NULL,
                                                                                 NULL,
                                                                                 kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment,
                                                                                 &blockBuffer);
        if (error != noErr) return;
        
        // Append audio buffer(s) to WAV.
        for (NSUInteger i = 0; i < audioBufferList.mNumberBuffers; i++)
        {
            AudioBuffer audioBuffer = audioBufferList.mBuffers[i];
            UInt32 bytesWritten;
            
            bytesWritten = [self.audioStream writeData:(uint8_t*)&audioBuffer.mData[0] maxLength:512];
            NSLog(@"buffer size: %u written: %u", (unsigned int)audioBuffer.mDataByteSize, (unsigned int)bytesWritten);

            bytesWritten = [self.audioStream writeData:(uint8_t*)&audioBuffer.mData[512] maxLength:512];
            NSLog(@"buffer size: %u written: %u", (unsigned int)audioBuffer.mDataByteSize, (unsigned int)bytesWritten);

            bytesWritten = [self.audioStream writeData:(uint8_t*)&audioBuffer.mData[512 + 512] maxLength:512];
            NSLog(@"buffer size: %u written: %u", (unsigned int)audioBuffer.mDataByteSize, (unsigned int)bytesWritten);

            bytesWritten = [self.audioStream writeData:(uint8_t*)&audioBuffer.mData[512 + 512 + 512] maxLength:512];
            NSLog(@"buffer size: %u written: %u", (unsigned int)audioBuffer.mDataByteSize, (unsigned int)bytesWritten);
        }
        
        // Release.
        CFRelease(blockBuffer);
    }
}

-(AudioStreamBasicDescription)audioFormatOfSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // Get audio format description.
    CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
    const AudioStreamBasicDescription format = *CMAudioFormatDescriptionGetStreamBasicDescription(formatDescription);
    return format;
}

-(NSData*)createWAVHeaderFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // Checks.
    if (sampleBuffer == NULL || CMSampleBufferGetNumSamples(sampleBuffer) == 0) return nil;
    
    // Get format.
    AudioStreamBasicDescription format = [self audioFormatOfSampleBuffer:sampleBuffer];
    CMItemCount sampleCount = CMSampleBufferGetNumSamples(sampleBuffer);
    size_t sampleSize = (format.mBytesPerPacket * format.mFramesPerPacket * format.mBytesPerFrame * format.mChannelsPerFrame);
    size_t sampleBufferSize = sampleCount * sampleSize;
    
    size_t wavHeaderSize = 44;
    size_t wavSize = NSUIntegerMax; // Infinite.s
    long sampleRate = format.mSampleRate;
    int channels = format.mChannelsPerFrame;
    long byteRate = format.mBitsPerChannel * format.mSampleRate * format.mChannelsPerFrame / 8;
    
    // WAV header.
    Byte *header = (Byte*)malloc(wavHeaderSize);
    header[0] = 'R';  // RIFF/WAVE header
    header[1] = 'I';
    header[2] = 'F';
    header[3] = 'F';
    header[4] = (Byte)(sampleBufferSize & 0xff);
    header[5] = (Byte)((sampleBufferSize >> 8) & 0xff);
    header[6] = (Byte)((sampleBufferSize >> 16) & 0xff);
    header[7] = (Byte)((sampleBufferSize >> 24) & 0xff);
    header[8] = 'W';
    header[9] = 'A';
    header[10] = 'V';
    header[11] = 'E';
    header[12] = 'f';  // 'fmt ' chunk
    header[13] = 'm';
    header[14] = 't';
    header[15] = ' ';
    header[16] = 16;  // 4 bytes: size of 'fmt ' chunk
    header[17] = 0;
    header[18] = 0;
    header[19] = 0;
    header[20] = 1;  // format = 1
    header[21] = 0;
    header[22] = (Byte) channels;
    header[23] = 0;
    header[24] = (Byte) (sampleRate & 0xff);
    header[25] = (Byte) ((sampleRate >> 8) & 0xff);
    header[26] = (Byte) ((sampleRate >> 16) & 0xff);
    header[27] = (Byte) ((sampleRate >> 24) & 0xff);
    header[28] = (Byte) (byteRate & 0xff);
    header[29] = (Byte) ((byteRate >> 8) & 0xff);
    header[30] = (Byte) ((byteRate >> 16) & 0xff);
    header[31] = (Byte) ((byteRate >> 24) & 0xff);
    header[32] = (Byte) (2 * 8 / 8);  // block align
    header[33] = 0;
    header[34] = 16;  // bits per sample
    header[35] = 0;
    header[36] = 'd';
    header[37] = 'a';
    header[38] = 't';
    header[39] = 'a';
    header[40] = (Byte) (wavSize & 0xff);
    header[41] = (Byte) ((wavSize >> 8) & 0xff);
    header[42] = (Byte) ((wavSize >> 16) & 0xff);
    header[43] = (Byte) ((wavSize >> 24) & 0xff);
    
    // Header data.
    return [NSData dataWithBytes:header length:wavHeaderSize];
}

-(void)writeNextAudioBufferList
{
    // Get topmost buffer list.
    EPPZAudioBufferList *audioBufferListObject = (EPPZAudioBufferList*)[self.audioBufferListObjectQueue firstObject];
    
    NSLog(@"audioBufferListObject %@", audioBufferListObject);
    
    // Checks.
    if (audioBufferListObject == nil) return;
    
    NSLog(@"writeNextAudioBufferList %@", audioBufferListObject);
    
    AudioBufferList audioBufferList = [audioBufferListObject audioBufferListStruct];
    
    for (NSUInteger i = 0; i < audioBufferList.mNumberBuffers; i++)
    {
        AudioBuffer audioBuffer = audioBufferList.mBuffers[i];
        [self.audioStream writeData:audioBuffer.mData maxLength:audioBuffer.mDataByteSize];
        NSLog(@"buffer size: %u", (unsigned int)audioBuffer.mDataByteSize);
    }
    
    // Dequeue.
    [self.audioBufferListObjectQueue removeObject:audioBufferListObject];
}

-(void)sendDataChunk
{ }


@end
