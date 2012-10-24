require 'spec_helper'
require_relative "../lib/transdifflation"

describe :get_transdifflation_from_gem do

  before(:each) do
    unless defined?(::Rails)
      @mocked_rails_class = true
      class ::Rails
      end
    end

    @gem_name = 'rake'
    @path_to_yaml_in_gem = 'spec/spec_helper.rb'
    @from_locale= :en
    @to_locale = :es

    @comparer = Transdifflation::Comparer.new

    #YAMLReader should returnb a valid hash
    Transdifflation::YAMLReader.stub(:read_YAML_from_gem).and_return({es: {:home => "hogar"}})

    #We require to simulate "Rails.root"
    ::Rails.stub(:root).and_return('/rails')
  end

  it 'should call get_first_time_file if the files does not exist' do
    #We actually don't care about basename, and we want to generate a testfile in our tests
    File.stub(:basename).and_return('/dir/file_or_something')
    File.stub(:join).and_return(File.join(File.dirname(__FILE__), '/assets/testfile'))

    File.stub(:gsub).and_return('idontcare')
    File.stub(:directory?).and_return(true)
    #File? Should return false, to simulate that the file is not created
    File.stub(:file?).and_return(false)

    @comparer = Transdifflation::Comparer.new
    # And finally we are checking which method is being called, making them throw different exceptions
    @comparer.stub(:get_first_time_file).and_raise(ArgumentError)
    @comparer.stub(:generate_diff_file).and_raise(NameError)
    @comparer.should_receive(:get_first_time_file)

    expect {@comparer.get_transdifflation_from_gem(@gem_name, @path_to_yaml_in_gem, @from_locale, @to_locale) }.to raise_error(ArgumentError)
  end

  it 'should call generate_diff_file if the files exists' do

    #We actually don't care about basename, and we want to generate a testfile in our tests
    File.stub(:basename).and_return('/dir/file_or_something')
    File.stub(:join).and_return(File.join(File.dirname(__FILE__), '/assets/testfile'))

    File.stub(:gsub).and_return('idontcare')
    File.stub(:directory?).and_return(true)
    #File? Should return true, to simulate that the file is exists
    File.stub(:file?).and_return(true)

    # And finally we are checking which method is being called, making them throw different exceptions
    @comparer.stub(:get_first_time_file).and_raise(ArgumentError)
    @comparer.stub(:generate_diff_file).and_raise(NameError)
    @comparer.should_receive(:generate_diff_file)

    expect {@comparer.get_transdifflation_from_gem(@gem_name, @path_to_yaml_in_gem, @from_locale, @to_locale) }.to raise_error(NameError)
  end

  it 'should translate yaml name from source locale to target locale' do
    @path_to_yaml_in_gem = 'config/locales/en/gem_name.en.yml'  #source file, it has to be translated, and match inner reg exp

    #File? Should return true, to simulate that the file is exists
    File.stub(:file?).and_return(true)
    #Finally simulate the call to generate_diff_file
    @comparer.stub(:generate_diff_file).and_return(nil)
    File.stub(:directory?).and_return(true)

    #call to method
    expect { @comparer.get_transdifflation_from_gem(@gem_name, @path_to_yaml_in_gem, @from_locale, @to_locale) }.to_not raise_error
  end
end

