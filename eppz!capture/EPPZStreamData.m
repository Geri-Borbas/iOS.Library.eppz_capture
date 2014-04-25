//
//  EPPZStreamData.m
//  eppz!capture
//
//  Created by Carnation on 25/04/14.
//  Copyright (c) 2014 eppz! development, LLC. All rights reserved.
//

#import "EPPZStreamData.h"


@interface EPPZStreamData ()


@property (nonatomic, strong) NSData *payload;
#warning Pack timestamp as well!


@end


@implementation EPPZStreamData


#pragma mark - Video

+(EPPZStreamData*)dataWithImage:(UIImage*) image
                      timeStamp:(CMTime) timeStamp
{
    EPPZStreamData *instance = [self new];
    instance.payload = UIImageJPEGRepresentation(image, 1.0);
    [instance packWithType:EPPZStreamVideoSampleDataType];
    return instance;
}

-(UIImage*)image
{ return [UIImage imageWithData:self.payload]; }


#warning Implement timestamp only stuff!
+(EPPZStreamData*)dataWithVideoTimeStampValue:(CMTimeValue) timeStampValue
{ return nil; }

-(CMTimeValue)videoTimeStampValue
{ return 0; }


#pragma mark - Audio

+(EPPZStreamData*)dataWithAudioBufferList:(EPPZAudioBufferList*) audioBufferList
                                timeStamp:(CMTime) timeStamp
{
    EPPZStreamData *instance = [self new];
    instance.payload = [NSKeyedArchiver archivedDataWithRootObject:audioBufferList];
    [instance packWithType:EPPZStreamAudioSampleDataType];
    return instance;
}

-(EPPZAudioBufferList*)audioBufferList
{ return [NSKeyedUnarchiver unarchiveObjectWithData:self.payload]; }

+(EPPZStreamData*)dataWithAudioStreamBasicDescription:(EPPZAudioStreamBasicDescription*) audioStreamBasicDescription
{
    EPPZStreamData *instance = [self new];
    instance.payload = [NSKeyedArchiver archivedDataWithRootObject:audioStreamBasicDescription];
    [instance packWithType:EPPZStreamAudioFormatDataType];
    return instance;
}

-(EPPZAudioStreamBasicDescription*)audioStreamBasicDescription
{ return [NSKeyedUnarchiver unarchiveObjectWithData:self.payload]; }


#warning Implement timestamp only stuff!
+(EPPZStreamData*)dataWithAudioTimeStampValue:(CMTimeValue) timeStampValue
{ return nil; }

-(CMTimeValue)audioTimeStampValue
{ return 0; }


#pragma mark - Incoming

-(void)packWithType:(EPPZStreamDataType) type
{
    self.type = type;
    [self pack];
}

+(EPPZStreamData*)dataWithInputData:(NSData*) data
{
    EPPZStreamData *instance = [self new];
    instance.data = data;
    [instance unpack];
    return instance;
}


#pragma mark - Packaging

-(void)pack
{
    // Append header.
    NSMutableData *data = [NSMutableData dataWithCapacity:([self.payload length]+sizeof(uint32_t))];
    uint32_t swappedHeader = CFSwapInt32HostToBig((uint32_t)self.type);
    [data appendBytes:&swappedHeader length:sizeof(uint32_t)];
    [data appendData:self.payload];
    
    // Retain.
    self.data = data;
}

-(void)unpack
{
    EPPZStreamDataType header;
    uint32_t swappedHeader;
    NSData *payload;
    
    // Split packet to header and payload.
    if ([self.data length] >= sizeof(uint32_t))
    {
        [self.data getBytes:&swappedHeader length:sizeof(uint32_t)];
        header = (EPPZStreamDataType)CFSwapInt32BigToHost(swappedHeader);
        NSRange payloadRange = {sizeof(uint32_t), [self.data length]-sizeof(uint32_t)};
        payload = [self.data subdataWithRange:payloadRange];
    }
    
    // Retain.
    self.type = header;
    self.payload = payload;
}


@end
