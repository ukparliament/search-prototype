# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Tokeniser' do
  let(:tokeniser) { Tokeniser.new(query) }

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