describe :get_transdifflation_from_file do

  before(:each) do
    unless defined?(::Rails)
      @mocked_rails_class = true
      class ::Rails
      end
    end

    @tag_name = 'my_tag'
    @path_to_yaml_relative_from_rails_root = 'spec/spec_helper.rb'
    @from_locale= :en
    @to_locale = :es

    @comparer = Transdifflation::Comparer.new

    #YAMLReader should returnb a valid hash
    Transdifflation::YAMLReader.stub(:read_YAML_from_pathfile).and_return({es: {:home => "hogar"}})

    #We require to simulate "Rails.root"
    ::Rails.stub(:root).and_return('/rails')
  end

  it 'should call get_first_time_file if the files does not exist' do
    #We actually don't care about basename, and we want to generate a testfile in our tests
    File.stub(:basename).and_return('/dir/file_or_something')
    File.stub(:join).and_return('./spec/assets/testfile_path')
    #We require to simulate "Rails.root"
    ::Rails.should_receive(:root).and_return('/rails')
    File.stub(:gsub).and_return('idontcare')
    #File? Should return false, to simulate that the file is not created
    File.stub(:file?).and_return(false)

    # And finally we are checking which method is being called, making them throw different exceptions
    @comparer.stub(:get_first_time_file).and_raise(ArgumentError)
    @comparer.stub(:generate_diff_file).and_raise(NameError)
    @comparer.should_receive(:get_first_time_file)
    expect { @comparer.get_transdifflation_from_file(@tag_name, @path_to_yaml_relative_from_rails_root, @from_locale, @to_locale) }.to raise_error(ArgumentError)
  end

  it 'should call generate_diff_file if the files exists' do

    #We actually don't care about basename, and we want to generate a testfile in our tests
    File.stub(:basename).and_return('/dir/file_or_something')
    File.stub(:join).and_return('./spec/assets/testfile')
    #We require to simulate "Rails.root"
    ::Rails.should_receive(:root).and_return('/rails')
    File.stub(:gsub).and_return('idontcare')
    #File? Should return false, to simulate that the file is not created
    File.stub(:file?).and_return(true)
    File.stub(:directory?).and_return(true)

    # And finally we are checking which method is being called, making them throw different exceptions
    @comparer.stub(:get_first_time_file).and_raise(ArgumentError)
    @comparer.stub(:generate_diff_file).and_raise(NameError)
    @comparer.should_receive(:generate_diff_file)
    expect { @comparer.get_transdifflation_from_file(@tag_name, @path_to_yaml_relative_from_rails_root, @from_locale, @to_locale) }.to raise_error(NameError)
  end

  it 'should translate yaml name from source locale to target locale' do
    @path_to_yaml_relative_from_rails_root = '../config/locales/en/file_name.en.yml'  #source file, it has to be translated, and match inner reg exp

    #File? Should return true, to simulate that the file is exists
    File.stub(:join).and_return('idontcare')
    File.stub(:file?).and_return(true)
    #Finally simulate the call to generate_diff_file
    @comparer.stub(:generate_diff_file).and_return(nil)

    #call to method
    expect { @comparer.get_transdifflation_from_file(@tag_name, @path_to_yaml_relative_from_rails_root, @from_locale, @to_locale) }.to_not raise_error
  end
end


