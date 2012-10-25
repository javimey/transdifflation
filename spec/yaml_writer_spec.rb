require 'spec_helper'


describe :YAMLWriter do
  describe :to_yaml do
    it 'should convert to ya2yaml format an input hash' do
      hashy = {:en=>{:date=>{:formats=>{:default=>"%d/%m/%Y", :short=>"%d %b"}}}}
      Transdifflation::YAMLWriter.to_yaml(hashy).should be == ":en:\n  :date:\n    :formats:\n      :default: ! '%d/%m/%Y'\n      :short: ! '%d %b'"
    end

    it 'should convert to ya2yaml format with just one term' do
      hashy = {:movie => "Avengers"}
      Transdifflation::YAMLWriter.to_yaml(hashy).should be == ":movie: Avengers"
    end

    it 'should chomp if matches with the regex: /\?\s+/' do
      hashy = {:movie => "Avengers"}
      Regex = "!ruby/symbol ---? \"es\"\n"
      hashy.deep_stringify_keys.stub(:send).and_return(Regex)

      Transdifflation::YAMLWriter.to_yaml(hashy).should be == ":\"es\""
    end
  end

  describe :deep_stringify_keys do
    it 'should not change anything printing the hash exactly how it is' do
     hashy = {:en=>{:date=>{:formats=>{:default=>"%d/%m/%Y", :short=>"%d %b"}}}}
     hashy.deep_stringify_keys.should == {:en=>{:date=>{:formats=>{:default=>"%d/%m/%Y", :short=>"%d %b"}}}}
    end

    it 'should print all the nodes from a hash in the exact same order' do
     hashy = {:en=>{:date=>{:formats=>{:default=>"%d/%m/%Y", :short=>"%d %b"}}}}
     hashy.deep_stringify_keys.should == hashy
    end

    it 'should print all the nodes from a hash in the exact same order' do
     hashy = {:en=>{:date=>{:formats=>{:default=>"%d/%m/%Y", :short=>"%d %b"}}}}
     hashy.deep_stringify_keys.should == hashy
    end
  end

end
