require 'rails'


namespace :transdifflation do

  def get_coverage_rate(from_locale, to_locale)
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
    translations = I18n.backend.send(:translations)

    hash_from_locale = translations[from_locale]
    hash_to_locale = translations[to_locale]

    comparer = Transdifflation::Comparer.new
    comparer.coverage_rate(hash_from_locale, hash_to_locale)
  end

  desc "A task to check a translation coverage"
  task :coverage, [:from_locale, :to_locale] => [:environment] do |t, args|

    args.with_defaults(:from_locale => I18n.default_locale, :to_locale => I18n.locale)
    puts "\nChecking how much work you have left...\n"
    from_locale = args[:from_locale].to_sym
    to_locale = args[:to_locale].to_sym
    #token = args[:token]

    differences = get_coverage_rate(from_locale, to_locale)
    puts "You have #{differences}"
  end



end
