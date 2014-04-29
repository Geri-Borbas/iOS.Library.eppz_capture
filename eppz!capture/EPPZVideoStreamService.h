//
//  EPPZVoiceChatService.h
//  eppz!capture
//
//  Created by Carnation on 25/04/14.
//  Copyright (c) 2014 eppz! development, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>

#import "EPPZCapture.h"
#import "EPPZStreamData.h"
#import "TDAudioStreamer.h"


@protocol EPPZVideoStreamServiceDelegate  <NSObject>

/*!
 
 To be feed into a remote `EPPZVideoStreamService` instance
 using `inputData:` method (probably dispatched to another
 device via Multipeer Connectivity or similar).
 
*/
-(void)videoStreamServiceDidOutputData:(NSData*) outputData;

/*! Reaching out for an output stream where audio stream packets can be written. */
-(NSOutputStream*)videoStreamServiceOutputStreamForAudio;

@end


@interface EPPZVideoStreamService : NSObject


@property (nonatomic, weak) UIImageView *videoImageView;
@property (nonatomic, weak) UIImageView *remoteVideoImageView;

+(instancetype)videoStreamServiceWithDelegate:(id<EPPZVideoStreamServiceDelegate>) delegate;
-(void)inputData:(NSData*) data;

-(void)startStreaming;
-(void)stopStreaming;

-(void)startVideoStreaming;
-(void)startAudioStreaming;

-(void)stopVideoStreaming;
-(void)stopAudioStreaming;

-(void)startVideoReceiving;
-(void)startAudioStreamReceiving:(NSInputStream*) inputStream;

-(void)stopVideoReceiving;
-(void)stopAudioReceiving;


@end
