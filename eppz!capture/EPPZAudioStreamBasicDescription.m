//
//  EPPZAudioStreamBasicDescription.m
//  eppz!capture
//
//  Created by Carnation on 25/04/14.
//  Copyright (c) 2014 eppz! development, LLC. All rights reserved.
//

#import "EPPZAudioStreamBasicDescription.h"


@interface EPPZAudioStreamBasicDescription ()


@property (nonatomic) Float64 mSampleRate;
@property (nonatomic) UInt32  mFormatID;
@property (nonatomic) UInt32  mFormatFlags;
@property (nonatomic) UInt32  mBytesPerPacket;
@property (nonatomic) UInt32  mFramesPerPacket;
@property (nonatomic) UInt32  mBytesPerFrame;
@property (nonatomic) UInt32  mChannelsPerFrame;
@property (nonatomic) UInt32  mBitsPerChannel;
@property (nonatomic) UInt32  mReserved;


@end


@implementation EPPZAudioStreamBasicDescription


#pragma mark - Creation

+(instancetype)audioStreamBasicDescriptionFromAudioStreamBasicDescriptionStruct:(AudioStreamBasicDescription) audioStreamBasicDescription
{
    EPPZAudioStreamBasicDescription *instance = [self new];
    [instance representAudioStreamBasicDescriptionStruct:audioStreamBasicDescription];
    return instance;
}

-(void)representAudioStreamBasicDescriptionStruct:(AudioStreamBasicDescription) audioStreamBasicDescription
{
    self.mSampleRate = audioStreamBasicDescription.mSampleRate;
    self.mFormatID = audioStreamBasicDescription.mFormatID;
    self.mFormatFlags = audioStreamBasicDescription.mFormatFlags;
    self.mBytesPerPacket = audioStreamBasicDescription.mBytesPerPacket;
    self.mFramesPerPacket = audioStreamBasicDescription.mFramesPerPacket;
    self.mBytesPerFrame = audioStreamBasicDescription.mBytesPerFrame;
    self.mChannelsPerFrame = audioStreamBasicDescription.mChannelsPerFrame;
    self.mBitsPerChannel = audioStreamBasicDescription.mBitsPerChannel;
    self.mReserved = audioStreamBasicDescription.mReserved;
}

-(AudioStreamBasicDescription)audioStreamBasicDescriptionStruct
{
    AudioStreamBasicDescription audioStreamBasicDescription = (AudioStreamBasicDescription){};
    
    audioStreamBasicDescription.mSampleRate = self.mSampleRate;
    audioStreamBasicDescription.mFormatID = self.mFormatID;
    audioStreamBasicDescription.mFormatFlags = self.mFormatFlags;
    audioStreamBasicDescription.mBytesPerPacket = self.mBytesPerPacket;
    audioStreamBasicDescription.mFramesPerPacket = self.mFramesPerPacket;
    audioStreamBasicDescription.mBytesPerFrame = self.mBytesPerFrame;
    audioStreamBasicDescription.mChannelsPerFrame = self.mChannelsPerFrame;
    audioStreamBasicDescription.mBitsPerChannel = self.mBitsPerChannel;
    audioStreamBasicDescription.mReserved = self.mReserved;
    
    return audioStreamBasicDescription;
}


#pragma mark - Archiving

-(void)encodeWithCoder:(NSCoder*) encoder
{
    [encoder encodeDouble:self.mSampleRate forKey:@"mSampleRate"];
    [encoder encodeObject:[NSNumber numberWithUnsignedInt:self.mFormatID] forKey:@"mFormatID"];
    [encoder encodeObject:[NSNumber numberWithUnsignedInt:self.mFormatFlags] forKey:@"mFormatFlags"];
    [encoder encodeObject:[NSNumber numberWithUnsignedInt:self.mBytesPerPacket] forKey:@"mBytesPerPacket"];
    [encoder encodeObject:[NSNumber numberWithUnsignedInt:self.mFramesPerPacket] forKey:@"mFramesPerPacket"];
    [encoder encodeObject:[NSNumber numberWithUnsignedInt:self.mBytesPerFrame] forKey:@"mBytesPerFrame"];
    [encoder encodeObject:[NSNumber numberWithUnsignedInt:self.mChannelsPerFrame] forKey:@"mChannelsPerFrame"];
    [encoder encodeObject:[NSNumber numberWithUnsignedInt:self.mBitsPerChannel] forKey:@"mBitsPerChannel"];
    [encoder encodeObject:[NSNumber numberWithUnsignedInt:self.mReserved] forKey:@"mReserved"];
}

-(id)initWithCoder:(NSCoder*) decoder
{
    self.mSampleRate = [decoder decodeDoubleForKey:@"mSampleRate"];
    self.mFormatID = [[decoder decodeObjectForKey:@"mFormatID"] unsignedIntValue];
    self.mFormatFlags = [[decoder decodeObjectForKey:@"mFormatFlags"] unsignedIntValue];
    self.mBytesPerPacket = [[decoder decodeObjectForKey:@"mBytesPerPacket"] unsignedIntValue];
    self.mFramesPerPacket = [[decoder decodeObjectForKey:@"mFramesPerPacket"] unsignedIntValue];
    self.mBytesPerFrame = [[decoder decodeObjectForKey:@"mBytesPerFrame"] unsignedIntValue];
    self.mChannelsPerFrame = [[decoder decodeObjectForKey:@"mChannelsPerFrame"] unsignedIntValue];
    self.mBitsPerChannel = [[decoder decodeObjectForKey:@"mBitsPerChannel"] unsignedIntValue];
    self.mReserved = [[decoder decodeObjectForKey:@"mReserved"] unsignedIntValue];
    
    return self;
}


@end
