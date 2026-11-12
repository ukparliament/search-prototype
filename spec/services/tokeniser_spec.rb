# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Tokeniser' do
  let(:tokeniser) { Tokeniser.new(query) }

  describe 'tokenise' do
    let(:query) { 'test' }

    context 'with a single scan array' do
      let(:terms) { [["term one", "term two", "term three", "term four", "term five", "term six", "term seven", "term eight", "term nine", "term ten", "term eleven", "term twelve", "term thirteen", "term fourteen", "term fifteen"]] }

      before do
        allow(tokeniser).to receive(:terms).and_return(terms)
      end

      it 'returns the tag associated with each term position, along with that term' do
        expect(tokeniser.tokenise).to eq([[:parenthesis, "term one"],
                                          [:boolean_operator, "term two"],
                                          [:modifier_operator, "term three"],
                                          [:all_records, "term four"],
                                          [:url, "term five"],
                                          [:uri_field, "term six"],
                                          [:specified_field_with_quoted_phrase, "term seven"],
                                          [:specified_field_with_quoted_phrase, "term eight"],
                                          [:specified_field_no_expansion, "term nine"],
                                          [:specified_field_wildcard, "term ten"],
                                          [:specified_field, "term eleven"],
                                          [:no_expansion, "term twelve"],
                                          [:quoted_phrase, "term thirteen"],
                                          [:quoted_phrase, "term fourteen"],
                                          [:unquoted_phrase, "term fifteen"]])
      end
    end

    context 'where the scan array includes nil values' do
      let(:terms) { [["term one", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]] }

      before do
        allow(tokeniser).to receive(:terms).and_return(terms)
      end

      it 'returns the tag associated with each term position, but omits nils' do
        expect(tokeniser.tokenise).to eq([[:parenthesis, "term one"]])
      end
    end

    context 'with multiple scan arrays' do
      let(:terms) { [["term one", "term two", "term three", "term four", "term five", "term six", "term seven", "term eight", "term nine", "term ten", "term eleven", "term twelve", "term thirteen", "term fourteen", "term fifteen"], ["term one", "term two", "term three", "term four", "term five", "term six", "term seven", "term eight", "term nine", "term ten", "term eleven", "term twelve", "term thirteen", "term fourteen", "term fifteen"]] }

      before do
        allow(tokeniser).to receive(:terms).and_return(terms)
      end

      it 'returns the tag associated with each term position, along with that term, across all scan arrays' do
        expect(tokeniser.tokenise).to eq([[:parenthesis, "term one"],
                                          [:boolean_operator, "term two"],
                                          [:modifier_operator, "term three"],
                                          [:all_records, "term four"],
                                          [:url, "term five"],
                                          [:uri_field, "term six"],
                                          [:specified_field_with_quoted_phrase, "term seven"],
                                          [:specified_field_with_quoted_phrase, "term eight"],
                                          [:specified_field_no_expansion, "term nine"],
                                          [:specified_field_wildcard, "term ten"],
                                          [:specified_field, "term eleven"],
                                          [:no_expansion, "term twelve"],
                                          [:quoted_phrase, "term thirteen"],
                                          [:quoted_phrase, "term fourteen"],
                                          [:unquoted_phrase, "term fifteen"],
                                          [:parenthesis, "term one"],
                                          [:boolean_operator, "term two"],
                                          [:modifier_operator, "term three"],
                                          [:all_records, "term four"],
                                          [:url, "term five"],
                                          [:uri_field, "term six"],
                                          [:specified_field_with_quoted_phrase, "term seven"],
                                          [:specified_field_with_quoted_phrase, "term eight"],
                                          [:specified_field_no_expansion, "term nine"],
                                          [:specified_field_wildcard, "term ten"],
                                          [:specified_field, "term eleven"],
                                          [:no_expansion, "term twelve"],
                                          [:quoted_phrase, "term thirteen"],
                                          [:quoted_phrase, "term fourteen"],
                                          [:unquoted_phrase, "term fifteen"]])
      end
    end

    context 'with multiple unquoted terms' do
      context 'adjacent unquoted terms' do
        let!(:query) { "cats dogs" }
        it 'combines adjacent unquoted terms into an unquoted phrase' do
          expect(tokeniser.tokenise).to eq([[:unquoted_phrase, "cats dogs"]])
        end
      end

      context 'with a mix of unquoted terms and other term types' do
        let!(:query) { "cats dogs subject:rats pigeons birds" }
        it 'combines adjacent unquoted terms into multiple unquoted phrases' do
          expect(tokeniser.tokenise).to eq([[:unquoted_phrase, "cats dogs"], [:specified_field, "subject:rats"], [:unquoted_phrase, "pigeons birds"]])
        end
      end

      context 'where explicit boolean operators are included' do
        let!(:query) { "cats OR dogs AND subject:rats OR pigeons birds" }
        it 'does not combine unquoted terms separated by operators' do
          expect(tokeniser.tokenise).to eq([[:unquoted_phrase, "cats"], [:boolean_operator, "OR"], [:unquoted_phrase, "dogs"], [:boolean_operator, "AND"], [:specified_field, "subject:rats"], [:boolean_operator, "OR"], [:unquoted_phrase, "pigeons birds"]])
        end
      end

      context 'where modifier operators are included' do
        let!(:query) { "-cats dogs AND subject:rats OR pigeons -birds" }
        it 'does not combine unquoted terms where one is modified by an operator that does not modify the other' do
          expect(tokeniser.tokenise).to eq([[:modifier_operator, "-"], [:unquoted_phrase, "cats"], [:unquoted_phrase, "dogs"], [:boolean_operator, "AND"], [:specified_field, "subject:rats"], [:boolean_operator, "OR"], [:unquoted_phrase, "pigeons"], [:modifier_operator, "-"], [:unquoted_phrase, "birds"]])
        end
      end

      context 'where the NOT operator is used' do
        let!(:query) { "NOT cats dogs AND subject:rats OR pigeons NOT birds" }
        it 'behaves in the same manner as with the - form' do
          expect(tokeniser.tokenise).to eq([[:modifier_operator, "NOT"], [:unquoted_phrase, "cats"], [:unquoted_phrase, "dogs"], [:boolean_operator, "AND"], [:specified_field, "subject:rats"], [:boolean_operator, "OR"], [:unquoted_phrase, "pigeons"], [:modifier_operator, "NOT"], [:unquoted_phrase, "birds"]])
        end
      end

      context 'where the NOT operator is used with the optional AND operator' do
        let!(:query) { "NOT cats dogs AND subject:rats OR pigeons AND NOT birds" }
        it 'includes the AND operator' do
          expect(tokeniser.tokenise).to eq([[:modifier_operator, "NOT"], [:unquoted_phrase, "cats"], [:unquoted_phrase, "dogs"], [:boolean_operator, "AND"], [:specified_field, "subject:rats"], [:boolean_operator, "OR"], [:unquoted_phrase, "pigeons"], [:boolean_operator, "AND"], [:modifier_operator, "NOT"], [:unquoted_phrase, "birds"]])
        end
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
          expect(tokeniser.terms).to eq([[nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "housing"]])
        end
      end

      context 'with brackets' do
        let!(:query) { "()" }

        it 'captures them in the expected bucket' do
          expect(tokeniser.terms).to eq([["(", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
                                         [")", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]])
        end
      end

      context 'with Solr operators' do
        let!(:query) { "AND OR NOT - +" }

        it 'captures them in the expected bucket' do
          expect(tokeniser.terms).to eq([[nil, "AND", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
                                         [nil, "OR", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
                                         [nil, nil, "NOT", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
                                         [nil, nil, "-", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
                                         [nil, nil, "+", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]])
        end
      end

      context 'with urls' do
        let!(:query) { "https://www.google.com" }

        it 'captures them in the expected bucket' do
          expect(tokeniser.terms).to eq([[nil, nil, nil, nil, "https://www.google.com", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]])
        end
      end

      context 'with the *:* selector' do
        let!(:query) { "*:*" }

        it 'captures them in the expected bucket' do
          expect(tokeniser.terms).to eq([[nil, nil, nil, "*:*", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]])
        end
      end

      context 'with the uri field' do
        let!(:query) { "uri:https://www.google.com" }

        it 'captures them in the expected bucket' do
          expect(tokeniser.terms).to eq([[nil, nil, nil, nil, nil, "uri:https://www.google.com", nil, nil, nil, nil, nil, nil, nil, nil, nil]])
        end
      end

      context "with a specified field and a quoted phrase (double quotes)" do
        let!(:query) { "subject:\"cats\"" }

        it 'captures them in the expected bucket' do
          expect(tokeniser.terms).to eq([[nil, nil, nil, nil, nil, nil, "subject:\"cats\"", nil, nil, nil, nil, nil, nil, nil, nil]])
        end
      end

      context "with a specified field and a quoted phrase (single quotes)" do
        let!(:query) { "subject:'cats'" }

        it 'captures them in the expected bucket' do
          expect(tokeniser.terms).to eq([[nil, nil, nil, nil, nil, nil, nil, "subject:'cats'", nil, nil, nil, nil, nil, nil, nil]])
        end
      end

      context "with a specified field and a non-expanded phrase (square brackets)" do
        let!(:query) { "subject:[cats]" }

        it 'captures them in the expected bucket' do
          expect(tokeniser.terms).to eq([[nil, nil, nil, nil, nil, nil, nil, nil, "subject:[cats]", nil, nil, nil, nil, nil, nil]])
        end
      end

      context "with a specified field and a field-exists operator (*)" do
        let!(:query) { "subject:*" }

        it 'captures them in the expected bucket' do
          expect(tokeniser.terms).to eq([[nil, nil, nil, nil, nil, nil, nil, nil, nil, "subject:*", nil, nil, nil, nil, nil]])
        end
      end

      context 'with field queries' do
        let!(:query) { "subject:cats" }

        it 'captures them in the expected bucket' do
          expect(tokeniser.terms).to eq([[nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "subject:cats", nil, nil, nil, nil]])
        end
      end

      context 'with non-expansion brackets around a phrase' do
        let!(:query) { "[cats]" }

        it 'captures them in the expected bucket' do
          expect(tokeniser.terms).to eq([[nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "[cats]", nil, nil, nil]])
        end
      end

      context 'with a quoted phrase (double quotes)' do
        let!(:query) { "\"cats\"" }

        it 'captures them in the expected bucket' do
          expect(tokeniser.terms).to eq([[nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "cats", nil, nil]])
        end
      end

      context 'with a quoted phrase (single quotes)' do
        let!(:query) { "'cats'" }

        it 'captures them in the expected bucket' do
          expect(tokeniser.terms).to eq([[nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "cats", nil]])
        end
      end

      context 'with an unquoted term' do
        let!(:query) { "cats" }

        it 'captures them in the expected bucket' do
          expect(tokeniser.terms).to eq([[nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "cats"]])
        end
      end

      context 'with multiple field scoped terms and unscoped terms' do
        let!(:query) { "subject:housing subject:\"old houses\" subject:\"houses\" houses \"old houses\" \"houses\"" }

        it 'extracts the individual terms into an array of scan result arrays' do
          expect(tokeniser.terms).to eq([[nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "subject:housing", nil, nil, nil, nil],
                                         [nil, nil, nil, nil, nil, nil, "subject:\"old houses\"", nil, nil, nil, nil, nil, nil, nil, nil],
                                         [nil, nil, nil, nil, nil, nil, "subject:\"houses\"", nil, nil, nil, nil, nil, nil, nil, nil],
                                         [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "houses"],
                                         [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "old houses", nil, nil],
                                         [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "houses", nil, nil]])
        end
      end
    end
  end
end