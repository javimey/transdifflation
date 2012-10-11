require 'spec_helper'


describe :YAMLReader do

  before(:each) do
    unless defined?(::Rails)
      @mocked_rails_class = true
      class ::Rails
      end
    end
  end
  describe :read_YAML_from_filesystem do
    it 'should raise an error exception when read_YAML_from_filesystem get nil as an argument' do
      File.stub(:basename).and_return(nil)
      File.stub(:realpath).and_return('/')
      ::Rails.should_receive(:root).and_return('/rails')

      expect {Transdifflation::YAMLReader.read_YAML_from_filesystem('whatever')}.to raise_error(ArgumentError)
    end

    it 'should not raise an error if the file exists at read_YAML_from_filesystem' do
      File.stub(:basename).and_return(nil)
      File.stub(:realpath).and_return('/')
      # Stubbing File to make it exist
      File.stub(:file?).and_return(true)
      ::Rails.should_receive(:root).and_return('/rails')

      
      expect {Transdifflation::YAMLReader.read_YAML_from_filesystem('whatever')}.to_not raise_error(ArgumentError)
    end
  end

  describe :read_YAML_from_gem do
    it 'should raise an error exception when a gem does not exist' do
      File.stub(:join).and_return(nil)
      File.stub(:file?).and_return(true)

      a_gem = 'one_random_gem'
      a_path = './'

      expect {Transdifflation::YAMLReader.read_YAML_from_gem(a_gem, a_path)}.to raise_error(ArgumentError)
    end

    it 'should not raise an error exception when a gem exists (rspec)' do
      a_gem = 'rspec'
      a_path = 'README.md'

      Transdifflation::YAMLReader.stub(:get_YAML_content_from_YAML_file).and_return(':a => 2')
      expect {Transdifflation::YAMLReader.read_YAML_from_gem(a_gem, a_path)}.to_not raise_error(ArgumentError)
    end
  end

  describe :read_YAML_from_pathfile do
    it 'should raise an error exception when a path does not exist' do
      File.stub(:file?).and_return(false)
      a_path = './'

      expect {Transdifflation::YAMLReader.read_YAML_from_pathfile(a_path)}.to raise_error(ArgumentError)
    end

    it 'should not raise an error exception when a path exists (rspec)' do
      File.stub(:basename).and_return(nil)
      File.stub(:file?).and_return(true)
      a_path = 'README.md'

      Transdifflation::YAMLReader.stub(:get_YAML_content_from_YAML_file).and_return(':a => 2')
      expect {Transdifflation::YAMLReader.read_YAML_from_pathfile(a_path)}.to_not raise_error(ArgumentError)
    end
  end

  describe :get_YAML_content_from_YAML_file do
    it 'should return {} when there is no YAML file' do
      a_yml_path = 'bad.yml'
      YAML.stub(:load_file).and_return(false)
      
     Transdifflation::YAMLReader.get_YAML_content_from_YAML_file(a_yml_path).should == {}
    end

    it 'should return the YAML in case it load properly the file' do
      a_yml_path = 'good.yml'
      YAML.stub(:load_file).and_return(['badger', 'elephant', 'tiger'])

      Transdifflation::YAMLReader.get_YAML_content_from_YAML_file(a_yml_path).should == ['badger', 'elephant', 'tiger']
    end
  end

end
