require 'spec_helper'
require 'transdifflation'

describe :lost_in_translation do

  before (:each) do
    @comparer = Transdifflation::Comparer.new
  end

  describe :inner_functionallity do
    it 'should return no differences with same data' do
      i18n = { :es => {:one_key => 'uno', :another_key => 'dos'} }
      @comparer.get_rest_of_translation(i18n, i18n, :es, :es).should eql({})
    end

    it 'should return differences with different data' do
      i18n_en = { :en => {:one_key => 'one', :another_key => 'another', :another_one => 'another_one_even'} }
      i18n_es = { :es => {:one_key => 'uno', :another_key => 'dos'} }
      @comparer.get_rest_of_translation(i18n_en, i18n_es, :en, :es).should eql( {"es" => {"another_one" => "another_one_even" }} )
    end

    it 'should return no differences if target has more info than source' do
      i18n_en = { :en => {:one_key => 'one', :another_key => 'another'} }
      i18n_es = { :es => {:one_key => 'uno', :another_key => 'dos', :another_one => 'tres'} }
      @comparer.get_rest_of_translation(i18n_en, i18n_es, :en, :es).should eql({})
    end
  end
end
