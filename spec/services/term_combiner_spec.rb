# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TermCombiner, type: :model do
  let(:term_combiner) { TermCombiner.new(terms) }

  context 'simple terms and user provided operators' do
    let(:terms) { ['fish', 'OR', 'chips'] }
    it 'combines into a query string' do
      expect(term_combiner.combine_terms).to eq("fish OR chips")
    end
  end
  context 'with multiple consecutive user provided operators' do
    let(:terms) { ['fish', 'AND', 'NOT', 'chips'] }
    it 'combines into a query string' do
      expect(term_combiner.combine_terms).to eq("fish AND NOT chips")
    end
  end
  context 'where no operators are provided by the user' do
    let(:terms) { ['fish', 'chips'] }
    it 'combines into a query string' do
      expect(term_combiner.combine_terms).to eq("fish AND chips")
    end
  end
end
