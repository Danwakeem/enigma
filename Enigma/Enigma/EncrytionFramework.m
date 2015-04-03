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
	
	newString = [self encrypt:@"\"Hippopotamus!\"" Using:Vigenere withKey:@"lemon" andKey:0];
	NSLog(@"Encrypted %@ to %@", @"\"Hippopotamus!\"", newString);
	
	newString = [self decrypt:newString Using:Vigenere withKey:@"lemon" andKey:0];
	NSLog(@"Decrypted to %@", newString);
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
	} else if (encrytionType == Vigenere) {
		newCString = Vigenere_encrypt((char *)[key1 cStringUsingEncoding:NSASCIIStringEncoding], (char *)CString);
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
	char *newCString = NULL;
	
	BOOL isVigenre = false;
	if (encrytionType == SimpleSub) {
		newCString = SimpleSub_decrypt((char *)[key1 cStringUsingEncoding:NSASCIIStringEncoding], (char *)CString);
	} else if  (encrytionType == Caesar) {
		int caesKey = [key1 intValue];
		newCString = Caesar_decrypt(caesKey, (char *)CString);
	} else if (encrytionType == Affine) {
		int affKeyA = [key1 intValue];
		newCString = Affine_decrypt(affKeyA, key2, (char *)CString);
	} else if (encrytionType == Vigenere) {
		/*
			Ok this one is a bit tricky. We need to split the string into words. Then we need to
			remove any empty strings that may have gotten through. Next we iterate over each word,
			and decrypt it. That word is then turned back into an NSString and appended to
			asiiNSString. This will cause us to lose newlines from the original text but based on how
			we're displaying the decrypted text, I don't see it as much of an issue.
		 
			Reason for this is because text is encrypted on a word by word basis and with the way this
			algorithm works that means we need to do the same thing while decrypting.
		 */
		
		isVigenre = true;
		NSArray *wordsAndEmpties = [asciiNSString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		NSArray *words = [wordsAndEmpties filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
		
		asciiNSString = [NSMutableString string];
		for (NSString *word in words) {
			char *newWord = Vigenere_decrypt((char *)[key1 cStringUsingEncoding:NSASCIIStringEncoding], (char *)[word cStringUsingEncoding:NSASCIIStringEncoding]);
			
			[asciiNSString appendString:[NSString stringWithFormat:@"%@ ", [NSString stringWithCString:newWord encoding:NSASCIIStringEncoding]]];
			
			free(newWord);
		}
	} else {
		newCString = Clear_decrypt((char *)CString);
	}
	
	if (!isVigenre) {
		asciiNSString = [NSMutableString stringWithCString:newCString encoding:NSASCIIStringEncoding];
		free(newCString);
	}
	
	for (int i = 0; i < [message length]; i++) {
		if (buffer[i] > 127) {
			[asciiNSString replaceCharactersInRange:NSMakeRange(i, 1) withString:[NSString stringWithFormat:@"%C", buffer[i]]];
		}
	}
	
	return asciiNSString;
}

+(NSString *) stringFromProfile:(NSManagedObject *)profile {
	NSMutableString *strProf = [NSMutableString string];
	
	[strProf appendString:[NSString stringWithFormat:@"%@,", [profile valueForKey:@"name"]]];
	
	NSSet *encryptions = [profile mutableSetValueForKey:@"encryption"];
	[strProf appendString:[NSString stringWithFormat:@"%lu,", (unsigned long)encryptions.count]];
	
	for (NSManagedObject *e in encryptions) {
		NSString *method = [e valueForKey:@"encryptionType"];
		NSString *key1 = [e valueForKey:@"key1"];
		NSString *key2 = [e valueForKey:@"key2"];
						  
		[strProf appendString:[NSString stringWithFormat:@"%@,%@", method, key1]];
		if (key2 && ![key2 isEqualToString:@""])
			[strProf appendString:[NSString stringWithFormat:@",%@", key2]];
	}
	
	NSLog(@"Profile as string: %@", strProf);
	
	return strProf;
}

@end
