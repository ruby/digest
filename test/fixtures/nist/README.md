# NIST SHAVS test vectors

`SHA1ShortMsg.rsp`, `SHA1LongMsg.rsp`, `SHA256ShortMsg.rsp`, and
`SHA256LongMsg.rsp` are the byte-oriented response files from NIST's
Secure Hash Algorithm Validation System (SHAVS), unmodified:

<https://csrc.nist.gov/CSRC/media/Projects/Cryptographic-Algorithm-Validation-Program/documents/shs/shabytetestvectors.zip>

ShortMsg covers every message length from 0 to 512 bits in 8-bit
increments (straddling the 64-byte block boundary for both algorithms);
LongMsg covers messages from ~1024 bits up to 51200 bits (6400 bytes,
100 blocks), exercising multi-block chaining. See
`test/digest/test_nist_vectors.rb`.

As a work of the U.S. federal government, this data is in the public
domain (17 U.S.C. § 105).
