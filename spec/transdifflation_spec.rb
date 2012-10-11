require 'spec_helper'
require_relative "../lib/transdifflation"



describe :get_transdifflation_from_gem do
 before(:each) do
   unless defined?(::Rails)
     @mocked_rails_class = true
     class ::Rails
     end
   end
 end
 
 it 'should call get_first_time_file if the files does not exist' do
    gem_name = 'rake'
    path_to_yaml_in_gem = 'spec/spec_helper.rb'
    from_locale= :en
    to_locale = :es
    #YAMLReader should returnb a valid hash
    Transdifflation::YAMLReader.stub(:read_YAML_from_gem).and_return({es: {:home => "casa"}})
    #We actually don't care about basename, and we want to generate a testfile in our tests
    File.stub(:basename).and_return('/dir/file_or_something')
    File.stub(:join).and_return('./spec/assets/testfile')
    #We require to simulate "Rails.root"
    ::Rails.should_receive(:root).and_return('/rails')
    File.stub(:gsub).and_return('idontcare')
    #File? Should return false, to simulate that the file is not created
    File.stub(:file?).and_return(false)
    comparer = Transdifflation::Comparer.new
    # And finally we are checking which method is being called, making them throw different exceptions
    comparer.stub(:get_first_time_file).and_raise(ArgumentError)
    comparer.stub(:generate_diff_file).and_raise(NameError)
    expect {comparer.get_transdifflation_from_gem(gem_name, path_to_yaml_in_gem, from_locale, to_locale) }.to raise_error(ArgumentError)
  end
 
  it 'should call generate_diff_file if the files exists' do
    gem_name = 'rake'
    path_to_yaml_in_gem = 'spec/spec_helper.rb'
    from_locale= :en
    to_locale = :es
    #YAMLReader should returnb a valid hash
    Transdifflation::YAMLReader.stub(:read_YAML_from_gem).and_return({es: {:home => "casa"}})
    #We actually don't care about basename, and we want to generate a testfile in our tests
    File.stub(:basename).and_return('/dir/file_or_something')
    File.stub(:join).and_return('./spec/assets/testfile')
    #We require to simulate "Rails.root"
    ::Rails.should_receive(:root).and_return('/rails')
    File.stub(:gsub).and_return('idontcare')
    #File? Should return false, to simulate that the file is not created
    File.stub(:file?).and_return(true)
    comparer = Transdifflation::Comparer.new
    # And finally we are checking which method is being called, making them throw different exceptions
    comparer.stub(:get_first_time_file).and_raise(ArgumentError)
    comparer.stub(:generate_diff_file).and_raise(NameError)
    expect {comparer.get_transdifflation_from_gem(gem_name, path_to_yaml_in_gem, from_locale, to_locale) }.to raise_error(NameError)
  end
end

describe :get_transdifflation_from_file do
 before(:each) do
   unless defined?(::Rails)
     @mocked_rails_class = true
     class ::Rails
     end
   end
 end
 
 it 'should call get_first_time_file if the files does not exist' do
   
    tag_name = 'my_tag'
    path_to_yaml_relative_from_rails_root = 'spec/spec_helper.rb'
    from_locale= :en
    to_locale = :es
    #YAMLReader should returnb a valid hash
    Transdifflation::YAMLReader.stub(:read_YAML_from_pathfile).and_return({es: {:home => "casa"}})
    #We actually don't care about basename, and we want to generate a testfile in our tests
    File.stub(:basename).and_return('/dir/file_or_something')
    File.stub(:join).and_return('./spec/assets/testfile_path')
    #We require to simulate "Rails.root"
    ::Rails.should_receive(:root).and_return('/rails')
    File.stub(:gsub).and_return('idontcare')
    #File? Should return false, to simulate that the file is not created
    File.stub(:file?).and_return(false)
    comparer = Transdifflation::Comparer.new
    # And finally we are checking which method is being called, making them throw different exceptions
    comparer.stub(:get_first_time_file).and_raise(ArgumentError)
    comparer.stub(:generate_diff_file).and_raise(NameError)
    expect {comparer.get_transdifflation_from_file(tag_name, path_to_yaml_relative_from_rails_root, from_locale, to_locale) }.to raise_error(ArgumentError)
  end
 
  it 'should call generate_diff_file if the files exists' do
    tag_name = 'my_tag'
    path_to_yaml_relative_from_rails_root = 'spec/spec_helper.rb'
    from_locale= :en
    to_locale = :es
    #YAMLReader should returnb a valid hash
    Transdifflation::YAMLReader.stub(:read_YAML_from_pathfile).and_return({es: {:home => "casa"}})
    #We actually don't care about basename, and we want to generate a testfile in our tests
    File.stub(:basename).and_return('/dir/file_or_something')
    File.stub(:join).and_return('./spec/assets/testfile')
    #We require to simulate "Rails.root"
    ::Rails.should_receive(:root).and_return('/rails')
    File.stub(:gsub).and_return('idontcare')
    #File? Should return false, to simulate that the file is not created
    File.stub(:file?).and_return(true)
    comparer = Transdifflation::Comparer.new
    # And finally we are checking which method is being called, making them throw different exceptions
    comparer.stub(:get_first_time_file).and_raise(ArgumentError)
    comparer.stub(:generate_diff_file).and_raise(NameError)
    expect {comparer.get_transdifflation_from_file(tag_name, path_to_yaml_relative_from_rails_root, from_locale, to_locale) }.to raise_error(NameError)
    
  end
end
