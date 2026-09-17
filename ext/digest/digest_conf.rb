# frozen_string_literal: false

def digest_conf(name)
  unless with_config("bundled-#{name}")
    case cc = with_config("common-digest", true)
    when true, false
    else
      cc = cc.split(/[\s,]++/).any? {|pat| File.fnmatch?(pat, name)}
    end
    if cc and File.exist?("#$srcdir/#{name}cc.h") and
      have_header("CommonCrypto/CommonDigest.h")
      $defs << "-D#{name.upcase}_USE_COMMONDIGEST"
      $headers << "#{name}cc.h"
      return :commondigest
    end
  end
  $objs << "#{name}.#{$OBJEXT}"
  return
end

# Check whether this compiler on an aarch64/arm64 host can build +source+. Will
# try with no additional cflags and also architecture specific flags when
# compiling +source+.
# 
# Returns the flag that worked (nil if none was needed), or false if no
# candidate compiled or the host isn't aarch64/arm64.
def arm_crypto_flag(source)
  return false unless RbConfig::CONFIG["host_cpu"] =~ /\A(aarch64|arm64)\z/i

  [nil, "-march=armv8-a+crypto"].each do |flag|
    label = "ARMv8 Crypto Extensions intrinsics" + (flag ? " (#{flag})" : "")
    if checking_for(label) { try_compile(%{#include "#{$srcdir}/#{source}"\n}, flag) }
      return flag
    end
  end
  false
end
