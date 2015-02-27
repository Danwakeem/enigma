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
	NSString *testString = @"\"Hello!\"";
	
	NSString *newString = [self encrypt:testString Using:SimpleSub withKey:@"pineapple" andKey:0];
	NSLog(@"Encrypted %@ to %@", testString, newString);
	
	newString = [self decrypt:newString Using:SimpleSub withKey:@"pineapple" andKey:0];
	NSLog(@"Decryted to %@", newString);
	
	newString = [self encrypt:testString Using:Caesar withKey:@"2" andKey:0];
	NSLog(@"Encrypted %@ to %@", testString, newString);
	
	newString = [self decrypt:newString Using:Caesar withKey:@"2" andKey:0];
	NSLog(@"Decryted to %@", newString);
	
	newString = [self encrypt:testString Using:Affine withKey:@"3" andKey:4];
	NSLog(@"Encrypted %@ to %@", testString, newString);
	
	newString = [self decrypt:newString Using:Affine withKey:@"3" andKey:4];
	NSLog(@"Decryted to %@", newString);
	
	newString = [self encrypt:testString Using:Clear withKey:@"" andKey:0];
	NSLog(@"Encrypted %@ to %@", testString, newString);
	
	newString = [self decrypt:newString Using:Clear withKey:@"" andKey:0];
	NSLog(@"Decryted to %@", newString);
}

+(NSString*) removeEmojiFromString:(NSString *)string {
	__block NSMutableString* temp = [NSMutableString string];
	
	[string enumerateSubstringsInRange: NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
	 ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop){
		 
		 const unichar hs = [substring characterAtIndex: 0];
		 
		 // surrogate pair
		 if (0xd800 <= hs && hs <= 0xdbff) {
			 const unichar ls = [substring characterAtIndex: 1];
			 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
			 
			 [temp appendString: (0x1d000 <= uc && uc <= 0x1f77f)? @"?": substring]; // U+1D000-1F77F
			 
			 // non surrogate
		 } else {
			 [temp appendString: (0x2100 <= hs && hs <= 0x26ff)? @"?": substring]; // U+2100-26FF
		 }
	 }];
	
	return temp;
}

+(NSString *) encrypt:(NSString *)message Using:(EncryptionType)encrytionType withKey:(NSString *)key1 andKey:(int)key2 {
	
	unichar buffer[[message length]+1];
	[message getCharacters:buffer range:NSMakeRange(0, [message length])];
	
	NSMutableString *asciiNSString = [NSMutableString string];
	for (int i = 0; i < [message length]; i++) {
		if (buffer[i] > 127) {
			[asciiNSString appendString:@"?"];
		} else {
			[asciiNSString appendString:[NSString stringWithFormat:@"%C", buffer[i]]];
		}
	}
	
	const char *CString = [asciiNSString cStringUsingEncoding:NSASCIIStringEncoding];
	char *newCString;
	
	if (encrytionType == SimpleSub) {
		newCString = SimpleSub_encrypt((char *)[key1 cStringUsingEncoding:NSASCIIStringEncoding], (char *)CString);
	} else if  (encrytionType == Caesar) {
		int caesKey = [key1 intValue];
		newCString = Caesar_encrypt(caesKey, (char *)CString);
	} else if (encrytionType == Affine) {
		int affKeyA = [key1 intValue];
		newCString = Affine_encrypt(affKeyA, key2, (char *)CString);
	} else {
		newCString = Clear_decrypt((char *)CString);
	}
	
	asciiNSString = [NSMutableString stringWithCString:newCString encoding:NSASCIIStringEncoding];
	free(newCString);
	
	for (int i = 0; i < [message length]; i++) {
		if (buffer[i] > 127) {
			[asciiNSString replaceCharactersInRange:NSMakeRange(i, 1) withString:[NSString stringWithFormat:@"%C", buffer[i]]];
		}
	}
	
	return asciiNSString;
}

+(NSString *) decrypt:(NSString *)message Using:(EncryptionType)encrytionType withKey:(NSString *)key1 andKey:(int)key2 {
	
	unichar buffer[[message length]+1];
	[message getCharacters:buffer range:NSMakeRange(0, [message length])];
	
	NSMutableString *asciiNSString = [NSMutableString string];
	for (int i = 0; i < [message length]; i++) {
		if (buffer[i] > 127) {
			[asciiNSString appendString:@"?"];
		} else {
			[asciiNSString appendString:[NSString stringWithFormat:@"%C", buffer[i]]];
		}
	}
	
	const char *CString = [asciiNSString cStringUsingEncoding:NSASCIIStringEncoding];
	char *newCString;
	
	if (encrytionType == SimpleSub) {
		newCString = SimpleSub_decrypt((char *)[key1 cStringUsingEncoding:NSASCIIStringEncoding], (char *)CString);
	} else if  (encrytionType == Caesar) {
		int caesKey = [key1 intValue];
		newCString = Caesar_decrypt(caesKey, (char *)CString);
	} else if (encrytionType == Affine) {
		int affKeyA = [key1 intValue];
		newCString = Affine_decrypt(affKeyA, key2, (char *)CString);
	} else {
		newCString = Clear_decrypt((char *)CString);
	}
	
	asciiNSString = [NSMutableString stringWithCString:newCString encoding:NSASCIIStringEncoding];
	free(newCString);
	
	for (int i = 0; i < [message length]; i++) {
		if (buffer[i] > 127) {
			[asciiNSString replaceCharactersInRange:NSMakeRange(i, 1) withString:[NSString stringWithFormat:@"%C", buffer[i]]];
		}
	}
	
	return asciiNSString;
}

@end
