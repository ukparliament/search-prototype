require 'rails_helper'

RSpec.describe FacetHelper, type: :helper do
  ##
  # This will need @search_data.filter_groups (or rather, one of those, as we grab it using the name when passing into this helper method)

  describe 'format_filter_group' do
    let!(:house) { [{ "val" => 25259, "count" => 70, "field_name" => "legislature_ses" }, { "val" => 25277, "count" => 15, "field_name" => "legislature_ses" }] }
    let!(:month) { [{ "val" => 11, "count" => 86, "field_name" => "date_month" }, { "val" => 3, "count" => 70, "field_name" => "date_month" }, { "val" => 5, "count" => 50, "field_name" => "date_month" }] }
    let!(:ordered_month) { [{ "val" => 3, "count" => 70, "field_name" => "date_month" }, { "val" => 5, "count" => 50, "field_name" => "date_month" }, { "val" => 11, "count" => 86, "field_name" => "date_month" }] }
    let!(:selected_month) { [{ "val" => 5, "count" => 50, "field_name" => "date_month" }] }
    let!(:year) { [{ "val" => 2013, "count" => 139, "field_name" => "date_year" }, { "val" => 2011, "count" => 92, "field_name" => "date_year" }, { "val" => 2016, "count" => 144, "field_name" => "date_year" }] }
    let!(:ordered_year) { [{ "val" => 2016, "count" => 144, "field_name" => "date_year" }, { "val" => 2013, "count" => 139, "field_name" => "date_year" }, { "val" => 2011, "count" => 92, "field_name" => "date_year" }] }
    let!(:session) { [{ "val" => "2004-05", "count" => 48, "field_name" => "session_s" }, { "val" => "1996-97", "count" => 40, "field_name" => "session_s" }, { "val" => "2019-19", "count" => 40, "field_name" => "session_s" }] }
    let!(:ordered_session) { [{ "val" => "2019-19", "count" => 40, "field_name" => "session_s" }, { "val" => "2004-05", "count" => 48, "field_name" => "session_s" }, { "val" => "1996-97", "count" => 40, "field_name" => "session_s" }] }

    context 'where facet is of a type not requiring formatting' do
      it 'returns the input data without change' do
        expect(helper.format_filter_group("House", house)).to eq(house)
      end
    end

    context 'for the month facet' do
      context 'without a matching value provided' do
        # this is where the user has selected a year but not a month, so we're still displaying all options
        it 'returns the input data with the months ordered by number' do
          expect(helper.format_filter_group("Month", month)).to eq(ordered_month)
        end
        context 'where a matching value is provided' do
          # this is where the user has selected a month, so we're filtering out all others
          it 'returns only the matching value from the input data' do
            expect(helper.format_filter_group("Month", month, matching_value: "5")).to eq(selected_month)
          end
        end
      end
    end

    context 'for the year facet' do
      it 'returns the input data with the year ordered by recency' do
        expect(helper.format_filter_group("Year", year)).to eq(ordered_year)
      end
    end

    context 'for the session facet' do
      it 'returns the input data with the sessions ordered by recency' do
        expect(helper.format_filter_group("Session", session)).to eq(ordered_session)
      end
    end
  end
end
