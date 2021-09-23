require "bundler/gem_tasks"
require "rake/testtask"
require 'fileutils'

helper = Bundler::GemHelper.instance

lib_dir = RUBY_ENGINE == 'jruby' ? "lib/java" : "lib"

Rake::TestTask.new(:test) do |t|
  t.libs << "test" << "test/lib" << lib_dir
  t.ruby_opts << "-rhelper"
  t.test_files = FileList["test/**/test_*.rb"]
end

algorithms = %w(BubbleBabble MD5 RMD160 SHA1 SHA2)

require 'rake/javaextensiontask'
Rake::JavaExtensionTask.new("digest") do |ext|
  ext.source_version = '1.8'
  ext.target_version = '1.8'
  ext.ext_dir = 'ext/java'
  ext.lib_dir = 'lib/java'
end

java_pkg = nil
task 'compile:java' => 'java:lib' do
  java_pkg = Bundler::GemHelper.instance.build_java_gem
end

task 'java:lib' do
  FileUtils.mkdir_p "./lib/java/digest"
  maps = algorithms.each.with_object({}) {|ext, map| map[ext.downcase] = ext}
  maps.each do |lib, ext|
    begin
      source = File.read("#{__dir__}/ext/digest/#{lib}/lib/#{lib}.rb")
      source["require 'digest/#{lib}.so'"] = "JRuby::Util.load_ext('org.jruby.ext.digest.#{ext}')"
    rescue
      source = <<-FILE
# frozen_string_literal: true
JRuby::Util.load_ext("org.jruby.ext.digest.#{ext}")
FILE
    end
    File.write "./lib/java/digest/#{lib}.rb", source
  end
  source = File.read("#{__dir__}/ext/digest/lib/digest.rb")
  source.gsub!(%r[require 'digest(?:/(\w+))?.so']) {
    "JRuby::Util.load_ext('org.jruby.ext.digest.#{maps.fetch($1, 'DigestLibrary')}')"
  }
  source.gsub!(%r['digest/\w+\K.so(?=')], '')
  File.write("./lib/java/digest.rb", source)
end

unless RUBY_ENGINE == 'jruby'
  require 'rake/extensiontask'
  Rake::ExtensionTask.new("digest")
  algorithms.each do |ext|
    Rake::ExtensionTask.new("digest/#{ext.downcase}")
  end
end

task :sync_tool do
  FileUtils.cp "../ruby/tool/lib/test/unit/core_assertions.rb", "./test/lib"
  FileUtils.cp "../ruby/tool/lib/envutil.rb", "./test/lib"
  FileUtils.cp "../ruby/tool/lib/find_executable.rb", "./test/lib"
end

def helper.build_java_gem
  file_name = nil
  sh([*gem_command, "build", "-V", "--platform=java", spec_path]) do
    file_name = built_gem_path
    pkg = File.join(base, "pkg")
    FileUtils.mkdir_p(pkg)
    FileUtils.mv(file_name, pkg)
    file_name = File.basename(file_name)
    Bundler.ui.confirm "#{name} #{version} built to pkg/#{file_name}."
    file_name = File.join(pkg, file_name)
  end
  file_name
end

task :default => :test
