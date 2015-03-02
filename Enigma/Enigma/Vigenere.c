//
//  Vigenere.c
//  Enigma
//
//  Created by Bradley Slayter on 3/2/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

#include "Vigenere.h"
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <ctype.h>

static char table[27][27];
static bool tableCreated = false;

void createTable() {
	if (tableCreated) return; // Only do this once
	
	for (int i = 0; i < 26; i++) {
		for (int j = 0; j < 26; j++) {
			table[i][j] = 'a' + ((j + i) % 26);
		}
		table[i][26] = '\0';
	}
	
	tableCreated = true;
}

char charForKey(char c, int keyIdx) {
	for (int i = 0; i < 26; i++) {
		if (table[i][keyIdx] == c)
			return 'a' + i;
	}
	
	return 0;
}

char *Vigenere_encrypt(char *key, char *message) {
	createTable();
	
	char *newMesg = (char *)malloc(strlen(message)+1);
	
	int i, j = 0;
	for (i = 0; i < strlen(message); i++) {
		if (tolower(message[i]) >= 'a' && tolower(message[i]) <= 'z') {
			int keyIdx = tolower(key[j]) - 'a';
			int messIdx = tolower(message[i]) - 'a';
			
			newMesg[i] = table[messIdx][keyIdx];
			
			if (isupper(message[i]))
				newMesg[i] = toupper(newMesg[i]);
			
			j++;
			if (!key[j])
				j = 0;
		} else {
			newMesg[i] = message[i];
		}
	}
	newMesg[i] = '\0';
	
	return newMesg;
}

char *Vigenere_decrypt(char *key, char *message) {
	createTable();
	
	char *newMesg = (char *)malloc(strlen(message)+1);
	
	int i, j = 0;
	for (i = 0; i < strlen(message); i++) {
		if (tolower(message[i]) >= 'a' && tolower(message[i]) <= 'z') {
			int keyIdx = tolower(key[j]) - 'a';
			
			newMesg[i] = charForKey(tolower(message[i]), keyIdx);
			
			if (isupper(message[i]))
				newMesg[i] = toupper(newMesg[i]);
			
			j++;
			if (!key[j])
				j = 0;
		} else {
			newMesg[i] = message[i];
		}
	}
	newMesg[i] = '\0';
	
	return newMesg;
}