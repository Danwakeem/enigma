//
//  Clear.c
//  Enigma
//
//  Created by Bradley Slayter on 2/12/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

#include "Clear.h"
#include <string.h>
#include <stdlib.h>

char *Clear_encrypt(char *message) {
	char *newMesg = (char *)malloc(strlen(message));
	
	strcpy(newMesg, message);
	
	return newMesg;
}

char *Clear_decrypt(char *message) {
	char *newMesg = (char *)malloc(strlen(message));
	
	strcpy(newMesg, message);
	
	return newMesg;
}