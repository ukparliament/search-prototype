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
      let(:terms) { [["term one", "term two", "term three", "term four", "term five", "term six", "term seven", "term eight", "term nine", "term ten", "term eleven", "term twelve", "term thirteen", "term fourteen"]] }

      it 'returns the tag associated with each term position, along with that term' do
        expect(tokeniser.tokenise).to eq([[:parenthesis, "term one"],
                                          [:operator, "term two"],
                                          [:all_records, "term three"],
                                          [:url, "term four"],
                                          [:uri_field, "term five"],
                                          [:specified_field_with_quoted_phrase, "term six"],
                                          [:specified_field_with_quoted_phrase, "term seven"],
                                          [:specified_field_no_expansion, "term eight"],
                                          [:specified_field_wildcard, "term nine"],
                                          [:specified_field, "term ten"],
                                          [:no_expansion, "term eleven"],
                                          [:quoted_phrase, "term twelve"],
                                          [:quoted_phrase, "term thirteen"],
                                          [:unquoted_phrase, "term fourteen"]])
      end
    end

    context 'where the scan array includes nil values' do
      let(:terms) { [["term one", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]] }

      it 'returns the tag associated with each term position, but omits nils' do
        expect(tokeniser.tokenise).to eq([[:parenthesis, "term one"]])
      end
    end

    context 'with multiple scan arrays' do
      let(:terms) { [["term one", "term two", "term three", "term four", "term five", "term six", "term seven", "term eight", "term nine", "term ten", "term eleven", "term twelve", "term thirteen", "term fourteen"], ["term one", "term two", "term three", "term four", "term five", "term six", "term seven", "term eight", "term nine", "term ten", "term eleven", "term twelve", "term thirteen", "term fourteen"]] }

      it 'returns the tag associated with each term position, along with that term, across all scan arrays' do
        expect(tokeniser.tokenise).to eq([[:parenthesis, "term one"],
                                          [:operator, "term two"],
                                          [:all_records, "term three"],
                                          [:url, "term four"],
                                          [:uri_field, "term five"],
                                          [:specified_field_with_quoted_phrase, "term six"],
                                          [:specified_field_with_quoted_phrase, "term seven"],
                                          [:specified_field_no_expansion, "term eight"],
                                          [:specified_field_wildcard, "term nine"],
                                          [:specified_field, "term ten"],
                                          [:no_expansion, "term eleven"],
                                          [:quoted_phrase, "term twelve"],
                                          [:quoted_phrase, "term thirteen"],
                                          [:unquoted_phrase, "term fourteen"],
                                          [:parenthesis, "term one"],
                                          [:operator, "term two"],
                                          [:all_records, "term three"],
                                          [:url, "term four"],
                                          [:uri_field, "term five"],
                                          [:specified_field_with_quoted_phrase, "term six"],
                                          [:specified_field_with_quoted_phrase, "term seven"],
                                          [:specified_field_no_expansion, "term eight"],
                                          [:specified_field_wildcard, "term nine"],
                                          [:specified_field, "term ten"],
                                          [:no_expansion, "term eleven"],
                                          [:quoted_phrase, "term twelve"],
                                          [:quoted_phrase, "term thirteen"],
                                          [:unquoted_phrase, "term fourteen"]])
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
          expect(tokeniser.terms).to eq([[nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "housing"]])
        end
      end

      context 'with brackets' do
        let!(:query) { "()" }

        it 'captures them in the expected bucket' do
          expect(tokeniser.terms).to eq([["(", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
                                         [")", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]])
        end
      end

      context 'with Solr operators' do
        let!(:query) { "AND OR NOT" }

        it 'captures them in the expected bucket' do
          expect(tokeniser.terms).to eq([[nil, "AND", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
                                         [nil, "OR", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
                                         [nil, "NOT", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]])
        end
      end

      context 'with urls' do
        let!(:query) { "https://www.google.com" }

        it 'captures them in the expected bucket' do
          expect(tokeniser.terms).to eq([[nil, nil, nil, "https://www.google.com", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]])
        end
      end

      context 'with the *:* selector' do
        let!(:query) { "*:*" }

        it 'captures them in the expected bucket' do
          expect(tokeniser.terms).to eq([[nil, nil, "*:*", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]])
        end
      end

      context 'with the uri field' do
        let!(:query) { "uri:https://www.google.com" }

        it 'captures them in the expected bucket' do
          expect(tokeniser.terms).to eq([[nil, nil, nil, nil, "uri:https://www.google.com", nil, nil, nil, nil, nil, nil, nil, nil, nil]])
        end
      end

      context "with a specified field and a quoted phrase (double quotes)" do
        let!(:query) { "subject:\"cats\"" }

        it 'captures them in the expected bucket' do
          expect(tokeniser.terms).to eq([[nil, nil, nil, nil, nil, "subject:\"cats\"", nil, nil, nil, nil, nil, nil, nil, nil]])
        end
      end

      context "with a specified field and a quoted phrase (single quotes)" do
        let!(:query) { "subject:'cats'" }

        it 'captures them in the expected bucket' do
          expect(tokeniser.terms).to eq([[nil, nil, nil, nil, nil, nil, "subject:'cats'", nil, nil, nil, nil, nil, nil, nil]])
        end
      end

      context "with a specified field and a non-expanded phrase (square brackets)" do
        let!(:query) { "subject:[cats]" }

        it 'captures them in the expected bucket' do
          expect(tokeniser.terms).to eq([[nil, nil, nil, nil, nil, nil, nil, "subject:[cats]", nil, nil, nil, nil, nil, nil]])
        end
      end

      context "with a specified field and a field-exists operator (*)" do
        let!(:query) { "subject:*" }

        it 'captures them in the expected bucket' do
          expect(tokeniser.terms).to eq([[nil, nil, nil, nil, nil, nil, nil, nil, "subject:*", nil, nil, nil, nil, nil]])
        end
      end

      context 'with field queries' do
        let!(:query) { "subject:cats" }

        it 'captures them in the expected bucket' do
          expect(tokeniser.terms).to eq([[nil, nil, nil, nil, nil, nil, nil, nil, nil, "subject:cats", nil, nil, nil, nil]])
        end
      end

      context 'with non-expansion brackets around a phrase' do
        let!(:query) { "[cats]" }

        it 'captures them in the expected bucket' do
          expect(tokeniser.terms).to eq([[nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "[cats]", nil, nil, nil]])
        end
      end

      context 'with a quoted phrase (double quotes)' do
        let!(:query) { "\"cats\"" }

        it 'captures them in the expected bucket' do
          expect(tokeniser.terms).to eq([[nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "cats", nil, nil]])
        end
      end

      context 'with a quoted phrase (double quotes)' do
        let!(:query) { "'cats'" }

        it 'captures them in the expected bucket' do
          expect(tokeniser.terms).to eq([[nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "cats", nil]])
        end
      end

      context 'with an unquoted term' do
        let!(:query) { "cats" }

        it 'captures them in the expected bucket' do
          expect(tokeniser.terms).to eq([[nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "cats"]])
        end
      end

      context 'with multiple field scoped terms and unscoped terms' do
        let!(:query) { "subject:housing subject:\"old houses\" subject:\"houses\" houses \"old houses\" \"houses\"" }

        it 'extracts the individual terms into an array of scan result arrays' do
          expect(tokeniser.terms).to eq([[nil, nil, nil, nil, nil, nil, nil, nil, nil, "subject:housing", nil, nil, nil, nil],
                                         [nil, nil, nil, nil, nil, "subject:\"old houses\"", nil, nil, nil, nil, nil, nil, nil, nil],
                                         [nil, nil, nil, nil, nil, "subject:\"houses\"", nil, nil, nil, nil, nil, nil, nil, nil],
                                         [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "houses"],
                                         [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "old houses", nil, nil],
                                         [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "houses", nil, nil]])
        end
      end
    end
  end
end