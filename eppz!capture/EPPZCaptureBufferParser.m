//
//  EPPZCaptureBufferParser.m
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

#import "EPPZCaptureBufferParser.h"


@interface EPPZCaptureBufferParser ()
@property (nonatomic, strong) EPPZAudioStreamPlayer *audioBufferPlayer;
@end


@implementation EPPZCaptureBufferParser


#pragma mark - Audio

-(AudioStreamBasicDescription)audioFormatOfSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // Get audio format description.
    CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
    const AudioStreamBasicDescription format = *CMAudioFormatDescriptionGetStreamBasicDescription(formatDescription);
    return format;
}

-(void)playSoundFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // Setup audio queue if not already.
    if (self.audioBufferPlayer == nil)
    {
        // Setup stream player.
        self.audioBufferPlayer = [EPPZAudioStreamPlayer new];
        [self.audioBufferPlayer setupForFormat:[self audioFormatOfSampleBuffer:sampleBuffer]];
        [self.audioBufferPlayer start];
    }
    
    // Get buffer list.
    AudioBufferList audioBufferList;
    CMBlockBufferRef blockBuffer;
    CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(
                                                            sampleBuffer,
                                                            NULL,
                                                            &audioBufferList,
                                                            sizeof(audioBufferList),
                                                            NULL,
                                                            NULL,
                                                            kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment,
                                                            &blockBuffer
                                                            );
    
    // Test only.
    EPPZAudioBufferList *archived = [EPPZAudioBufferList audioBufferListFromAudioBufferListStruct:audioBufferList];
    AudioBufferList reconstructed = [archived audioBufferListStruct];   
    
    // Play.
    [self.audioBufferPlayer submitAudioBufferListForPlay:&reconstructed];
    
    // Release the buffer when done.
    CFRelease(blockBuffer);
}

-(void)stopAudioBufferPlayerIfAny
{
    [self.audioBufferPlayer stop];
    self.audioBufferPlayer = nil;
}


#pragma mark - Video

-(UIImage*)imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data.
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    // Lock the base address of the pixel buffer.
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
	
    // Get the number of bytes per row for the pixel buffer.
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
	
    // Get the number of bytes per row for the pixel buffer.
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    
    // Get the pixel buffer width and height.
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
	
    // Create a device-dependent RGB color space.
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
    // Create a bitmap graphics context with the sample buffer data.
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
												 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    // Create a Quartz image from the pixel data in the bitmap graphics context.
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    
    // Unlock the pixel buffer.
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
	
    // Free up the context and color space.
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
	
    // Create an image object from the Quartz image.
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
	
    // Release the Quartz image.
    CGImageRelease(quartzImage);
	
    return (image);
}


@end
