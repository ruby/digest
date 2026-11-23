/* sha1-arm.h - prototype for the ARMv8 Crypto Extensions backend in sha1-arm.c */
#ifndef RB_DIGEST_SHA1_ARM_H
#define RB_DIGEST_SHA1_ARM_H

#include <stdint.h>

void sha1_process_arm(uint32_t state[5], const uint8_t data[], uint32_t length);

#endif /* RB_DIGEST_SHA1_ARM_H */
