//
//  crash.c
//  Picasso
//
//  Created by Hariz Shirazi on 2023-08-22.
//

#include "crash.h"

#include <stdio.h>

void crashProgram(void) {
    char *crash = (char *)0x00000000;
    printf(*crash);
}
