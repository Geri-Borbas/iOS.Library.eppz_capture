//
//  EPPZCapture.m
//  eppz!kit
//
//  Created by Borbás Geri on 8/5/12.
//  Copyright (c) 2014 eppz! development, LLC.
//
//  follow http://www.twitter.com/_eppz
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "EPPZCapture.h"


@interface EPPZCapture ()


@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, readonly) NSString *selectedSessionPreset;

@property (nonatomic, strong) AVCaptureDevice *videoDevice;
@property (nonatomic, strong) AVCaptureDevice *audioDevice;

@property (nonatomic, readonly) AVCaptureDevice *selectedCameraDevice;
@property (nonatomic, readonly) AVCaptureDevice *rearCameraDevice;
@property (nonatomic, readonly) AVCaptureDevice *frontFacingCameraDevice;

@property (nonatomic, weak) AVCaptureDeviceInput *videoInput;
@property (nonatomic, weak) AVCaptureDeviceInput *audioInput;

@property (nonatomic, weak) AVCaptureVideoDataOutput *videoOutput;
@property (nonatomic, weak) AVCaptureAudioDataOutput *audioOutput;


@end


@implementation EPPZCapture
@synthesize delegate = _delegate;


#pragma mark - Creation

+(instancetype)captureWithDelegate:(id) delegate
{ return [[self alloc] initWithDelegate:delegate]; }

-(id)initWithDelegate:(id) delegate
{
    if (self = [super init])
    {
        self.delegate = delegate;
        [self createSession];
        self.parser = [EPPZCaptureBufferParser new];
    }
    return self;
}

-(void)dealloc
{ [self tearDownSession]; }


#pragma mark - Start session

-(void)createSession
{
    // Create the session.
	self.captureSession = [AVCaptureSession new];
	self.captureSession.sessionPreset = self.selectedSessionPreset;
    
	// Subscribe notifications.
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self selector:@selector(sessionDidStartRunning:) name:AVCaptureSessionDidStartRunningNotification object:self.captureSession];
	[notificationCenter addObserver:self selector:@selector(sessionDidStopRunning:) name:AVCaptureSessionDidStopRunningNotification object:self.captureSession];
	[notificationCenter addObserver:self selector:@selector(sessionDidStartRunning:) name:AVCaptureSessionInterruptionEndedNotification object:self.captureSession];
    
    // Start.
    [self.captureSession startRunning];
}

-(void)tearDownSession
{
    // Stop.
	[self.captureSession stopRunning];
	
    // Unsubscribe notifications.
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter removeObserver:self name:AVCaptureSessionDidStartRunningNotification object:self.captureSession];
	[notificationCenter removeObserver:self name:AVCaptureSessionDidStopRunningNotification object:self.captureSession];
	[notificationCenter removeObserver:self name:AVCaptureSessionInterruptionEndedNotification object:self.captureSession];
}


#pragma mark - Video capture

