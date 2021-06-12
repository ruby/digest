require "bundler/gem_tasks"
require "rake/testtask"
require 'fileutils'

Rake::TestTask.new(:test) do |t|
  t.libs << "test" << "test/lib" << "lib"
  t.ruby_opts << "-rhelper"
  t.test_files = FileList["test/**/test_*.rb"]
end

require 'rake/javaextensiontask'
Rake::JavaExtensionTask.new("digest") do |ext|
  ext.source_version = '1.8'
  ext.target_version = '1.8'
  ext.ext_dir = 'ext/java'
end

algorithms = %w(bubblebabble md5 rmd160 sha1 sha2)

# copy library loaders
FileUtils.mkdir "./lib/digest" unless File.exist?("./lib/digest")
algorithms.each do |ext|
  source = "./ext/digest/#{ext}/lib/#{ext}.rb"
  if File.exist? source
    FileUtils.cp source, "./lib/digest/#{ext}.rb"
  end
end

if RUBY_ENGINE == 'jruby'
  File.write("./lib/digest/bubblebabble.rb", <<-FILE)
# frozen_string_literal: true
JRuby::Util.load_ext("org.jruby.ext.digest.BubbleBabble")
FILE
  File.write("./lib/digest/md5.rb", <<-FILE)
# frozen_string_literal: true
JRuby::Util.load_ext("org.jruby.ext.digest.MD5")
FILE
  File.write("./lib/digest/rmd160.rb", <<-FILE)
# frozen_string_literal: true
JRuby::Util.load_ext("org.jruby.ext.digest.RMD160")
FILE
  File.write("./lib/digest/sha1.rb", <<-FILE)
# frozen_string_literal: true
JRuby::Util.load_ext("org.jruby.ext.digest.SHA1")
FILE
  File.write("./lib/digest/sha2.rb", File.read("./lib/digest/sha2.rb").sub("require 'digest/sha2.so'", "JRuby::Util.load_ext('org.jruby.ext.digest.SHA2')"))
  File.write("./lib/digest.rb", File.read("./lib/digest.rb").sub("require 'digest.so'", "JRuby::Util.load_ext('org.jruby.ext.digest.DigestLibrary')"))
else
  require 'rake/extensiontask'
  Rake::ExtensionTask.new("digest")
  algorithms.each do |ext|
    Rake::ExtensionTask.new("digest/#{ext}")
  end
end

task :sync_tool do
  FileUtils.cp "../ruby/tool/lib/test/unit/core_assertions.rb", "./test/lib"
  FileUtils.cp "../ruby/tool/lib/envutil.rb", "./test/lib"
  FileUtils.cp "../ruby/tool/lib/find_executable.rb", "./test/lib"
end

task :default => :test
