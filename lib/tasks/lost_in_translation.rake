require 'rails'


namespace :transdifflation do

  def get_differences (from_locale, to_locale)

    #this will access translations method, that is protected in BackEnd in I18n
    
    #Reading config  file
    search_locations = %w[config/transdifflation.yml transdifflation.yml]


    file_task_config = nil
    search_locations.each do |path| #Take config file from these locations
      abs_path = File.expand_path(path, Rails.root)
      if(File.exists?(abs_path))
        file_task_config = abs_path
        break
      end
    end

    raise Transdifflation::ConfigFileNotFound if file_task_config.nil?

    paths_ignored =  YAML.load_file(file_task_config).symbolize![:ignore_paths]
    
    if paths_ignored
      I18n.reload!
      paths_ignored.each {|ignored |
        I18n.load_path.delete_if {|p| p.include?(ignored)}
      }
      I18n.backend.load_translations

    end

    translations = I18n.backend.send(:translations) #Now is nil {}
    # do something with /Faker-/ to remove all Faker yamls from the backend

    hash_from_locale = translations[from_locale]
    hash_to_locale = translations[to_locale]

    comparer = Transdifflation::Comparer.new
    differences = comparer.get_rest_of_translation(hash_from_locale, hash_to_locale, from_locale, to_locale)
    differences = { to_locale.to_s => differences } if !differences.empty?

  end

  desc "What is not translated in our app"
  task :lost_in_translation, [:from_locale, :to_locale] => [:environment] do |t, args|


    args.with_defaults(:from_locale => I18n.default_locale, :to_locale => I18n.locale)
    puts "\nExecuting lost_in_translation ************************** "
    from_locale = args[:from_locale].to_sym
    to_locale = args[:to_locale].to_sym
    differences = get_differences(from_locale, to_locale)

    if !differences.empty?
      missing_translations_file = File.join( Rails.root, "config/locales/#{to_locale}/missing_translations.yml.diff")
      missing_translations_stream = File.new(missing_translations_file, "w+:UTF-8")
      begin
        missing_translations_stream.write("#These are the missing translations Transdifflation found for you\n")
        missing_translations_stream.write(Transdifflation::YAMLWriter.to_yaml(differences))  #we can't use YAML#dump due to issues wuth Utf8 chars
        puts "Detected missing translations, file '#{missing_translations_file}' has them:\n\n#{differences.to_yaml}" if !differences.empty?
      ensure
        missing_translations_stream.close
      end

    else
      puts "Sucess! All translation are done!"
    end
  end

  desc "Testing in CI what is not translated in our app"
  task :lost_in_translation_ci, [:from_locale, :to_locale] => [:environment] do |t, args|

    args.with_defaults(:from_locale => I18n.default_locale, :to_locale => I18n.locale)
    puts "\nExecuting lost_in_translation_ci ************************** "

    differences = get_differences(args[:from_locale].to_sym, args[:to_locale].to_sym)
    fail "Detected missing translations: \n\n#{differences.to_yaml}" if !differences.empty?
    puts "Sucess! All translation are done!"

  end



end
