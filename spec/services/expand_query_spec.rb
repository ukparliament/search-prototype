# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ExpandQuery' do
  let(:expand_query) { ExpandQuery.new(search_query) }

  describe 'extract_terms' do
    let!(:search_query) { "subject:housing subject:\"old houses\" subject:\"houses\" houses \"old houses\" \"houses\"" }

    it 'extracts the individual terms into an array of strings' do
      expect(expand_query.extract_terms).to eq(["subject:housing", "subject:\"old houses\"", "subject:\"houses\"", "houses", "old houses", "houses"])
    end
  end
end
