require 'spec_helper'
require 'pry'

describe :symbolize! do
  it 'convert a key in a Hash (presumily from YAML) in symbol' do
    example_hash = { "es" => 666 }
    example_hash.symbolize!
	example_hash.should ==  { :es => 666 }
  end

  it 'convert all keys in a Hash (presumily from YAML) in symbols' do
    example_hash = { "es" => 666, "lala" => "truururur" }
    example_hash.symbolize!
	example_hash.should ==  { :es => 666, :lala => "truururur" }
  end

  it 'convert all keys in a Hash (presumily from YAML) in symbols but if there is a hash it should leave it' do
    example_hash = { :es => 666, "lala" => "truururur" }
    example_hash.symbolize!
	example_hash.should ==  { :es => 666, :lala => "truururur" }
  end

  it 'should return something usefull on nil' do
    example_hash = Hash.new
    example_hash.symbolize!
	example_hash.should ==  {}
  end
end