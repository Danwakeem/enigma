//
//  Ceasar.c
//  Enigma
//
//  Created by Bradley Slayter on 1/31/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

#include "Ceasar.h"
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

char *Caesar_encrypt(int key, char *message) {
	char *newMesg = (char *)malloc(strlen(message)+1);
	
	int i;
	for (i = 0; i < strlen(message); i++) {
		if (message[i] != ' ') {
			newMesg[i] = 'a' + (((tolower(message[i]) - 'a') + key) % 26);
			if ((((tolower(message[i]) - 'a') + key) % 26) < 0)
				newMesg[i] = '{' + (((tolower(message[i]) - 'a') + key) % 26);

			if (isupper(message[i]))
				newMesg[i] = toupper(newMesg[i]);
		} else {
			newMesg[i] = ' ';
		}
	}
	newMesg[i] = '\0';
	
	return newMesg;
}

char *Caesar_decrypt(int key, char *message) {
	char *newMesg = (char *)malloc(strlen(message)+1);
	
	int i;
	for (i = 0; i < strlen(message); i++) {
		if (message[i] != ' ') {
			newMesg[i] = 'a' + (((tolower(message[i]) - 'a') - key) % 26);
			if ((((tolower(message[i]) - 'a') - key) % 26) < 0)
				newMesg[i] = '{' + (((tolower(message[i]) - 'a') - key) % 26);
			
			if (isupper(message[i]))
				newMesg[i] = toupper(newMesg[i]);
		} else {
			newMesg[i] = ' ';
		}
	}
	newMesg[i] = '\0';
	
	return newMesg;
}














