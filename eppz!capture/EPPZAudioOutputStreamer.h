//
//  EPPZAudioOutputStreamer.h
//  eppz!capture
//
//  Created by Carnation on 29/04/14.
//  Copyright (c) 2014 eppz! development, LLC. All rights reserved.
//

#import "TDAudioOutputStreamer.h"
#import <CoreMedia/CoreMedia.h>
#import "EPPZAudioBufferList.h"


@interface EPPZAudioOutputStreamer : TDAudioOutputStreamer


-(void)enqueueSampleBuffer:(CMSampleBufferRef) sampleBuffer;


@end
