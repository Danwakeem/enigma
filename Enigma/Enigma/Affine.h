//
//  Affine.h
//  Enigma
//
//  Created by Bradley Slayter on 1/31/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

#ifndef __Enigma__Affine__
#define __Enigma__Affine__

#include <stdio.h>

char *Affine_encrypt(int keyA, int keyB, char *message);
char *Affine_decrypt(int keyA, int keyB, char *message);

#endif /* defined(__Enigma__Affine__) */
