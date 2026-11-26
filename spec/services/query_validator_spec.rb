# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'QueryValidator' do
  let!(:query_validator) { QueryValidator.new(tokens) }

  context 'with a valid query' do
    let!(:tokens) { [QueryToken.new(type: :specified_field, value: "procedural:(\"New"), QueryToken.new(type: :unquoted_phrase, value: "clauses"), QueryToken.new(type: :quoted_phrase, value: " AND "), QueryToken.new(type: :unquoted_phrase, value: "New schedules"), QueryToken.new(type: :closing_parenthesis, value: ")")] }
    it 'returns the tokens unaltered' do
      expect(query_validator.validate).to eq(tokens)
    end
  end

  context 'with an invalid query' do
    let!(:tokens) { [QueryToken.new(type: :specified_field, value: "procedural:(\"New"), QueryToken.new(type: :unquoted_phrase, value: "clauses")] }
    it 'returns the errors' do
      expect(query_validator.validate).to eq('errors')
    end
  end
end