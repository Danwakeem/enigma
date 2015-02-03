//
//  SimpleSub.h
//  Enigma
//
//  Created by Bradley Slayter on 1/31/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

#ifndef __Enigma__SimpleSub__
#define __Enigma__SimpleSub__

#include <stdio.h>

char *SimpleSub_encrypt(char *key, char *message);
char *SimpleSub_decrypt(char *key, char *message);

#endif /* defined(__Enigma__SimpleSub__) */
