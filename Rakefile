require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test" << "test/lib" << "lib"
  t.ruby_opts << "-rhelper"
  t.test_files = FileList["test/**/test_*.rb"]
end

if RUBY_ENGINE == 'jruby'
  require 'rake/javaextensiontask'
  Rake::JavaExtensionTask.new("digest") do |ext|
    ext.source_version = '1.8'
    ext.target_version = '1.8'
    ext.ext_dir = 'ext/java'
  end

  # copy library loaders
  require 'fileutils'
  %w(bubblebabble md5 rmd160 sha1 sha2).each do |ext|
    FileUtils.mkdir "./lib/digest" unless File.exist?("./lib/digest")
    FileUtils.cp "./ext/digest/#{ext}/lib/#{ext}.rb", "./lib/digest/#{ext}.rb"
  end
else
  require 'rake/extensiontask'
  Rake::ExtensionTask.new("digest")
  %w(bubblebabble md5 rmd160 sha1 sha2).each do |ext|
    Rake::ExtensionTask.new("digest/#{ext}")
  end
end

task :sync_tool do
  require 'fileutils'
  FileUtils.cp "../ruby/tool/lib/test/unit/core_assertions.rb", "./test/lib"
  FileUtils.cp "../ruby/tool/lib/envutil.rb", "./test/lib"
  FileUtils.cp "../ruby/tool/lib/find_executable.rb", "./test/lib"
end

task :default => :test
