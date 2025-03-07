require 'rails_helper'

RSpec.describe FacetHelper, type: :helper do
  describe 'format_facets' do

    let!(:legislature_facet) { { :field_name => "legislature_ses", :facets => [{ "val" => 25277, "count" => 55 }] } }
    let!(:month_facet) { { :field_name => "date_month", :facets => [{ "val" => 6, "count" => 33 }, { "val" => 7, "count" => 14 }, { "val" => 1, "count" => 4 }, { "val" => 12, "count" => 3 }, { "val" => 3, "count" => 1 }] } }
    let!(:ordered_month_facet) { { :field_name => "date_month", :facets => [{ "val" => 1, "count" => 4 }, { "val" => 3, "count" => 1 }, { "val" => 6, "count" => 33 }, { "val" => 7, "count" => 14 }, { "val" => 12, "count" => 3 }] } }
    let!(:year_facet) { { :field_name => "date_year", :facets => [{ "val" => 2015, "count" => 51 }, { "val" => 2016, "count" => 4 }] } }
    let!(:ordered_year_facet) { { :field_name => "date_year", :facets => [{ "val" => 2016, "count" => 4 }, { "val" => 2015, "count" => 51 }] } }

    context 'where facet is of a type not requiring formatting' do
      it 'returns the input data without change' do
        expect(helper.format_facets(legislature_facet)).to eq(legislature_facet)
      end
    end

    context 'for the month facet' do
      it 'returns the input data with the months ordered by number' do
        expect(helper.format_facets(month_facet)).to eq(ordered_month_facet)
      end
    end

    context 'for the year facet' do
      it 'returns the input data with the year ordered by recency' do
        expect(helper.format_facets(year_facet)).to eq(ordered_year_facet)
      end
    end
  end
end
