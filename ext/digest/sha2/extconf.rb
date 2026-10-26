# -*- coding: us-ascii -*-
# frozen_string_literal: false
# $RoughId: extconf.rb,v 1.4 2001/08/14 19:54:51 knu Exp $
# $Id$

require "mkmf"
require File.expand_path("../../digest_conf", __FILE__)

$objs = [ "sha2init.#{$OBJEXT}" ]

bundled = !digest_conf("sha2")
if bundled
  have_type("u_int8_t")
end

have_header("sys/cdefs.h")

# On aarch64/arm64, build the ARMv8 Crypto Extensions backend and let
# SHA256_Transform() pick it at runtime when the CPU actually has the extension.
# 
# $CFLAGS can't carry the extra instruction-set flag for just this one file, 
# so give it its own compile rule below when one is needed. This only applies
# when CommonCrypto is not available.
arm_cflags = {}
if bundled && with_config("arm-crypto", true)
  case flag = arm_crypto_flag("sha256-arm.c")
  when false
    # Not aarch64/arm64, or the toolchain can't build the intrinsics: fall
    # back to the portable C implementation only.
  else
    $objs << "sha256-arm.#{$OBJEXT}"
    $defs << "-DHAVE_ARM_CRYPTO_EXT"
    arm_cflags["sha256-arm"] = flag if flag
  end
end

$preload = %w[digest]

create_makefile("digest/sha2")

unless arm_cflags.empty?
  File.open("Makefile", "a") do |mf|
    mf.puts
    mf.puts "# Per-file instruction-set flags for the ARMv8 Crypto Extensions backend."
    arm_cflags.each do |obj, cflag|
      target = "#{obj}.#{$OBJEXT}"
      mf.puts "#{target}: $(srcdir)/#{obj}.c"
      mf.puts "\t$(ECHO) compiling #{obj}.c"
      mf.puts "\t$(Q) $(CC) $(INCFLAGS) $(CPPFLAGS) $(CFLAGS) #{cflag} $(COUTFLAG)$@ -c $(CSRCFLAG)$(srcdir)/#{obj}.c"
    end
  end
end
