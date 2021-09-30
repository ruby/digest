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
else
  require "rake/extensiontask"
  Rake::ExtensionTask.new("digest")
  %w[bubblebabble md5 rmd160 sha1 sha2].each do |ext|
    Rake::ExtensionTask.new("digest/#{ext}")
  end
end

task :sync_tool do
  cp "../ruby/tool/lib/core_assertions.rb", "./test/lib"
  cp "../ruby/tool/lib/envutil.rb", "./test/lib"
  cp "../ruby/tool/lib/find_executable.rb", "./test/lib"
end

task :check do
  if ENV.key?("BUNDLER_VERSION")
    abort "run me without bundle exec."
  end

  spec = Gem::Specification::load("digest.gemspec")
  version = spec.version.to_s

  gem = "pkg/digest-#{version}#{"-java" if RUBY_ENGINE == "jruby"}.gem"
  File.size?(gem) or abort "gem not built!"

  sh "gem", "install", gem

  require_relative "test/lib/envutil"

  _, _, status = EnvUtil.invoke_ruby([], <<~EOS)
    version = #{version.dump}
    gem "digest", version
    loaded_version = Gem.loaded_specs["digest"].version.to_s

    if loaded_version == version
      puts "digest \#{loaded_version} is loaded."
    else
      abort "digest \#{loaded_version} is loaded instead of \#{version}!"
    end

    require "digest"

    string = "digest"
    actual = Digest::SHA256.hexdigest(string)
    expected = "0bf474896363505e5ea5e5d6ace8ebfb13a760a409b1fb467d428fc716f9f284"
    puts "sha256(\#{string.dump}) = \#{actual.dump}"

    if actual != expected
      abort "no! expected to be \#{expected.dump}!"
    end
  EOS

  if status.success?
    puts "check succeeded!"
  else
    warn "check failed!"
    exit status.exitstatus
  end
end

task :default => :test
