# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts 'Run `bundle install` to install missing gems'
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = 'pokitdok-ruby'
  gem.homepage = 'http://github.com/pokitdok/pokitdok-ruby'
  gem.license = 'MIT'
  gem.summary = %Q(Gem for easy access to the PokitDok Platform APIs)
  gem.description = %Q(Gem for easy access to the PokitDok Platform APIs.)
  gem.email = 'platform@pokitdok.com'
  gem.authors = ['PokitDok, Inc.']
end

Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.verbose = true
end

require 'coveralls'
Coveralls.wear!

desc 'Code coverage detail'
task :simplecov do
  ENV['COVERAGE'] = 'true'
  Rake::Task['spec'].execute
end

task default: :spec

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  @version = File.exist?('VERSION') ? File.read('VERSION') : ''

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = 'pokitdok-ruby #{@version}'
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.main = 'README.md'
end

require 'rubocop/rake_task'
desc 'Run RuboCop on the lib and test directory'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.patterns = %w( 'lib/**/*.rb' 'test/**/*.rb' )
  task.formatters = %w( 'offenses' 'progress' )
  task.fail_on_error = false
end
