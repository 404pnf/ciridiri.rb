require 'rubygems'
require 'rake/testtask'
require 'rake/gempackagetask'

task :default => :test

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "ciridiri"
    gemspec.version = "0.8.1"
    gemspec.summary = gemspec.description = "Dead simple wiki engine"
    gemspec.email = "vasily@polovnyov.ru"
    gemspec.homepage = "http://vast.github.com/ciridiri.rb"
    gemspec.authors = ["Vasily Polovnyov"]

    gemspec.add_dependency 'sinatra', '>=0.9.1'

    gemspec.add_development_dependency 'rack-test', '>=0.3.0'
    gemspec.add_development_dependency 'contest', '>=0.1.0'

    gemspec.test_files = Dir.glob('test/*')
    gemspec.files = ["LICENSE", "README.md", "Rakefile", "config.ru"] + Dir.glob('lib/**/*') + gemspec.test_files +
                    Dir.glob('public/**/*') + Dir.glob('views/*')

  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
  ENV['RACK_ENV'] = 'test'
end
