require 'rails'


namespace :transdifflation do

  def get_coverage_rate(from_locale, to_locale)
    #this will access translations method, that is protected in BackEnd in I18n
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