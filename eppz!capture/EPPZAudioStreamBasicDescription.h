//
//  EPPZAudioStreamBasicDescription.h
//  eppz!capture
//
//  Created by Carnation on 25/04/14.
//  Copyright (c) 2014 eppz! development, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>


@interface EPPZAudioStreamBasicDescription : NSObject

    <NSCoding>

+(instancetype)audioStreamBasicDescriptionFromAudioStreamBasicDescriptionStruct:(AudioStreamBasicDescription) audioStreamBasicDescription;
-(AudioStreamBasicDescription)audioStreamBasicDescriptionStruct;

@end
