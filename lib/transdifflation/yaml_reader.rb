module Transdifflation
  # Reads YAML from the specified source
  class YAMLReader

    # Get YAML content from a gem
    #
    # @param [String] gem_name                 Installed gem's name
    # @param [String] file_path_to_yaml_in_gem Path of the file inside gem's source code
    def self.read_YAML_from_gem(gem_name, file_path_to_yaml_in_gem)

      #get where the gem is localized
      gem_SRC =`bundle show #{gem_name}`.chomp
      raise ArgumentError.new("Gem '#{gem_name}' not installed") if ($?.to_i != 0)  #get return code and check if is different from zero

      #get the file within the gem
      yaml_file_in_gem_SRC = File.join( gem_SRC, file_path_to_yaml_in_gem )
      raise ArgumentError.new("File '#{file_path_to_yaml_in_gem}' does not exists in gem '#{gem_name}'") if (!File.file?(yaml_file_in_gem_SRC))

      #read the yml content file
      get_YAML_content_from_YAML_file(yaml_file_in_gem_SRC)
     
    end

    # Get YAML content from a file in filesystem
    #
    # @param [String] path_to_yaml_relative_from_rails_root  Tag name this file will be intalled on host
    def self.read_YAML_from_filesystem(path_to_yaml_relative_from_rails_root)

      #get the file
      yaml_file_path = File.realpath(path_to_yaml_relative_from_rails_root, Rails.root)
      yaml_file_name = File.basename( yaml_file_path )
      raise ArgumentError.new("File '#{yaml_file_name}' does not exists in path '#{yaml_file_path}'") if (!File.file?(yaml_file_path))

      #read the yml content file
      get_YAML_content_from_YAML_file(yaml_file_path)
     
    end

    # Get YAML content from a file in filesystem
    #
    # @param [String] path_to_yaml  Tag name this file will be intalled on host
    def self.read_YAML_from_pathfile(path_to_yaml)

      #get the file
      yaml_file_name = File.basename( path_to_yaml )
      raise ArgumentError.new("File '#{yaml_file_name}' does not exists in path '#{path_to_yaml}'") if (!File.file?(path_to_yaml))

      #read the yml content file
      get_YAML_content_from_YAML_file(path_to_yaml)     
    end

    private

    def self.get_YAML_content_from_YAML_file(yml_path_file)

      #read the yml content file
      yml_source_content = YAML.load_file(yml_path_file)
      yml_source_content = {} if (yml_source_content == false)

      #return
      yml_source_content

    end
  end
end
