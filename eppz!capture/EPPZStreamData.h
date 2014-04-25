//
//  EPPZStreamData.h
//  eppz!capture
//
//  Created by Carnation on 25/04/14.
//  Copyright (c) 2014 eppz! development, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>

#import "EPPZAudioBufferList.h"
#import "EPPZAudioStreamBasicDescription.h"


typedef enum
{
    
    EPPZStreamVideoSampleDataType,              // 0
    EPPZStreamAudioSampleDataType,              // 1

    EPPZStreamAudioFormatDataType,              // 2
    EPPZStreamAudioFormatReceivedDataType,      // 3
    
    EPPZStreamVideoTimeStampValueDataType,      // 4
    EPPZStreamAudioTimeStampValueDataType,      // 5
    
    
} EPPZStreamDataType;


@interface EPPZStreamData : NSObject


@property (nonatomic) EPPZStreamDataType type;


#pragma mark - Video

+(EPPZStreamData*)dataWithImage:(UIImage*) image timeStamp:(CMTime) timeStamp;
@property (nonatomic, readonly) UIImage *image;

+(EPPZStreamData*)dataWithVideoTimeStampValue:(CMTimeValue) timeStampValue;
@property (nonatomic, readonly) CMTimeValue videoTimeStampValue;


#pragma mark - Audio

+(EPPZStreamData*)dataWithAudioBufferList:(EPPZAudioBufferList*) audioBufferList timeStamp:(CMTime) timeStamp;
@property (nonatomic, readonly) EPPZAudioBufferList *audioBufferList;

+(EPPZStreamData*)dataWithAudioStreamBasicDescription:(EPPZAudioStreamBasicDescription*) audioStreamBasicDescription;
@property (nonatomic, readonly) EPPZAudioStreamBasicDescription *audioStreamBasicDescription;

+(EPPZStreamData*)dataWithAudioTimeStampValue:(CMTimeValue) timeStampValue;
@property (nonatomic, readonly) CMTimeValue audioTimeStampValue;


#pragma mark - Incoming

+(EPPZStreamData*)dataWithInputData:(NSData*) data;
@property (nonatomic, strong) NSData *data;


@end
