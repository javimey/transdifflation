#!/usr/bin/env rake
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
Dir['lib/tasks/*'].each { |f| load f }
RSpec::Core::RakeTask.new('spec')