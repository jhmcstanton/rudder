# frozen_string_literal: true

require 'tasks/docker'

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'yard'

RSpec::Core::RakeTask.new(:unit) do |t|
  t.pattern = Dir['spec/*/**/*_spec.rb'].reject{ |f| f['/integration'] }
end

RSpec::Core::RakeTask.new(:integration) do |t|
  t.pattern = "spec/integration/**/*_spec.rb"
end

task :full_suite => [:docker_up, :unit, :integration, :docker_down]

YARD::Rake::YardocTask.new do |t|
  t.files = ['lib/**/*.rb', 'exe/rudder', 'README.md', 'LICENCE']
  t.options = ['-o', 'docs/']
end

task default: :unit
