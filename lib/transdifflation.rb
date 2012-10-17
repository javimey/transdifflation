require 'transdifflation/version'
require 'transdifflation/yaml_reader'
require 'transdifflation/yaml_writer'
require 'transdifflation/exceptions'
require 'transdifflation/utilities'

require 'pry'

# The main module for the program
module Transdifflation

  require 'transdifflation/railtie' if defined?(Rails) 

  # Implements the core
  class Comparer

    #const string added to keys not translated
    NOT_TRANSLATED = "**NOT_TRANSLATED** "
    #Instance variable to get if changes have been detected
    attr_reader :has_changes

    def initialize()
      @has_changes = false
    end

    # Get Diff from YAML translation locale file from a gem and generate differences in a file on our host
    #
    # @param [String] gem_name    Installed gem's name
    # @param [String] path_to_yaml_in_gem Path of the file inside gem's source code
    # @param [Symbol] from_locale Default locale in gem. Used to translate 'from'
    # @param [Symbol] to_locale   Default locale in host. Used to translate 'to'
    def get_transdifflation_from_gem(gem_name, path_to_yaml_in_gem, from_locale=:en, to_locale=:es )

      #default values in optional params
      from_locale ||= I18n.default_locale
      to_locale ||= I18n.locale


      yml_gem_content = YAMLReader.read_YAML_from_gem(gem_name, path_to_yaml_in_gem)
      puts "Loaded YAML content from gem '#{gem_name}', file '#{path_to_yaml_in_gem}'"


      #build the file name in our host
      filename_in_gem_SRC = File.basename( path_to_yaml_in_gem )
      host_target_filename = filename_in_gem_SRC.gsub(/-?#{from_locale}\./) do |match_s|
        match_s.sub("#{from_locale}", "#{to_locale}")
      end
      host_target_file = File.join( Rails.root, "config/locales/#{to_locale}", "#{gem_name}.#{host_target_filename}")

      if(!File.file? host_target_file)
        get_first_time_file(yml_gem_content, host_target_file, from_locale, to_locale)
      else
        generate_diff_file(yml_gem_content, host_target_file, from_locale, to_locale)
      end

      @has_changes
    end



    # Get Diff from YAML translation locale file from filesystem and generate differences in a file on our host
    #
    # @param [String] tag_name    Tag name this file will be installed on host
    # @param [String] path_to_yaml_relative_from_rails_root Path to the file in system, relative from Rails.root
    # @param [Symbol] from_locale Default locale in gem. Used to translate 'from'
    # @param [Symbol] to_locale   Default locale in host. Used to translate 'to'
    def get_transdifflation_from_file(tag_name, path_to_yaml_relative_from_rails_root, from_locale=:en, to_locale=:es )

      #default values in optional params
      from_locale ||= I18n.default_locale
      to_locale ||= I18n.locale

      yml_source_content = YAMLReader.read_YAML_from_pathfile(path_to_yaml_relative_from_rails_root)
      puts "Loaded YAML content from file '#{path_to_yaml_relative_from_rails_root}'"

      #build the file name in our host
      filename_in_SRC = File.basename( path_to_yaml_relative_from_rails_root )
      host_target_filename = filename_in_SRC.gsub(/-?#{from_locale}\./) do |match_s|
        match_s.sub("#{from_locale}", "#{to_locale}")
      end
      host_target_file = File.join( Rails.root, "config/locales/#{to_locale}", "#{tag_name}.#{host_target_filename}")

      if(!File.file? host_target_file)
        get_first_time_file(yml_source_content, host_target_file, from_locale, to_locale)
      else
        generate_diff_file(yml_source_content, host_target_file, from_locale, to_locale)
      end

      @has_changes
    end


    # Get Diff from YAML translation locale file from filesystem and generate differences in a file on our host
    #
    # @param [String] source I18n source translation to compare
    # @param [String] target I18n target translation to compare
    # @param [Symbol] from_locale Default locale in gem. Used to translate 'from'
    # @param [Symbol] to_locale   Default locale in host. Used to translate 'to'
    def get_rest_of_translation(source, target, from_locale, to_locale)

      added_diff_hash = {}
      generate_added_diff(source, target, added_diff_hash, Array.new,  from_locale, to_locale, false)
      added_diff_hash.unsymbolize!
    end


    # Get Coverage rate from two hashes, depending on the number of keys that have a given token
    #
    # @param [Hash] hash_from_locale I18n source translation to compare
    # @param [Hash] hash_to_locale I18n target translation to compare
    # @param [String] token The string you want to compare. example: **NOT TRANSLATED**
    def coverage_rate(hash_from_locale, hash_to_locale, token = NOT_TRANSLATED)      
        
      if hash_from_locale.nil?
        return "Translation coverage error: from_locale language not detected."
      end

      if hash_to_locale.nil?
        return "Translation coverage error: to_locale language not detected."
      end
      
      if hash_from_locale.empty?
        return "from_locale is empty, so you have everything translated"         
      end

      words = 0
      found = 0

      words, found = rate_from_branch(hash_from_locale, hash_to_locale, token, words, found)
      percent = (found.to_f/words.to_f) * 100
      truncate = "%.2f" % percent
      return "#{truncate}% #{found}/#{words} entries translated"
    end


    # Get the number of translated keys 
    #
    # @param [Hash] hash_from I18n source translation to compare
    # @param [Hash] hash_to I18n target translation to compare
    # @param [String] token The string you want to compare. example: **NOT TRANSLATED**
    # @param [Integer] words Number of keys (accumulated) from hash_from
    # @param [Integer] found Number of keys (accumulated) where token is not found in hash_to 
    def rate_from_branch(hash_from, hash_to, token, words, found)

      hash_from.each_pair{ |key, value|
        if hash_from[key.to_sym].instance_of? Hash
          if hash_to[key.to_sym]
            words, found = rate_from_branch(hash_from[key.to_sym], hash_to[key.to_sym], token, words, found)
          else
          # Sum other words
          # could have nested branches, so we call it with hash_from[key.to_sym] to count the number of words, returning the found to a temporal var
          words, temp = rate_from_branch(hash_from[key.to_sym], hash_from[key.to_sym], token, words, found)
          end
        else
          words += 1
          if hash_to[key.to_sym]
            found += 1 if !hash_to[key.to_sym].to_s.include?(token) 
          end          
        end
      }
      return words, found
    end      

    private

    # Build the initial translation file
    #
    # @param [String] yml_source_content  Content to translate
    # @param [String] host_target_file    The filename to create
    # @param [Symbol] from_locale Default locale in gem. Used to translate 'from'
    # @param [Symbol] to_locale   Default locale in host. Used to translate 'to'
    def get_first_time_file(yml_source_content, host_target_file, from_locale, to_locale)

      puts "Target translation file '#{host_target_file}' not found, generating it for the first time"
      #create a file
      host_target_file_stream = File.open(host_target_file, "a+:UTF-8")

      begin
        translated_yaml = {}
        #translate from source yaml content, to target existant yml
        translate_keys_in_same_yaml(yml_source_content, translated_yaml, from_locale, to_locale)

        host_target_file_stream.write(YAMLWriter.to_yaml(translated_yaml))
        @has_changes = true
      ensure
        host_target_file_stream.close
      end
    end


    # Recursively translate hash from YAML file
    #
    # @param [Hash]   source      Hash from origin YAML file
    # @param [Hash]   target      Hash from target YAML file
    # @param [Symbol] from_locale Locale used to translate 'from'
    # @param [Symbol] to_locale   Locale used to translate 'to'
    # @param [Boolean] add_NOT_TRANSLATED   Boolean to set if it should add "**NOT_TRANSLATED** " to value (default = true)
    def translate_keys_in_same_yaml(source, target, from_locale, to_locale, add_NOT_TRANSLATED=true)

      source.each_pair { |source_key, source_value|

        key_is_symbol = source_key.instance_of? Symbol

        source_key_translated = source_key.to_s.sub(/^#{from_locale}$/, "#{to_locale}")
        source_key_translated = source_key_translated.to_sym if key_is_symbol

        #if value is a hash, we call it recursively
        if (source_value.instance_of? Hash)
          if(!target.has_key? (source_key_translated))
            target[source_key_translated] = Hash.new
          end
          translate_keys_in_same_yaml(source_value, target[source_key_translated], from_locale, to_locale, add_NOT_TRANSLATED) #recurrence of other hashes
        else
          #it's a leaf node
          target[source_key_translated] = (add_NOT_TRANSLATED ? "#{NOT_TRANSLATED}#{source_value}" : "#{source_value}") if  !target.has_key? (source_key_translated)
        end
      }
    end

    def generate_diff_file(yml_source_content, host_target_file, from_locale, to_locale)

      existant_yml = YAMLReader.read_YAML_from_pathfile(host_target_file)
      added_diff_hash, removed_diff_hash = Hash.new, Hash.new

      generate_added_diff(yml_source_content, existant_yml, added_diff_hash, Array.new, from_locale, to_locale)
      generate_added_diff(existant_yml, yml_source_content, removed_diff_hash, Array.new,  to_locale, from_locale, false)

      if (removed_diff_hash.length > 0)
        #we have to reprocess hash to show user what happened
        temp_removed_diff_hash = {}
        translate_keys_in_same_yaml(removed_diff_hash, temp_removed_diff_hash, from_locale, to_locale, false)
        removed_diff_hash = temp_removed_diff_hash
        
      end


      if( added_diff_hash.length > 0 || removed_diff_hash.length > 0 )

        diff_file = File.join(File.dirname(host_target_file), "#{File.basename(host_target_file)}.diff")
        diff_file_stream = File.new(diff_file, "w+:UTF-8")
        begin
           
          if (added_diff_hash.length > 0)
            diff_file_stream.write("ADDED KEYS (Keys not found in your file, founded in source file) ********************\n")
            diff_file_stream.write(YAMLWriter.to_yaml(added_diff_hash))  #we can't use YAML#dump due to issues wuth Utf8 chars
          end

          if (removed_diff_hash.length > 0)
            diff_file_stream.write("\n\n") if (added_diff_hash.length > 0)
            diff_file_stream.write("REMOVED KEYS (Keys not found in source file, founded in your file) ********************\n")
            diff_file_stream.write(YAMLWriter.to_yaml(removed_diff_hash))  #we can't use YAML#dump due to issues wuth Utf8 chars
          end

        ensure
          diff_file_stream.close
        end
        puts "File #{File.basename( host_target_file )} processed >> %s" %  [ "#{File.basename( diff_file )} has the changes!"]
        @has_changes = true
      else 
        puts "File #{File.basename( host_target_file )} processed >> No changes!"
      end
    end


    # Recursively generate difference hash from YAML file
    #
    # @param [Hash]   source           Hash from origin YAML file
    # @param [Hash]   target           Hash from target YAML file
    # @param [Hash]   added_diff_hash  Hash containing differences; at the first time, it should be empty
    # @param [Array]  key_trace_passed Array containing trace of the key generated, recursively. At the first time, it should be empty
    # @param [Symbol] from_locale      Default locale in gem. Used to translate 'from'
    # @param [Symbol] to_locale        Default locale in host. Used to translate 'to'
    # @param [Boolean] add_NOT_TRANSLATED   Boolean to set if it should add "**NOT_TRANSLATED** " to value (default = true)
    # @return [Hash] the resulting hash translated
    def generate_added_diff(source, target, added_diff_hash, key_trace_passed, from_locale, to_locale, add_NOT_TRANSLATED=true)

      source.each_pair { |source_key, source_value|
        key_trace = key_trace_passed.dup #each pair should have a clear copy of the same array
        key_is_symbol = source_key.instance_of? Symbol
        source_key_translated = source_key.to_s.sub(/^#{from_locale}$/, "#{to_locale}")
        source_key_translated = source_key_translated.to_sym if key_is_symbol

        #if value is a hash, we call it recursively
        if (source_value.instance_of? Hash)
          key_trace.push source_key_translated #add the key to the trace to be generated if necessary
          target[source_key_translated] = Hash.new if(!target.has_key? (source_key_translated))  #to continue trace, otherwise, node will not exist in next iteration
          generate_added_diff(source_value, target[source_key_translated], added_diff_hash, key_trace, from_locale, to_locale, add_NOT_TRANSLATED) #recursively call
        else #it's a leaf node

          if !target.has_key? (source_key_translated)
            added_diff_hash_positioned = added_diff_hash #pointer to added_diff_hash
            key_trace.each do |key|  #add the keys if necessary on the accurate level
              added_diff_hash_positioned [key] = Hash.new if(!added_diff_hash_positioned.has_key? key )
              added_diff_hash_positioned = added_diff_hash_positioned [key] #and position pointer to next level
            end
            added_diff_hash_positioned[source_key_translated] = (add_NOT_TRANSLATED ? "#{NOT_TRANSLATED}#{source_value}" : "#{source_value}")    #add the inexistant key
          end
        end
      }
    end

    def self.generate_config_example_file(path)
      FileUtils.copy(File.expand_path('./transdifflation/transdifflation.yml', File.dirname( __FILE__ )), path)
    end
  end
end
