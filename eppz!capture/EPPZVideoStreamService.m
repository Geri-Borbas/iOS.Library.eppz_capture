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

@property (nonatomic) BOOL audioFormatDelivered;


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
    // Send audio format if needed.
    if (self.audioFormatDelivered == NO)
    {
        AudioStreamBasicDescription audioFormat = [self.capture.parser audioFormatOfSampleBuffer:audioSampleBuffer];
        [self send:[[EPPZStreamData dataWithAudioStreamBasicDescription:
                    [EPPZAudioStreamBasicDescription audioStreamBasicDescriptionFromAudioStreamBasicDescriptionStruct:audioFormat]] data]];
        
        self.audioFormatDelivered = YES;
    }
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
{ [self.capture startAudioCapture]; }

-(void)stopVideoStreaming
{ [self.capture stopVideoCapture]; }

-(void)stopAudioStreaming
{ [self.capture stopAudioCapture]; }

-(void)startVideoReceiving
{ }

-(void)stopVideoReceiving
{ }

-(void)startAudioReceiving
{ }

-(void)stopAudioReceiving
{ }


@end
