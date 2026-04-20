# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Tokeniser' do
  let(:tokeniser) { Tokeniser.new(query) }

  describe 'tokenise' do
    let(:query) { 'test' }

    before do
      allow(tokeniser).to receive(:terms).and_return(terms)
    end

    context 'with a Solr operator' do
      let(:terms) { ["OR"] }
      it 'tags as an operator token' do
        expect(tokeniser.tokenise).to eq([[:operator, "OR"]])
      end
    end

    context 'with an http url' do
      let(:terms) { ["http://example.com"] }
      it 'tags as a url' do
        expect(tokeniser.tokenise).to eq([[:url, "http://example.com"]])
      end
    end

    context 'with a specified field' do
      let(:terms) { ["subject:cats"] }
      it 'tags as a specified field' do
        expect(tokeniser.tokenise).to eq([[:specified_field, "subject:cats"]])
      end
    end

    context 'with a specified field with quotes' do
      let(:terms) { ["subject:\"cats protection\""] }
      it 'tags as a specified field with quoted phrase' do
        expect(tokeniser.tokenise).to eq([[:specified_field_with_quoted_phrase, "subject:\"cats protection\""]])
      end
    end

    context 'with a quoted phrase' do
      let(:terms) { ["\"cats protection\""] }
      it 'tags as a quoted phrase' do
        expect(tokeniser.tokenise).to eq([[:quoted_phrase, "\"cats protection\""]])
      end
    end

    context 'with an unquoted term' do
      let(:terms) { ['cat'] }

      it 'tags it as an unquoted phrase' do
        expect(tokeniser.tokenise).to eq([[:unquoted_phrase, "cat"]])
      end
    end

    context 'with multiple sequential unquoted terms' do
      let(:terms) { ['cat', 'dog'] }

      it 'tags it as an unquoted phrase, with the terms returned in a single string' do
        expect(tokeniser.tokenise).to eq([[:unquoted_phrase, "cat dog"]])
      end
    end

    context 'with non-sequential unquoted terms' do
      let(:terms) { ['cat', 'subject:welfare', 'dog', 'chicken'] }

      it 'tags it as an unquoted phrase, non-sequential terms returned as separate tokens' do
        expect(tokeniser.tokenise).to eq([[:unquoted_phrase, "cat"], [:specified_field, "subject:welfare"], [:unquoted_phrase, "dog chicken"]])
      end
    end

    context 'with square brackets' do
      let(:terms) { ['[cat]'] }

      it 'tags it as no expansion' do
        expect(tokeniser.tokenise).to eq([[:no_expansion, "[cat]"]])
      end
    end

    context 'with a field name and square brackets' do
      let(:terms) { ['subject:[cats]'] }
      it 'tags it as specified field no expansion' do
        expect(tokeniser.tokenise).to eq([[:specified_field_no_expansion, "subject:[cats]"]])
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

        it 'returns the term in an array' do
          expect(tokeniser.terms).to eq(["housing"])
        end
      end
      context 'with multiple field scoped terms and unscoped terms' do
        let!(:query) { "subject:housing subject:\"old houses\" subject:\"houses\" houses \"old houses\" \"houses\"" }

        it 'extracts the individual terms into an array of strings' do
          expect(tokeniser.terms).to eq(["subject:housing", "subject:\"old houses\"", "subject:\"houses\"", "houses", "old houses", "houses"])
        end
      end
    end
  end
end