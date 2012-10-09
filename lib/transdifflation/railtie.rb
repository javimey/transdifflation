require 'transdifflation'
require 'rails'

module Transdifflation

  class Railtie < Rails::Railtie


    search_locations = %w[config/transdifflation.yml transdifflation.yml]

    railtie_name :transdifflation
    rake_tasks do
      begin

        file_task_config = nil
        search_locations.each do |path| #Take config file from these locations
          abs_path = File.expand_path(path, Rails.root)
          if(File.exists?(abs_path))
            file_task_config = abs_path
            break
          end
        end

        raise Transdifflation::ConfigFileNotFound if file_task_config.nil?

        tasks_config =  YAML.load_file(file_task_config)
        tasks_config.symbolize!

        raise Transdifflation::ConfigFileWithErrors, "Transdifflation config file has no parent 'tasks' node" if tasks_config[:tasks].nil?

        #Individual tasks
        task_all = []
        tasks_config[:tasks].each_pair do |key, value|

          task_name = key.to_s
          task_desc = value[:desc].to_s

          raise Transdifflation::ConfigFileWithErrors, "Transdifflation task #{task_name}: has no type defined" if value[:type].nil?

          raise Transdifflation::ConfigFileWithErrors, "Transdifflation task #{task_name}: type defined unknown (%s)" % [value[:type]] if !['gem', 'file'].include?(value[:type])
          task_type = value[:type] == 'gem'? :gem : :file

          raise Transdifflation::ConfigFileWithErrors, "Transdifflation task #{task_name}: has no params defined" if value[:params].nil?
          params = value[:params]
          raise Transdifflation::ConfigFileWithErrors, "Transdifflation task #{task_name}: param 'gem_name' is not defined" if params[:gem_name].nil? && task_type == :gem
          raise Transdifflation::ConfigFileWithErrors, "Transdifflation task #{task_name}: param 'path_in_gem' is not defined" if params[:path_in_gem].nil? && task_type == :gem
          raise Transdifflation::ConfigFileWithErrors, "Transdifflation task #{task_name}: param 'tag_name' is not defined" if params[:tag_name].nil? && task_type == :file
          raise Transdifflation::ConfigFileWithErrors, "Transdifflation task #{task_name}: param 'file_path' is not defined" if params[:file_path_from_rails_root].nil? && task_type == :file

          if(task_type == :gem)

            namespace :transdifflation do
              desc task_desc
              task task_name do
                puts "\nExecuting #{task_name} ************************** "
                comparer = Transdifflation::Comparer.new
                comparer.get_transdifflation_from_gem(params[:gem_name], params[:path_in_gem], params[:from_locale],  params[:to_locale])
              end
            end

          else

            namespace :transdifflation do
              desc task_desc
              task task_name do
                puts "\nExecuting #{task_name} ************************** "
                comparer = Transdifflation::Comparer.new
                comparer.get_transdifflation_from_file(params[:tag_name], params[:file_path_from_rails_root], params[:from_locale],  params[:to_locale])
              end
            end

          end

          task_all.push (task_name)

        end

        #Grouped tasks
        tasks_config[:grouped_tasks].each_pair do |key, value|

          value.map! do |item|
            item.to_sym
          end

          namespace :transdifflation do
            desc "Task #{key} (Grouped Task)"
            task key => value
          end

        end

        #All tasks
        namespace :transdifflation do
          desc "All tasks"
          task :all => task_all
        end

      rescue Transdifflation::ConfigFileNotFound
       
        #Generate task to set-up 
        namespace :transdifflation do
          desc "Task to set-up config file in host"
          task :setup do
              destination_file = File.expand_path('config/transdifflation.yml', Rails.root)
              destination_path = File.dirname(destination_file)
              Transdifflation::Comparer.generate_config_example_file destination_file
              puts "\nCopied a transdifflation.yml example into '#{destination_path}'"
          end
        end

      rescue Transdifflation::ConfigFileWithErrors => e

        raise "Gem 'Transdifflation' says => #{e.message}"  

      rescue Exception => e

        raise "Gem 'Transdifflation' says => #{e.message}"  

      end
    end
  end
end
