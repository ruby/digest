require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test" << "test/lib"
  t.libs << "lib"
  t.test_files = FileList["test/**/test_*.rb"]
end

require 'rake/extensiontask'
%w(bubblebabble md5 rmd160 sha1 sha2).each do |ext|
  Rake::ExtensionTask.new("digest/#{ext}")
end

task :default => :test
