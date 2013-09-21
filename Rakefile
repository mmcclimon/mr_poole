require "bundler/gem_tasks"
require 'rspec/core/rake_task'

desc "Run rspec tests with short output"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = "--color"
end

desc "Run rspec tests with long output"
RSpec::Core::RakeTask.new(:dspec) do |t|
  t.rspec_opts = "--color --format documentation"
end
