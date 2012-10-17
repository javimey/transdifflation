require 'spec_helper'
require 'transdifflation'

describe :translation_coverage do
	describe :coverage_rate do
		it 'should return a message when hash_from_locale is an nil hash' do
			@comparer = Transdifflation::Comparer.new
			hash_from_locale = nil
			hash_to_locale  = {}
			token = "**NOT TRANSLATED**"
			
			@comparer.coverage_rate(hash_from_locale, hash_to_locale, token).should == "Translation coverage error: from_locale language not detected."
		end
		it 'should return a message when hash_to_locale is an nil hash' do
			@comparer = Transdifflation::Comparer.new
			hash_from_locale = {}
			hash_to_locale  = nil
			token = "**NOT TRANSLATED**"
			
			@comparer.coverage_rate(hash_from_locale, hash_to_locale, token).should == "Translation coverage error: to_locale language not detected."
		end

		it 'should return 100% when hash_from_locale is empty' do
			@comparer = Transdifflation::Comparer.new
			hash_from_locale = {}
			hash_to_locale  = {}
			token = "**NOT TRANSLATED**"
			
			@comparer.coverage_rate(hash_from_locale, hash_to_locale, token).should == "from_locale is empty, so you have everything translated"
		end

		it 'should return 100% when hash_from_locale is empty, even if there is something at hash_to_locale' do
			@comparer = Transdifflation::Comparer.new
			hash_from_locale = {}
			hash_to_locale  = {:home => "hogar"}
			token = "**NOT TRANSLATED**"

			@comparer.coverage_rate(hash_from_locale, hash_to_locale, token).should == "from_locale is empty, so you have everything translated"
		end

		it 'should return 0% when theres all to translate' do
			@comparer = Transdifflation::Comparer.new
			hash_from_locale = {:home => "home"}
			hash_to_locale  = {}
			token = "**NOT TRANSLATED**"

			@comparer.coverage_rate(hash_from_locale, hash_to_locale, token).should == "0% 0/1 words translated"
		end

		it 'should return 100% when you have everything translated (5/5)' do
			@comparer = Transdifflation::Comparer.new
			hash_from_locale = { :one => "one", :two => "two", :three => "tree", :four => "four", :five => "five" }
			hash_to_locale =   { :one => "uno", :two => "dos", :three => "tres", :four => "cuatro", :five => "cinco" }
			token = "**NOT TRANSLATED**"

			@comparer.coverage_rate(hash_from_locale, hash_to_locale, token).should == "100% 5/5 words translated"
		end

		it 'should return 80% when you have 8/10 terms translated' do
			@comparer = Transdifflation::Comparer.new
			hash_from_locale = { :one => "one", :two => "two", :three => "tree", :four => "four", :five => "five", :six => "six", :seven => "seven", :eight => "eight", :nine => "nine", :ten => "ten" }
			hash_to_locale =   { :one => "uno", :two => "dos", :three => "tres", :four => "cuatro", :five => "cinco", :six => "**NOT TRANSLATED** six", :seven => "**NOT TRANSLATED** seven", :eight => "ocho", :nine => "nueve", :ten => "diez" }
			token = "**NOT TRANSLATED**"

			@comparer.coverage_rate(hash_from_locale, hash_to_locale, token).should == "80% 8/10 words translated"
		end
	end
end
