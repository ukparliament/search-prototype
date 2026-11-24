# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Tokeniser' do
  let(:tokeniser) { Tokeniser.new(query) }

  describe 'tokenise' do
    let(:query) { 'test' }
    let!(:position_zero_token) { QueryToken.new(type: :opening_parenthesis, value: 'zero') }
    let!(:position_one_token) { QueryToken.new(type: :closing_parenthesis, value: 'one') }
    let!(:position_two_token) { QueryToken.new(type: :boolean_operator, value: 'two') }
    let!(:position_three_token) { QueryToken.new(type: :modifier_operator, value: 'three') }
    let!(:position_four_token) { QueryToken.new(type: :all_records, value: 'four') }
    let!(:position_five_token) { QueryToken.new(type: :url, value: 'five') }
    let!(:position_six_token) { QueryToken.new(type: :uri_field, value: 'six') }
    let!(:position_seven_token) { QueryToken.new(type: :specified_field_with_quoted_phrase, value: 'seven') }
    let!(:position_eight_token) { QueryToken.new(type: :specified_field_with_quoted_phrase, value: 'eight') }
    let!(:position_nine_token) { QueryToken.new(type: :specified_field_no_expansion, value: 'nine') }
    let!(:position_ten_token) { QueryToken.new(type: :specified_field_wildcard, value: 'ten') }
    let!(:position_eleven_token) { QueryToken.new(type: :specified_field, value: 'eleven') }
    let!(:position_twelve_token) { QueryToken.new(type: :no_expansion, value: 'twelve') }
    let!(:position_thirteen_token) { QueryToken.new(type: :opening_bracket, value: 'thirteen') }
    let!(:position_fourteen_token) { QueryToken.new(type: :closing_bracket, value: 'fourteen') }
    let!(:position_fifteen_token) { QueryToken.new(type: :quoted_phrase, value: 'fifteen') }
    let!(:position_sixteen_token) { QueryToken.new(type: :quoted_phrase, value: 'sixteen') }
    let!(:position_seventeen_token) { QueryToken.new(type: :unquoted_word, value: 'seventeen') }

    context 'with a single scan array' do
      let(:terms) { [["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen"]] }

      before do
        allow(tokeniser).to receive(:terms).and_return(terms)
      end

      it 'returns the token associated with each term position' do
        expect(tokeniser.tokenise).to eq([
                                           position_zero_token,
                                           position_one_token,
                                           position_two_token,
                                           position_three_token,
                                           position_four_token,
                                           position_five_token,
                                           position_six_token,
                                           position_seven_token,
                                           position_eight_token,
                                           position_nine_token,
                                           position_ten_token,
                                           position_eleven_token,
                                           position_twelve_token,
                                           position_thirteen_token,
                                           position_fourteen_token,
                                           position_fifteen_token,
                                           position_sixteen_token,
                                           position_seventeen_token
                                         ])
      end
    end

    context 'where the scan array includes nil values' do
      let(:terms) { [["zero", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]] }

      before do
        allow(tokeniser).to receive(:terms).and_return(terms)
      end

      it 'returns the tag associated with each term position, but omits nils' do
        expect(tokeniser.tokenise).to eq([position_zero_token])
      end
    end

    context 'with multiple scan arrays' do
      let(:terms) { [["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen"], ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen"]] }

      before do
        allow(tokeniser).to receive(:terms).and_return(terms)
      end

      it 'returns the tag associated with each term position, along with that term, across all scan arrays' do
        expect(tokeniser.tokenise).to eq([position_zero_token,
                                          position_one_token,
                                          position_two_token,
                                          position_three_token,
                                          position_four_token,
                                          position_five_token,
                                          position_six_token,
                                          position_seven_token,
                                          position_eight_token,
                                          position_nine_token,
                                          position_ten_token,
                                          position_eleven_token,
                                          position_twelve_token,
                                          position_thirteen_token,
                                          position_fourteen_token,
                                          position_fifteen_token,
                                          position_sixteen_token,
                                          position_seventeen_token,
                                          position_zero_token,
                                          position_one_token,
                                          position_two_token,
                                          position_three_token,
                                          position_four_token,
                                          position_five_token,
                                          position_six_token,
                                          position_seven_token,
                                          position_eight_token,
                                          position_nine_token,
                                          position_ten_token,
                                          position_eleven_token,
                                          position_twelve_token,
                                          position_thirteen_token,
                                          position_fourteen_token,
                                          position_fifteen_token,
                                          position_sixteen_token,
                                          position_seventeen_token
                                         ])
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
          expect(tokeniser.terms).to eq([[nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "housing"]])
        end
      end

      context 'with brackets' do
        let!(:query) { "()[]" }

        it 'captures them in the expected bucket' do
          expect(tokeniser.terms).to eq([["(", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
                                         [nil, ")", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
                                         [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "[", nil, nil, nil, nil],
                                         [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "]", nil, nil, nil]])
        end
      end

      context 'with Solr operators' do
        let!(:query) { "AND OR NOT - +" }

        it 'captures them in the expected bucket' do
          expect(tokeniser.terms).to eq([[nil, nil, "AND", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
                                         [nil, nil, "OR", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
                                         [nil, nil, nil, "NOT", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
                                         [nil, nil, nil, "-", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
                                         [nil, nil, nil, "+", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]])
        end
      end

      context 'with urls' do
        let!(:query) { "https://www.google.com" }

        it 'captures them in the expected bucket' do
          expect(tokeniser.terms).to eq([[nil, nil, nil, nil, nil, "https://www.google.com", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]])
        end
      end

      context 'with the *:* selector' do
        let!(:query) { "*:*" }

        it 'captures them in the expected bucket' do
          expect(tokeniser.terms).to eq([[nil, nil, nil, nil, "*:*", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]])
        end
      end

      context 'with the uri field' do
        let!(:query) { "uri:https://www.google.com" }

        it 'captures them in the expected bucket' do
          expect(tokeniser.terms).to eq([[nil, nil, nil, nil, nil, nil, "uri:https://www.google.com", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]])
        end
      end

      context "with a specified field and a quoted phrase (double quotes)" do
        let!(:query) { "subject:\"cats\"" }

        it 'captures them in the expected bucket' do
          expect(tokeniser.terms).to eq([[nil, nil, nil, nil, nil, nil, nil, "subject:\"cats\"", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]])
        end
      end

      context "with a specified field and a quoted phrase (single quotes)" do
        let!(:query) { "subject:'cats'" }

        it 'captures them in the expected bucket' do
          expect(tokeniser.terms).to eq([[nil, nil, nil, nil, nil, nil, nil, nil, "subject:'cats'", nil, nil, nil, nil, nil, nil, nil, nil, nil]])
        end
      end

      context "with a specified field and a non-expanded phrase (square brackets)" do
        let!(:query) { "subject:[cats]" }

        it 'captures them in the expected bucket' do
          expect(tokeniser.terms).to eq([[nil, nil, nil, nil, nil, nil, nil, nil, nil, "subject:[cats]", nil, nil, nil, nil, nil, nil, nil, nil]])
        end
      end

      context "with a specified field and a field-exists operator (*)" do
        let!(:query) { "subject:*" }

        it 'captures them in the expected bucket' do
          expect(tokeniser.terms).to eq([[nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "subject:*", nil, nil, nil, nil, nil, nil, nil]])
        end
      end

      context 'with field queries' do
        let!(:query) { "subject:cats" }

        it 'captures them in the expected bucket' do
          expect(tokeniser.terms).to eq([[nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "subject:cats", nil, nil, nil, nil, nil, nil]])
        end
      end

      context 'with non-expansion brackets around a word' do
        let!(:query) { "[cats]" }

        it 'captures them in the expected bucket' do
          expect(tokeniser.terms).to eq([[nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "[cats]", nil, nil, nil, nil, nil]])
        end
      end

      context 'with non-expansion brackets around a phrase' do
        let!(:query) { "[big cats]" }

        it 'captures them in the expected bucket' do
          expect(tokeniser.terms).to eq([[nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "[big cats]", nil, nil, nil, nil, nil]])
        end
      end

      context 'with a quoted phrase (double quotes)' do
        let!(:query) { "\"cats\"" }

        it 'captures them in the expected bucket' do
          expect(tokeniser.terms).to eq([[nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "cats", nil, nil]])
        end
      end

      context 'with a quoted phrase (single quotes)' do
        let!(:query) { "'cats'" }

        it 'captures them in the expected bucket' do
          expect(tokeniser.terms).to eq([[nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "cats", nil]])
        end
      end

      context 'with an unquoted term' do
        let!(:query) { "cats" }

        it 'captures them in the expected bucket' do
          expect(tokeniser.terms).to eq([[nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "cats"]])
        end
      end

      context 'with multiple field scoped terms and unscoped terms' do
        let!(:query) { "subject:housing subject:\"old houses\" subject:\"houses\" houses \"old houses\" \"houses\"" }

        it 'extracts the individual terms into an array of scan result arrays' do
          expect(tokeniser.terms).to eq([[nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "subject:housing", nil, nil, nil, nil, nil, nil],
                                         [nil, nil, nil, nil, nil, nil, nil, "subject:\"old houses\"", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
                                         [nil, nil, nil, nil, nil, nil, nil, "subject:\"houses\"", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
                                         [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "houses"],
                                         [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "old houses", nil, nil],
                                         [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "houses", nil, nil]])
        end
      end
    end
  end
end