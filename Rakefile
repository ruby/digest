require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  ENV["RUBYOPT"] = "-Itest -Itest/lib -Ilib"
  t.test_files = FileList["test/**/test_*.rb"]
end

require 'rake/extensiontask'
Rake::ExtensionTask.new("digest")
%w(bubblebabble md5 rmd160 sha1 sha2).each do |ext|
  Rake::ExtensionTask.new("digest/#{ext}")
end

task :default => :test
