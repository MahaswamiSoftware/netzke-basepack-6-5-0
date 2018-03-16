require 'yard'
require "bundler/gem_tasks"
require "./lib/netzke/basepack/version"

YARD::Rake::YardocTask.new do |t|
  t.options = ['--title', "Netzke Basepack #{Netzke::Basepack::VERSION}"]
end

namespace :yard do
  desc "Publish docs to api.netzke.org"
  task publish: :yard do
    dir = 'www/api.netzke.org/basepack'
    puts "Publishing to fl:#{dir}..."
    `ssh fl "mkdir -p #{dir}"`
    `scp -r doc/* fl:#{dir}`
  end
end

desc "Run all tests"
task :test do
  system("cd spec/rails_app && RAILS_ENV=test rake db:migrate") &&
  system("bundle exec rspec spec") ||
  abort
end

desc 'rake test'
task default: :test
