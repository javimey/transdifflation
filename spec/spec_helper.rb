require 'rubygems'
require 'simplecov'
SimpleCov.start do
  add_filter "spec/"
end

require 'transdifflation/version'
require 'transdifflation/yaml_reader'
require 'transdifflation/yaml_writer'
require 'transdifflation/exceptions'
require 'transdifflation/utilities'
require 'yaml'


RSpec.configure do |config|
  # some (optional) config here

end
