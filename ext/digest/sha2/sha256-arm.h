/* sha256-arm.h - prototype for the ARMv8 Crypto Extensions backend in sha256-arm.c */
#ifndef RB_DIGEST_SHA256_ARM_H
#define RB_DIGEST_SHA256_ARM_H

#include <stdint.h>

void sha256_process_arm(uint32_t state[8], const uint8_t data[], uint32_t length);

#endif /* RB_DIGEST_SHA256_ARM_H */
