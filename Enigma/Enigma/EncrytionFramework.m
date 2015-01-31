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
	const char *CString = [testString cStringUsingEncoding:NSASCIIStringEncoding];
	
	NSLog(@"Testing Caesar encrytion");
	NSLog(@"Using %@", testString);
	char *newMesg = Caesar_encrypt(5, (char *)CString);
	
	NSString *encryptedObj = [NSString stringWithCString:newMesg encoding:NSASCIIStringEncoding];
	NSLog(@"Encrypted Message is: %@", encryptedObj);
	
	char *decryptedMesg = Caesar_decrypt(5, newMesg);
	NSString *decrypObj = [NSString stringWithCString:decryptedMesg encoding:NSASCIIStringEncoding];
	NSLog(@"Decrypted message is: %@", decrypObj);
	
	free(newMesg);
	free(decryptedMesg);
	
	NSLog(@"Testing Affine encrytion");
	NSLog(@"Using %@", testString);
	
	newMesg = Affine_encrypt(17, 3, (char *)CString);
	encryptedObj = [NSString stringWithCString:newMesg encoding:NSASCIIStringEncoding];
	NSLog(@"Encrypted Message is: %@", encryptedObj);
	
	decryptedMesg = Affine_decrypt(17, 3, (char *)newMesg);
	decrypObj = [NSString stringWithCString:decryptedMesg encoding:NSASCIIStringEncoding];
	NSLog(@"Decrypted message is: %@", decrypObj);
	
	free(newMesg);
	free(decryptedMesg);
	
	NSLog(@"Testing Simple Substitution encrytion");
	NSLog(@"Using %@", testString);
	
	newMesg = SimpleSub_encrypt("zyxwvutsrqponmlkjihgfedcba", (char *)CString);
	encryptedObj = [NSString stringWithCString:newMesg encoding:NSASCIIStringEncoding];
	NSLog(@"Encrypted Message is: %@", encryptedObj);
	
	decryptedMesg = SimpleSub_decrypt("zyxwvutsrqponmlkjihgfedcba", (char *)newMesg);
	decrypObj = [NSString stringWithCString:decryptedMesg encoding:NSASCIIStringEncoding];
	NSLog(@"Decrypted message is: %@", decrypObj);
	
	free(newMesg);
	free(decryptedMesg);
}

@end
