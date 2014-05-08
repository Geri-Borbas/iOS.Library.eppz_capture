//
//  EPPZVideoStreamService.h
//  eppz!capture
//
//  Created by Carnation on 25/04/14.
//  Copyright (c) 2014 eppz! development, LLC. All rights reserved.
//

#import "EPPZVideoStreamService.h"


@interface EPPZVideoStreamService ()


@property (nonatomic, strong) EPPZCapture *capture;
@property (nonatomic, weak) id <EPPZVideoStreamServiceDelegate> delegate;

@property (nonatomic, strong) EPPZAudioOutputStreamer *audioOutputStreamer;
@property (nonatomic, strong) TDAudioInputStreamer *audioInputStreamer;


@end


@implementation EPPZVideoStreamService


+(instancetype)videoStreamServiceWithDelegate:(id<EPPZVideoStreamServiceDelegate>) delegate
{
    EPPZVideoStreamService *instance = [self new];
    instance.delegate = delegate;
    return instance;
}

-(id)init
{
    if (self = [super init])
    { [self setup]; }
    return self;
}

-(void)setup
{
    self.capture = [EPPZCapture captureWithDelegate:self];
    self.capture.cameraPosition = FrontCameraPosition;
}


#pragma mark - Incoming data

-(void)inputData:(NSData*) data
{
    EPPZStreamData *streamData = [EPPZStreamData dataWithInputData:data];
    
    // Video sample.
    if (streamData.type == EPPZStreamVideoSampleDataType)
    {
        UIImage *image = streamData.image;
        dispatch_async(dispatch_get_main_queue(), ^
        { self.remoteVideoImageView.image = image; });
    }
    
    // Having sound data.
    if (streamData.type == EPPZStreamAudioSampleDataType)
    {
        // [self.capture.parser playSoundFromSampleBuffer:audioSampleBuffer];
    }
}


#pragma mark - Outgoing data

-(void)captureDidOutputAudioBuffer:(CMSampleBufferRef) audioSampleBuffer
                         timeStamp:(CMTime) timeStamp
{
    // Send.
    [self.audioOutputStreamer enqueueSampleBuffer:audioSampleBuffer];
}

-(void)captureDidOutputImageBuffer:(CMSampleBufferRef) imageSampleBuffer
                         timeStamp:(CMTime) timeStamp
{
    // Parse.
    UIImage *image = [self.capture.parser imageFromSampleBuffer:imageSampleBuffer];
    
    // Send.
    [self send:[[EPPZStreamData dataWithImage:image
                                    timeStamp:timeStamp] data]];
    
    // Show.
    dispatch_async(dispatch_get_main_queue(), ^
    { self.videoImageView.image = image; });
    
}

-(void)send:(NSData*) data
{ [self.delegate videoStreamServiceDidOutputData:data]; }


#pragma mark - User inputs

-(void)startStreaming
{
    [self startVideoStreaming];
    [self startAudioStreaming];
}

-(void)stopStreaming
{
    [self stopVideoStreaming];
    [self stopAudioStreaming];
}

-(void)startVideoStreaming
{ [self.capture startVideoCapture]; }

-(void)startAudioStreaming
{
    // Ask for a stream to write.
    NSOutputStream *outputStream = [self.delegate videoStreamServiceOutputStreamForAudio];
    
    // Get the track for now.
    // NSURL *audioURL = [[NSBundle mainBundle] URLForResource:@"Street Walkin'" withExtension:@"mp3"];
    
    // Create.
    self.audioOutputStreamer = [[EPPZAudioOutputStreamer alloc] initWithOutputStream:outputStream];
    [self.audioOutputStreamer start];
    
    // Take off capture session.
    [self.capture startAudioCapture];
}

-(void)stopVideoStreaming
{ [self.capture stopVideoCapture]; }

-(void)stopAudioStreaming
{ [self.capture stopAudioCapture]; }

-(void)startVideoReceiving
{ }

-(void)stopVideoReceiving
{ }

-(void)startAudioStreamReceiving:(NSInputStream*) inputStream
{
    if (!self.audioInputStreamer)
    {
        // Create, start.
        self.audioInputStreamer = [[TDAudioInputStreamer alloc] initWithInputStream:inputStream];
        [self.audioInputStreamer start];
    }
}

-(void)stopAudioReceiving
{ }


@end
