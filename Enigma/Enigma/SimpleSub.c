//
//  SimpleSub.c
//  Enigma
//
//  Created by Bradley Slayter on 1/31/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

#include "SimpleSub.h"
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

int keyContains(char c, char *key) {
	int i;
	for (i = 0; i < strlen(key); i++) {
		if (key[i] == c)
			return 1;
	}
	
	return 0;
}

void createKey(char *key, char *buffer) {
	int i = 0, j = 0;
	while (key[i]) {
		// if the next char is a duplicate or it is already in the key, skip it
		if ((key[i+1] && key[i+1] == key[i]) || keyContains(key[i], buffer)) {
			i++;
			continue;
		}
		
		buffer[j] = key[i];
		i++;
		j++;
	}
	buffer[j] = '\0';  // Null terminate for couting purposes
	buffer[26] = '\0';
	
	for (i = (int)strlen(buffer); i < 26; i++) {
		char nextChar;
		
		// Try the remaining letters in the alphabet and make sure it is not
		// already in the key
		for (j = 0; j < 26; j++) {
			nextChar = 'a' + j;
			
			if (!keyContains(nextChar, buffer)) {
				buffer[i] = nextChar;
				break;
			}
		}
	}
}

char *SimpleSub_encrypt(char *key, char *message) {
	char *newMesg = (char *)malloc(strlen(message)+1);
	
	char newKey[27];
	createKey(key, newKey);
	
	int i;
	for (i = 0; i < strlen(message); i++) {
		if (message[i] != ' ') {
			int keyIdx = tolower(message[i]) - 'a';
			newMesg[i] = newKey[keyIdx];
			
			if (isupper(message[i]))
				newMesg[i] = toupper(newMesg[i]);
		} else {
			newMesg[i] = ' ';
		}
	}
	newMesg[i] = '\0';
	
	return newMesg;
}

// Get the index of a char from a key
int indexForKey(char c, char *key) {
	int i;
	for (i = 0; i < 26; i++) {
		if (key[i] == c)
			return i;
	}
	
	return 0;
}

char *SimpleSub_decrypt(char *key, char *message) {
	char *newMesg = (char *)malloc(strlen(message)+1);
	
	char newKey[27];
	createKey(key, newKey);
	
	int i;
	for (i = 0; i < strlen(message); i++) {
		if (message[i] != ' ') {
			int keyIdx = indexForKey(tolower(message[i]), newKey);
			newMesg[i] = 'a' + keyIdx;
			
			if (isupper(message[i]))
				newMesg[i] = toupper(newMesg[i]);
		} else {
			newMesg[i] = ' ';
		}
	}
	newMesg[i] = '\0';
	
	return newMesg;
}














