//
//  EncrytionFramework.h
//  Enigma
//
//  Created by Bradley Slayter on 1/31/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Ceasar.h"
#import "Affine.h"
#import "SimpleSub.h"

typedef enum {
	SimpleSub,
	Caesar,
	Affine
} EncryptionType;

@interface EncrytionFramework : NSObject

+(void) test;
+(NSString *) encrypt:(NSString *)message Using:(EncryptionType)encrytionType withKey:(NSString *)key1 andKey:(int)key2;
+(NSString *) decrypt:(NSString *)message Using:(EncryptionType)encrytionType withKey:(NSString *)key1 andKey:(int)key2;

@end
