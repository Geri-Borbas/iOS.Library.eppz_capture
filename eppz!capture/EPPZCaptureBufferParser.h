//
//  EPPZCaptureBufferParser.h
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
#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>
#import "EPPZAudioStreamPlayer.h"


@interface EPPZCaptureBufferParser : NSObject


/*!
 
 Create a UIImage from a CoreMedia video sample (probably spit out by an `AVCaptureSession`).
 
 @param sampleBuffer
 The CoreMedia video sample buffer that the famous
 `captureOutput:didOutputSampleBuffer:fromConnection:` method gives you (either by
 `AVCaptureVideoDataOutputSampleBufferDelegate` or `AVCaptureAudioDataOutputSampleBufferDelegate`).
 
*/
-(UIImage*)imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer;


/*!
 
 Plays a CoreMedia audi sample buffer (probably spit out by an `AVCaptureSession`).
 
 @param sampleBuffer
 The CoreMedia audio sample buffer that the famous
 `captureOutput:didOutputSampleBuffer:fromConnection:` method gives you (either by
 `AVCaptureVideoDataOutputSampleBufferDelegate` or `AVCaptureAudioDataOutputSampleBufferDelegate`).
 
 */
-(void)playSoundFromSampleBuffer:(CMSampleBufferRef) sampleBuffer;
-(void)stopAudioBufferPlayerIfAny;

#pragma mark - Audio accessors


-(AudioStreamBasicDescription)audioFormatOfSampleBuffer:(CMSampleBufferRef) sampleBuffer;
// -(AudioBufferList)audioBufferListFromSampleBuffer:(CMSampleBufferRef) sampleBuffer;



@end
