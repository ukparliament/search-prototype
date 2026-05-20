# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Tokeniser' do
  let(:tokeniser) { Tokeniser.new(query) }

  describe 'tokenise' do
    let(:query) { 'test' }

    before do
      allow(tokeniser).to receive(:terms).and_return(terms)
    end

    context 'with a single scan array' do
      let(:terms) { [["term one", "term two", "term three", "term four", "term five", "term six", "term seven", "term eight", "term nine", "term ten", "term eleven", "term twelve"]] }

      it 'returns the tag associated with each term position, along with that term' do
        expect(tokeniser.tokenise).to eq([[:operator, "term one"],
                                          [:url, "term two"],
                                          [:uri_field, "term three"],
                                          [:specified_field_with_quoted_phrase, "term four"],
                                          [:specified_field_with_quoted_phrase, "term five"],
                                          [:specified_field_no_expansion, "term six"],
                                          [:specified_field_wildcard, "term seven"],
                                          [:specified_field, "term eight"],
                                          [:quoted_phrase, "term nine"],
                                          [:quoted_phrase, "term ten"],
                                          [:no_expansion, "term eleven"],
                                          [:unquoted_phrase, "term twelve"]])
      end
    end

    context 'where the scan array includes nil values' do
      let(:terms) { [["term one", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]] }

      it 'returns the tag associated with each term position, but omits nils' do
        expect(tokeniser.tokenise).to eq([[:operator, "term one"]])
      end
    end

    context 'with multiple scan arrays' do
      let(:terms) { [["term one", "term two", "term three", "term four", "term five", "term six", "term seven", "term eight", "term nine", "term ten", "term eleven", "term twelve"], ["term one", "term two", "term three", "term four", "term five", "term six", "term seven", "term eight", "term nine", "term ten", "term eleven", "term twelve"]] }

      it 'returns the tag associated with each term position, along with that term, across all scan arrays' do
        expect(tokeniser.tokenise).to eq([[:operator, "term one"],
                                          [:url, "term two"],
                                          [:uri_field, "term three"],
                                          [:specified_field_with_quoted_phrase, "term four"],
                                          [:specified_field_with_quoted_phrase, "term five"],
                                          [:specified_field_no_expansion, "term six"],
                                          [:specified_field_wildcard, "term seven"],
                                          [:specified_field, "term eight"],
                                          [:quoted_phrase, "term nine"],
                                          [:quoted_phrase, "term ten"],
                                          [:no_expansion, "term eleven"],
                                          [:unquoted_phrase, "term twelve"],
                                          [:operator, "term one"],
                                          [:url, "term two"],
                                          [:uri_field, "term three"],
                                          [:specified_field_with_quoted_phrase, "term four"],
                                          [:specified_field_with_quoted_phrase, "term five"],
                                          [:specified_field_no_expansion, "term six"],
                                          [:specified_field_wildcard, "term seven"],
                                          [:specified_field, "term eight"],
                                          [:quoted_phrase, "term nine"],
                                          [:quoted_phrase, "term ten"],
                                          [:no_expansion, "term eleven"],
                                          [:unquoted_phrase, "term twelve"]])
      end
    end
  end

  describe 'terms' do
    context 'with no search query' do
      let!(:query) {}
      it 'returns nil' do
        expect(tokeniser.terms).to be_nil
      end
    end
    context 'with an empty search query' do
      let!(:query) { "" }

      it 'returns nil' do
        expect(tokeniser.terms).to be_nil
      end
    end
    context 'with a search query' do
      context 'with a single term' do
        let!(:query) { "housing" }

        it 'returns the term in a scan result array' do
          expect(tokeniser.terms).to eq([[nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "housing"]])
        end
      end
      context 'with multiple field scoped terms and unscoped terms' do
        let!(:query) { "subject:housing subject:\"old houses\" subject:\"houses\" houses \"old houses\" \"houses\"" }

        it 'extracts the individual terms into an array of scan result arrays' do
          expect(tokeniser.terms).to eq([[nil, nil, nil, nil, nil, nil, nil, "subject:housing", nil, nil, nil, nil],
                                         [nil, nil, nil, "subject:\"old houses\"", nil, nil, nil, nil, nil, nil, nil, nil],
                                         [nil, nil, nil, "subject:\"houses\"", nil, nil, nil, nil, nil, nil, nil, nil],
                                         [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "houses"],
                                         [nil, nil, nil, nil, nil, nil, nil, nil, nil, "old houses", nil, nil],
                                         [nil, nil, nil, nil, nil, nil, nil, nil, nil, "houses", nil, nil]])
        end
      end
    end
  end
end