# frozen_string_literal: false
#
# Runs Digest::SHA1 and Digest::SHA256 against NIST's official SHAVS test
# vectors (see test/fixtures/nist/README.md). These go through the public
# Digest API, so they validate whichever backend the extension was actually
# built with rather than any one of them in particular.

require 'test/unit'

require 'digest'
%w[digest/sha1 digest/sha2].each do |lib|
  begin
    require lib
  rescue LoadError
  end
end

module TestNISTVectors
  FIXTURE_DIR = File.expand_path("../fixtures/nist", __dir__)

  # Parses a byte-oriented SHAVS ShortMsg/LongMsg .rsp file into an array
  # of [message_bytes, expected_hex_digest] pairs.
  def self.parse_rsp(filename)
    vectors = []
    len = nil
    msg_hex = nil

    File.foreach(File.join(FIXTURE_DIR, filename)) do |line|
      case line
      when /\ALen\s*=\s*(\d+)/
        len = $1.to_i
      when /\AMsg\s*=\s*([0-9a-fA-F]*)/
        msg_hex = $1
      when /\AMD\s*=\s*([0-9a-fA-F]+)/
        # Len is in bits but always a multiple of 8 in these byte-oriented
        # files; Msg is padded to a whole byte even when Len is 0.
        message = [msg_hex].pack("H*")[0, len / 8]
        vectors << [message, $1]
      end
    end

    vectors
  end

  module Suite
    def test_vectors
      self.class::VECTORS.each do |message, expected|
        assert_equal(expected, self.class::ALGO.hexdigest(message),
                     "message length #{message.bytesize} bytes")
      end
    end
  end

  class TestSHA1ShortMsg < Test::Unit::TestCase
    include Suite
    ALGO = Digest::SHA1
    VECTORS = TestNISTVectors.parse_rsp("SHA1ShortMsg.rsp")
  end if defined?(Digest::SHA1)

  class TestSHA1LongMsg < Test::Unit::TestCase
    include Suite
    ALGO = Digest::SHA1
    VECTORS = TestNISTVectors.parse_rsp("SHA1LongMsg.rsp")
  end if defined?(Digest::SHA1)

  class TestSHA256ShortMsg < Test::Unit::TestCase
    include Suite
    ALGO = Digest::SHA256
    VECTORS = TestNISTVectors.parse_rsp("SHA256ShortMsg.rsp")
  end if defined?(Digest::SHA256)

  class TestSHA256LongMsg < Test::Unit::TestCase
    include Suite
    ALGO = Digest::SHA256
    VECTORS = TestNISTVectors.parse_rsp("SHA256LongMsg.rsp")
  end if defined?(Digest::SHA256)
end
