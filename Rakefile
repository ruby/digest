require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test" << "test/lib" << "lib"
  if RUBY_ENGINE == "jruby"
    t.libs << "ext/java/org/jruby/ext/digest/lib"
  else
    t.libs << "ext/digest/lib"
  end
  t.ruby_opts << "-rhelper"
  t.test_files = FileList["test/**/test_*.rb"]
end

if RUBY_ENGINE == "jruby"
  require "rake/javaextensiontask"
  Rake::JavaExtensionTask.new("digest") do |ext|
    ext.source_version = "1.8"
    ext.target_version = "1.8"
    ext.ext_dir = "ext/java"
  end

  task :build => :compile
else
  require "rake/extensiontask"
  Rake::ExtensionTask.new("digest")
  %w[bubblebabble md5 rmd160 sha1 sha2 crc32].each do |ext|
    Rake::ExtensionTask.new("digest/#{ext}")
  end
end

task :check do
  Bundler.with_unbundled_env do
    spec = Gem::Specification::load("digest.gemspec")
    version = spec.version.to_s

    gem = "pkg/digest-#{version}#{"-java" if RUBY_ENGINE == "jruby"}.gem"
    File.size?(gem) or abort "gem not built!"

    require "envutil"

    require 'tmpdir'
    status = Dir.mktmpdir do |tmpdir|
      tmpdir = File.realpath(tmpdir)
      sh "gem", "install", "--install-dir", tmpdir, "--no-document", gem

      _, _, status = EnvUtil.invoke_ruby([{"GEM_HOME"=>tmpdir}], <<~EOS)
      version = #{version.dump}
      gem "digest", version
      loaded_version = Gem.loaded_specs["digest"].version.to_s

      if loaded_version == version
        puts "digest \#{loaded_version} is loaded."
      else
        abort "digest \#{loaded_version} is loaded instead of \#{version}!"
      end

      require "digest"

      name = RUBY_ENGINE == "jruby" ? "/digest.rb" : "/digest.#{RbConfig::CONFIG["DLEXT"]}"
      found = $".select {|path| path.end_with?(name)}
      unless found.size == 1 and found.first.start_with?(#{tmpdir.dump})
        abort "Unexpected digest is loaded: \#{found.inspect}"
      end

      string = "digest"
      actual = Digest::SHA256.hexdigest(string)
      expected = "0bf474896363505e5ea5e5d6ace8ebfb13a760a409b1fb467d428fc716f9f284"
      puts "sha256(\#{string.dump}) = \#{actual.dump}"

      if actual != expected
        abort "no! expected to be \#{expected.dump}!"
      end
      EOS
      status
    end

    if status.success?
      puts "check succeeded!"
    else
      warn "check failed!"
      exit status.exitstatus
    end
  end
end

task :default => :test
