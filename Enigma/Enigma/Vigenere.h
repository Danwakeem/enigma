//
//  Vigenere.h
//  Enigma
//
//  Created by Bradley Slayter on 3/2/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

#ifndef __Enigma__Vigenere__
#define __Enigma__Vigenere__

#include <stdio.h>

char *Vigenere_encrypt(char *key, char *message);
char *Vigenere_decrypt(char *key, char *message);

#endif /* defined(__Enigma__Vigenere__) */