describe :comparer_common_methods do

  before(:each) do
    unless defined?(::Rails)
      @mocked_rails_class = true
      class ::Rails
      end
    end

    @gem_name = 'rake'
    @path_to_yaml_in_gem = 'spec/spec_helper.rb'
    @from_locale= :en
    @to_locale = :es

    @comparer = Transdifflation::Comparer.new

    #YAMLReader should returnb a valid hash
    Transdifflation::YAMLReader.stub(:read_YAML_from_gem).and_return({en: {:home => "hogar"}})
    #We require to simulate "Rails.root"
    ::Rails.stub(:root).and_return('/rails')
  end

  it 'should generate first timefile if the files does not exist' do

    #We actually don't care about basename, and we want to generate a testfile in our tests
    File.stub(:basename).and_return('config/locales/en/gem_name.en.yml')

    #File? Should return false, to simulate that the file is not created
    File.stub(:file?).and_return(false)

    #now we must stub File.open, write and close in order to avoid fails on get_first_time_file
    mock_file = mock("File")
    mock_file.stub(:write).and_return(nil)
    mock_file.stub(:close).and_return(nil)
    File.stub(:open).and_return(mock_file)
    File.stub(:directory?).and_return(true)

    expect {@comparer.get_transdifflation_from_gem(@gem_name, @path_to_yaml_in_gem, @from_locale, @to_locale) }.to_not raise_error
  end

  it 'should try to copy config_example_file if asked' do

    FileUtils.stub(:copy).and_return(nil)
    expect { Transdifflation::Comparer.generate_config_example_file('foo/bar') }.to_not raise_error
  end

  it 'should generate a valid diff_file when differences not exists' do

    #We actually don't care about basename, and we want to generate a testfile in our tests
    File.stub(:basename).and_return('/dir/file_or_something')
    File.stub(:join).and_return('./spec/assets/testfile')
    #We require to simulate "Rails.root"
    ::Rails.should_receive(:root).and_return('/rails')
    File.stub(:gsub).and_return('idontcare')
    File.stub(:directory?).and_return(true)
    #File? Should return false, to simulate that the file is not created
    File.stub(:file?).and_return(true)

    #YAMLReader should return TWO valid hashes
    Transdifflation::YAMLReader.stub(:read_YAML_from_pathfile).and_return( {es: {:dorothy => "Dorothy"}})

    #now we must stub File.open, write and close in order to avoid fails on get_first_time_file
    mock_file = mock("File")
    mock_file.stub(:write).and_return(nil)
    mock_file.stub(:close).and_return(nil)
    File.stub(:open).and_return(mock_file)

    expect { @comparer.get_transdifflation_from_gem(@gem_name, @path_to_yaml_in_gem, @from_locale, @to_locale) }.to_not raise_error
  end

  it 'should generate a clear diff_file when differences exists' do

    #We actually don't care about basename, and we want to generate a testfile in our tests
    File.stub(:basename).and_return('/dir/file_or_something')
    File.stub(:join).and_return('./spec/assets/testfile')
    #We require to simulate "Rails.root"
    ::Rails.should_receive(:root).and_return('/rails')
    File.stub(:gsub).and_return('idontcare')
    File.stub(:directory?).and_return(true)
    #File? Should return false, to simulate that the file is not created
    File.stub(:file?).and_return(true)

    #now we must stub File.open, write and close in order to avoid fails on get_first_time_file
    mock_file = mock("File")
    mock_file.stub(:write).and_return(nil)
    mock_file.stub(:close).and_return(nil)
    File.stub(:open).and_return(mock_file)

    #YAMLReader should return TWO valid hashes
    Transdifflation::YAMLReader.stub(:read_YAML_from_pathfile).and_return({en: {:home => "hogar"}})
    expect { @comparer.get_transdifflation_from_gem(@gem_name, @path_to_yaml_in_gem, @from_locale, @from_locale) }.to_not raise_error
  end

  it "should create a folder in get_transdifflation_from_gem when it doesn't exist" do
    #We actually don't care about basename, and we want to generate a testfile in our tests
    File.stub(:basename).and_return('/dir/file_or_something')

    Transdifflation::YAMLReader.stub(:read_YAML_from_gem).and_return({en: {:home => "hogar"}})    #We require to simulate "Rails.root"
    ::Rails.should_receive(:root).and_return('/rails')
    File.stub(:gsub).and_return('idontcare')

    File.stub(:directory?).and_return(false)
    #File? Should return false, to simulate that the file is not created

    File.stub(:join).and_return(["./spec/tempFolder"])
    File.stub(:file?).and_return(false)

    #now we must stub File.open, write and close in order to avoid fails on get_first_time_file
    mock_file = mock("File")
    mock_file.stub(:write).and_return(nil)
    mock_file.stub(:close).and_return(nil)
    File.stub(:open).and_return(mock_file)

    @comparer.get_transdifflation_from_gem(@gem_name, @path_to_yaml_in_gem, @from_locale, @from_locale)
    FileUtils.remove_dir("./spec/tempFolder").should == 0
  end

  it "should create a folder in get_transdifflation_from_file when it doesn't exist" do
    #We actually don't care about basename, and we want to generate a testfile in our tests
    File.stub(:basename).and_return('/dir/file_or_something')

    Transdifflation::YAMLReader.stub(:read_YAML_from_pathfile).and_return({en: {:home => "hogar"}})    #We require to simulate "Rails.root"
    ::Rails.should_receive(:root).and_return('/rails')
    File.stub(:gsub).and_return('idontcare')

    File.stub(:directory?).and_return(false)
    #File? Should return false, to simulate that the file is not created

    File.stub(:join).and_return(["./spec/tempFolder"])
    File.stub(:file?).and_return(false)

    #now we must stub File.open, write and close in order to avoid fails on get_first_time_file
    mock_file = mock("File")
    mock_file.stub(:write).and_return(nil)
    mock_file.stub(:close).and_return(nil)
    File.stub(:open).and_return(mock_file)

    @comparer.get_transdifflation_from_file(@gem_name, @path_to_yaml_in_gem, @from_locale, @from_locale)
    FileUtils.remove_dir("./spec/tempFolder").should == 0
  end
end


