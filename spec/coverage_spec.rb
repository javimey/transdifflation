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

      @comparer.coverage_rate(hash_from_locale, hash_to_locale, token).should == "0.00% 0/1 entries translated"
    end

    it 'should return 100% when you have everything translated (5/5)' do
      @comparer = Transdifflation::Comparer.new
      hash_from_locale = { :one => "one", :two => "two", :three => "tree", :four => "four", :five => "five" }
      hash_to_locale =   { :one => "uno", :two => "dos", :three => "tres", :four => "cuatro", :five => "cinco" }
      token = "**NOT TRANSLATED**"

      @comparer.coverage_rate(hash_from_locale, hash_to_locale, token).should == "100.00% 5/5 entries translated"
    end

    it 'should return 80% when you have 8/10 terms translated' do
      @comparer = Transdifflation::Comparer.new
      hash_from_locale = { :one => "one", :two => "two", :three => "tree", :four => "four", :five => "five", :six => "six", :seven => "seven", :eight => "eight", :nine => "nine", :ten => "ten" }
      hash_to_locale =   { :one => "uno", :two => "dos", :three => "tres", :four => "cuatro", :five => "cinco", :six => "**NOT TRANSLATED** six", :seven => "**NOT TRANSLATED** seven", :eight => "ocho", :nine => "nueve", :ten => "diez" }
      token = "**NOT TRANSLATED**"

      @comparer.coverage_rate(hash_from_locale, hash_to_locale, token).should == "80.00% 8/10 entries translated"
    end


    it 'should return 70% when you have 7/10 terms translated, but you dont have a term, even in the hash and 2 of them are not translated' do
      @comparer = Transdifflation::Comparer.new
      hash_from_locale = { :one => "one", :two => "two", :three => "tree", :four => "four", :five => "five", :six => "six", :seven => "seven", :eight => "eight", :nine => "nine", :ten => "ten" }
      hash_to_locale =   { :one => "uno", :two => "dos", :three => "tres", :four => "cuatro", :five => "cinco", :six => "**NOT TRANSLATED** six", :seven => "**NOT TRANSLATED** seven", :eight => "ocho", :nine => "nueve" }
      token = "**NOT TRANSLATED**"

      @comparer.coverage_rate(hash_from_locale, hash_to_locale, token).should == "70.00% 7/10 entries translated"
    end

    it 'should return 62.50% when you have 5/8 terms translated' do
      @comparer = Transdifflation::Comparer.new
      hash_from_locale = { :one => "one", :two => "two", :three => "tree", :four => "four", :five => "five", :six => "six", :seven => "seven", :eight => "eight" }
      hash_to_locale =   { :one => "uno", :two => "**NOT TRANSLATED** two", :three => "tres", :four => "cuatro", :five => "cinco", :six => "**NOT TRANSLATED** six", :seven => "**NOT TRANSLATED** seven", :eight => "ocho"}
      token = "**NOT TRANSLATED**"

      @comparer.coverage_rate(hash_from_locale, hash_to_locale, token).should == "62.50% 5/8 entries translated"
    end

    it 'should return 62.50% when you have 5/8 terms translated, having extra terms at the hash_to_locale hash' do
      @comparer = Transdifflation::Comparer.new
      hash_from_locale = { :one => "one", :two => "two", :three => "tree", :four => "four", :five => "five", :six => "six", :seven => "seven", :eight => "eight" }
      hash_to_locale =   { :one => "uno", :two => "**NOT TRANSLATED** two", :three => "tres", :four => "cuatro", :five => "cinco", :six => "**NOT TRANSLATED** six", :seven => "**NOT TRANSLATED** seven", :eight => "ocho", :puerta => "Puerta"}
      token = "**NOT TRANSLATED**"

      @comparer.coverage_rate(hash_from_locale, hash_to_locale, token).should == "62.50% 5/8 entries translated"
    end

    it 'should return 100.00% in nested hash' do
      @comparer = Transdifflation::Comparer.new
      hash_from_locale = { :house => "house", :street => {:street_name => "street name", :postal => "postal code"}}
      hash_to_locale = { :house => "casa", :street => {:street_name => "Nombre de la calle", :postal => "codigo postal"}}
      token = "**NOT TRANSLATED**"

      @comparer.coverage_rate(hash_from_locale, hash_to_locale, token).should == "100.00% 3/3 entries translated"
    end

    it 'should return 3 entries, 2 translations found' do
      @comparer = Transdifflation::Comparer.new
      hash_from_locale = { :house => "house", :street => {:street_name => "street name", :postal => "postal code"}}
      hash_to_locale = { :house => "casa", :street => {:street_name => "**NOT TRANSLATED** Nombre de la calle", :postal => "codigo postal"}}
      token = "**NOT TRANSLATED**"

      @comparer.coverage_rate(hash_from_locale, hash_to_locale, token).should == "66.67% 2/3 entries translated"
    end

    it 'should return 0.00% in nested hash' do
      @comparer = Transdifflation::Comparer.new
      hash_from_locale = { :street => {:street_name => "**NOT TRANSLATED** Nombre de la calle", :postal => "codigo postal", :number => { :one => "one", :two => "two", :three => "tree"}}}
      hash_to_locale =   { :one => "uno"}
      token = "**NOT TRANSLATED**"

      @comparer.coverage_rate(hash_from_locale, hash_to_locale, token).should == "0.00% 0/5 entries translated"
    end

    it 'should return 10.00% in nested hash' do
      @comparer = Transdifflation::Comparer.new
      hash_from_locale = { :one => "one", :two => "two", :three => "tree", :four => "four", :five => "five", :six => "six", :seven => "seven", :eight => "eight", :nine => "nine", :ten => "ten", :street => {:street_name => "**NOT TRANSLATED** Nombre de la calle", :postal => "codigo postal"}}
      hash_to_locale =   { :one => "uno"}
      token = "**NOT TRANSLATED**"

      @comparer.coverage_rate(hash_from_locale, hash_to_locale, token).should == "8.33% 1/12 entries translated"
    end

    it 'should return 8.33% in nested hash with only one term' do
      @comparer = Transdifflation::Comparer.new
      hash_from_locale = { :one => "one", :two => "two", :three => "tree", :four => "four", :five => "five", :six => "six", :seven => "seven", :eight => "eight", :nine => "nine", :ten => "ten", :street => {:street_name => "Nombre de la calle", :postal => "codigo postal"}}
      hash_to_locale =   { :one => "uno"}
      token = "**NOT TRANSLATED**"

      @comparer.coverage_rate(hash_from_locale, hash_to_locale, token).should == "8.33% 1/12 entries translated"
    end
  end
end
