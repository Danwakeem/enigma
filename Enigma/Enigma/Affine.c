//
//  Affine.c
//  Enigma
//
//  Created by Bradley Slayter on 1/31/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

#include "Affine.h"
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

int findInverse(int keyA) {
	for (int i = 0; i < 26; i++) {
		if ((keyA * i) % 26 == 1 % 26)
			return i;
	}
	
	return 0;
}

char *Affine_encrypt(int keyA, int keyB, char *message) {
	char *newMesg = (char *)malloc(strlen(message)+1);
	
	int i;
	for (i = 0; i < strlen(message); i++) {
		if (message[i] != ' ') {
			newMesg[i] = 'a' + ((keyA * (tolower(message[i]) - 'a') + keyB) % 26);
			
			if (isupper(message[i]))
				newMesg[i] = toupper(newMesg[i]);
		} else {
			newMesg[i] = ' ';
		}
	}
	newMesg[i] = '\0';
	
	return newMesg;
}

char *Affine_decrypt(int keyA, int keyB, char *message) {
	char *newMesg = (char *)malloc(strlen(message)+1);
	
	int inverse = findInverse(keyA);
	
	int i;
	for (i = 0; i < strlen(message); i++) {
		if (message[i] != ' ') {
			newMesg[i] = 'a' + ((inverse * ((tolower(message[i]) - 'a') - keyB)) % 26);
			if (((inverse * ((tolower(message[i]) - 'a') - keyB)) % 26) < 0)
				newMesg[i] = '{' + ((inverse * ((tolower(message[i]) - 'a') - keyB)) % 26);
			
			if (isupper(message[i]))
				newMesg[i] = toupper(newMesg[i]);
		} else {
			newMesg[i] = ' ';
		}
	}
	newMesg[i] = '\0';
	
	return newMesg;
}
















