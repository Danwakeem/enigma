//
//  EncrytionFramework.m
//  Enigma
//
//  Created by Bradley Slayter on 1/31/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

#import "EncrytionFramework.h"

@implementation EncrytionFramework

+(void) test {
	NSString *testString = @"Hello";
	
	NSString *newString = [self encrypt:testString Using:@"SimpleSub" withKey:@"pineapple" andKey:0];
	NSLog(@"Encrypted %@ to %@", testString, newString);
	
	newString = [self decrypt:newString Using:@"SimpleSub" withKey:@"pineapple" andKey:0];
	NSLog(@"Decryted to %@", newString);
	
	newString = [self encrypt:testString Using:@"Caesar" withKey:@"2" andKey:0];
	NSLog(@"Encrypted %@ to %@", testString, newString);
	
	newString = [self decrypt:newString Using:@"Caesar" withKey:@"2" andKey:0];
	NSLog(@"Decryted to %@", newString);
	
	newString = [self encrypt:testString Using:@"Affine" withKey:@"3" andKey:4];
	NSLog(@"Encrypted %@ to %@", testString, newString);
	
	newString = [self decrypt:newString Using:@"Affine" withKey:@"3" andKey:4];
	NSLog(@"Decryted to %@", newString);
}

+(NSString *) encrypt:(NSString *)message Using:(NSString *)encrytionType withKey:(NSString *)key1 andKey:(int)key2 {
	const char *CString = [message cStringUsingEncoding:NSASCIIStringEncoding];
	char *newCString;
	
	if ([encrytionType isEqualToString:@"SimpleSub"]) {
		newCString = SimpleSub_encrypt((char *)[key1 cStringUsingEncoding:NSASCIIStringEncoding], (char *)CString);
	} else if  ([encrytionType isEqualToString:@"Caesar"]) {
		int caesKey = [key1 intValue];
		newCString = Caesar_encrypt(caesKey, (char *)CString);
	} else {
		int affKeyA = [key1 intValue];
		newCString = Affine_encrypt(affKeyA, key2, (char *)CString);
	}
	
	NSString *newMessage = [NSString stringWithCString:newCString encoding:NSASCIIStringEncoding];
	free(newCString);
	
	return newMessage;
}

+(NSString *) decrypt:(NSString *)message Using:(NSString *)encrytionType withKey:(NSString *)key1 andKey:(int)key2 {
	const char *CString = [message cStringUsingEncoding:NSASCIIStringEncoding];
	char *newCString;
	
	if ([encrytionType isEqualToString:@"SimpleSub"]) {
		newCString = SimpleSub_decrypt((char *)[key1 cStringUsingEncoding:NSASCIIStringEncoding], (char *)CString);
	} else if  ([encrytionType isEqualToString:@"Caesar"]) {
		int caesKey = [key1 intValue];
		newCString = Caesar_decrypt(caesKey, (char *)CString);
	} else {
		int affKeyA = [key1 intValue];
		newCString = Affine_decrypt(affKeyA, key2, (char *)CString);
	}
	
	NSString *newMessage = [NSString stringWithCString:newCString encoding:NSASCIIStringEncoding];
	free(newCString);
	
	return newMessage;
}

@end