-(void)startVideoCapture
{
    NSError *error = nil;
	
    // Device.
    self.videoDevice = self.selectedCameraDevice;
	
	// Attempt to turn on auto focus.
	if ([self.videoDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
    {
        if ([self.videoDevice lockForConfiguration:&error])
		{
			self.videoDevice.focusMode = AVCaptureFocusModeContinuousAutoFocus;
			[self.videoDevice unlockForConfiguration];
		}
    }
    
    // Input.
    self.videoInput = [AVCaptureDeviceInput deviceInputWithDevice:self.videoDevice error:&error];
    if (!self.videoInput) { /* May handling error appropriately */ }
    [self.captureSession addInput:self.videoInput];
    
	// Output.
    AVCaptureVideoDataOutput *videoOutput = [AVCaptureVideoDataOutput new];
    self.videoOutput = videoOutput;
    [self.videoOutput setAlwaysDiscardsLateVideoFrames:YES];
    [self.videoOutput setSampleBufferDelegate:self queue:dispatch_queue_create("Video output queue", NULL)];
    self.videoOutput.videoSettings = @{ (id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInt:kCVPixelFormatType_32BGRA] };
    [self.captureSession addOutput:self.videoOutput];
}

-(void)stopVideoCapture
{
    [self.captureSession removeInput:self.videoInput];
    [self.captureSession removeOutput:self.videoOutput];
    self.videoDevice = nil;
}


#pragma mark - Audio capture

-(void)startAudioCapture
{
    NSError *error = nil;
	
    // Device.
    self.audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    
    // Input.
    self.audioInput = [AVCaptureDeviceInput deviceInputWithDevice:self.audioDevice error:&error];
    if (!self.audioInput) { /* May handling error appropriately */ }
    [self.captureSession addInput:self.audioInput];
    
	// Output.
    AVCaptureAudioDataOutput *audioOutput = [AVCaptureAudioDataOutput new];
    self.audioOutput = audioOutput;
    [self.audioOutput setSampleBufferDelegate:self queue:dispatch_queue_create("Audio output queue", NULL)];
    [self.captureSession addOutput:self.audioOutput];
}

-(void)stopAudioCapture
{
    [self.captureSession removeInput:self.audioInput];
    [self.captureSession removeOutput:self.audioOutput];
    self.audioDevice = nil;
    
    [self.parser stopAudioBufferPlayerIfAny];
}


#pragma mark - Camera devices

-(AVCaptureDevice*)selectedCameraDevice
{
    if (self.cameraPosition == FrontCameraPosition)
    {
        // Attempt to get front facing camera device.
        NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        for (AVCaptureDevice *eachDevice in videoDevices)
        {
            if (eachDevice.position == AVCaptureDevicePositionFront)
            { return eachDevice; }
        }
    }
    
    // Rear camera.
    return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
}

-(void)toggleCameraSource
{
    // Only if video is started.
    if (self.videoDevice == nil) return;
    
    // Remove current input.
    [self.captureSession removeInput:self.videoInput];
    
    // Toggle.
    self.cameraPosition = (self.cameraPosition == RearCameraPosition) ? FrontCameraPosition : RearCameraPosition;
    
    // New device.
    self.videoDevice = self.selectedCameraDevice;
    
    // Create, add new input.
    NSError *error = nil;
    self.videoInput = [AVCaptureDeviceInput deviceInputWithDevice:self.videoDevice error:&error];
    [self.captureSession addInput:self.videoInput];
    
    // Delegate hook.
    [self.delegate captureDidSwitchCameraPosition:self.cameraPosition];
}


#pragma mark - Quality

-(NSString*)selectedSessionPreset
{
    if (self.quality == EPPZCaptureQualityLow)
        return AVCaptureSessionPresetLow;
    
    if (self.quality == EPPZCaptureQualityMedium)
        return AVCaptureSessionPresetMedium;
    
    // self.quality == EPPZCaptureQualityHigh
    return AVCaptureSessionPreset640x480;
}

-(void)setQuality:(EPPZCaptureQuality) quality
{
    _quality = quality;
    
    // Apply to session.
    self.captureSession.sessionPreset = self.selectedSessionPreset;
}


#pragma mark - Notifications

-(void)sessionDidStartRunning:(AVCaptureSession*) session
{
    NSLog(@"sessionDidStartRunning:");
}

-(void)sessionDidStopRunning:(AVCaptureSession*) session
{
    NSLog(@"sessionDidStopRunning:");
}


#pragma mark - Sample buffer
    
 -(void)captureOutput:(AVCaptureOutput*) captureOutput
didOutputSampleBuffer:(CMSampleBufferRef) sampleBuffer
       fromConnection:(AVCaptureConnection*) connection
{
    // Get time stamp.
    CMTime timeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);

    if ([captureOutput isKindOfClass:[AVCaptureVideoDataOutput class]])
    { [self.delegate captureDidOutputImageBuffer:sampleBuffer timeStamp:timeStamp]; }
    
    if ([captureOutput isKindOfClass:[AVCaptureAudioDataOutput class]])
    { [self.delegate captureDidOutputAudioBuffer:sampleBuffer timeStamp:timeStamp]; }
}


@end
