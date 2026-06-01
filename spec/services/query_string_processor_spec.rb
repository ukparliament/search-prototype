# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'QueryStringProcessor' do
  let(:query_string_processor) { QueryStringProcessor.new(data) }

  describe 'sequential_combinations'
  context 'when given an array of terms' do
    let(:data) { ["one", "two", "three", "four"] }

    it 'returns every possible sequential combination of one or more words, longest first' do
      expect(query_string_processor.sequential_combinations).to eq(["one two three four", "one two three", "two three four", "one two", "two three", "three four", "one", "two", "three", "four"])
    end
  end

  context 'when given a query string' do
    let(:data) { "one two three four" }

    it 'splits the string on spaces before processing' do
      expect(query_string_processor.sequential_combinations).to eq(["one two three four", "one two three", "two three four", "one two", "two three", "three four", "one", "two", "three", "four"])
    end
  end

  describe 'normalise_quotes' do
    context 'when given an array of terms' do
      let(:data) { ["one", "‘two’", "three’s", "“four”"] }
      it 'raises an error' do
        expect { query_string_processor.normalise_quotes }.to raise_exception.with_message("[\"one\", \"‘two’\", \"three’s\", \"“four”\"] is not a String")
      end
    end
    context 'when given a query string' do
      let(:data) { "one ‘two’ three’s “four”" }
      it 'replaces non ASCII quotes' do
        expect(query_string_processor.normalise_quotes).to eq("one 'two' three's \"four\"")
      end
    end
  end
end
