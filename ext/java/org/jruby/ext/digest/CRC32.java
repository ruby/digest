/*
 **** BEGIN LICENSE BLOCK *****
 * BSD 2-Clause License
 *
 * Copyright (c) 2026, Olle Jonsson
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 ***** END LICENSE BLOCK *****/

package org.jruby.ext.digest;

import java.io.IOException;

import org.jruby.Ruby;
import org.jruby.RubyClass;
import org.jruby.RubyFixnum;
import org.jruby.RubyModule;
import org.jruby.RubyObject;
import org.jruby.RubyString;
import org.jruby.anno.JRubyClass;
import org.jruby.anno.JRubyMethod;
import org.jruby.api.Access;
import org.jruby.runtime.ThreadContext;
import org.jruby.runtime.Visibility;
import org.jruby.runtime.builtin.IRubyObject;
import org.jruby.runtime.load.Library;
import org.jruby.util.ByteList;

public class CRC32 implements Library {

    public void load(final Ruby runtime, boolean wrap) throws IOException {
        runtime.getLoadService().require("digest");
        ThreadContext context = runtime.getCurrentContext();
        RubyModule Digest = Access.getModule(context, "Digest");
        RubyClass Base = Digest.getClass(context, "Base");
        RubyClass crc32 = Digest.defineClassUnder(context, "CRC32", Base, DigestCRC32::new);
        crc32.defineMethods(context, DigestCRC32.class);
    }

    private static final class CloneableCRC32 extends java.util.zip.CRC32 implements Cloneable {
        @Override
        public CloneableCRC32 clone() throws CloneNotSupportedException {
            return (CloneableCRC32) super.clone();
        }
    }

    @JRubyClass(name="Digest::CRC32", parent="Digest::Base")
    public static class DigestCRC32 extends RubyObject {
        private static final long serialVersionUID = -2811470471354871234L;

        private transient CloneableCRC32 crc = new CloneableCRC32();

        public DigestCRC32(Ruby runtime, RubyClass type) {
            super(runtime, type);
        }

        @JRubyMethod(required = 1, visibility = Visibility.PRIVATE)
        @Override
        public IRubyObject initialize_copy(ThreadContext context, IRubyObject obj) {
            if (this == obj) return this;
            DigestCRC32 from = (DigestCRC32) obj;
            this.checkFrozen();
            try {
                this.crc = from.crc.clone();
            } catch (CloneNotSupportedException e) {
                throw getRuntime().newRaiseException(getRuntime().getTypeError(), "Could not initialize copy of Digest::CRC32");
            }
            return this;
        }

        @JRubyMethod(name = {"update", "<<"}, required = 1)
        public IRubyObject update(IRubyObject obj) {
            ByteList bytes = obj.convertToString().getByteList();
            crc.update(bytes.getUnsafeBytes(), bytes.getBegin(), bytes.getRealSize());
            return this;
        }

        @JRubyMethod()
        public IRubyObject finish() {
            long val = crc.getValue();
            crc.reset();
            byte[] digest = new byte[] {
                (byte)(val >>> 24),
                (byte)(val >>> 16),
                (byte)(val >>> 8),
                (byte) val
            };
            return RubyString.newStringNoCopy(getRuntime(), digest);
        }

        @JRubyMethod()
        public IRubyObject reset() {
            crc.reset();
            return this;
        }

        @JRubyMethod()
        public IRubyObject digest_length() {
            return RubyFixnum.newFixnum(getRuntime(), 4);
        }

        @JRubyMethod()
        public IRubyObject block_length() {
            return RubyFixnum.newFixnum(getRuntime(), 8);
        }
    }
}
