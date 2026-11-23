/* arm_crypto.h - runtime detection of the ARMv8 Cryptographic Extension */
#ifndef RB_DIGEST_ARM_CRYPTO_H
#define RB_DIGEST_ARM_CRYPTO_H

#if defined(HAVE_ARM_CRYPTO_EXT)

#if defined(__APPLE__)
# include <sys/sysctl.h>
#elif defined(__linux__) || defined(__ANDROID__)
# include <sys/auxv.h>
/* Not every libc/kernel-header combination defines these (e.g. older
 * <asm/hwcap.h> layouts), so fall back to the values Linux has used for
 * aarch64 since they were introduced. */
# ifndef HWCAP_SHA1
#  define HWCAP_SHA1 (1 << 5)
# endif
# ifndef HWCAP_SHA2
#  define HWCAP_SHA2 (1 << 6)
# endif
#endif

#if defined(__STDC_VERSION__) && __STDC_VERSION__ >= 201112L && \
    defined(__has_include) && __has_include(<stdatomic.h>) && !defined(_MSC_VER)
# include <stdatomic.h>
# define RB_DIGEST_ARM_ATOMIC_INT _Atomic int
#else
# define RB_DIGEST_ARM_ATOMIC_INT int
#endif

#if defined(__APPLE__)
static inline int
rb_digest_arm_sysctl_enabled(const char *name)
{
    int enabled = 0;
    size_t size = sizeof(enabled);
    if (sysctlbyname(name, &enabled, &size, NULL, 0) != 0) return 0;
    return enabled != 0;
}
#endif

static inline int
rb_digest_have_arm_sha1(void)
{
    enum { UNKNOWN = -1, NO = 0, YES = 1 };
    static RB_DIGEST_ARM_ATOMIC_INT cached = UNKNOWN;
    int state = cached;

    if (state == UNKNOWN) {
#if defined(__APPLE__)
        state = rb_digest_arm_sysctl_enabled("hw.optional.arm.FEAT_SHA1") ? YES : NO;
#elif defined(__linux__) || defined(__ANDROID__)
        state = (getauxval(AT_HWCAP) & HWCAP_SHA1) ? YES : NO;
#else
        state = NO;
#endif
        cached = state;
    }
    return state == YES;
}

static inline int
rb_digest_have_arm_sha256(void)
{
    enum { UNKNOWN = -1, NO = 0, YES = 1 };
    static RB_DIGEST_ARM_ATOMIC_INT cached = UNKNOWN;
    int state = cached;

    if (state == UNKNOWN) {
#if defined(__APPLE__)
        state = rb_digest_arm_sysctl_enabled("hw.optional.arm.FEAT_SHA256") ? YES : NO;
#elif defined(__linux__) || defined(__ANDROID__)
        state = (getauxval(AT_HWCAP) & HWCAP_SHA2) ? YES : NO;
#else
        state = NO;
#endif
        cached = state;
    }
    return state == YES;
}

#else /* !HAVE_ARM_CRYPTO_EXT */

static inline int rb_digest_have_arm_sha1(void) { return 0; }
static inline int rb_digest_have_arm_sha256(void) { return 0; }

#endif /* HAVE_ARM_CRYPTO_EXT */

#endif /* RB_DIGEST_ARM_CRYPTO_H */
