# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'TermExpander' do
  let(:term_expander) { TermExpander.new(expanded_fields, ses_data, search_term) }
  let!(:ses_data) { [{ equivalent_terms: [["Accommodation", "Houses"]], preferred_term_id: "91569", preferred_term: "Housing", topic_id: "95629" }] }
  let!(:search_term) { 'housing' }
  let!(:expanded_fields) { { "boolean_fields" => [],
                             "date_fields" => [],
                             "non_aliased_fields" => ["field1", "field2"],
                             "ses_fields" => [],
                             "ses_id_fields" => [],
                             "text_fields" => [] } }

  describe 'expand_terms' do
    context 'there are non-aliased fields' do
      it 'calls handle_non_aliased_terms' do
        allow(term_expander).to receive(:handle_non_aliased_terms)
        term_expander.expand_terms
        expect(term_expander).to have_received(:handle_non_aliased_terms).with(["field1", "field2"], ses_data, search_term).once
      end
    end

    context 'there are text fields' do
      let!(:expanded_fields) { { "boolean_fields" => [],
                                 "date_fields" => [],
                                 "non_aliased_fields" => [],
                                 "ses_fields" => [],
                                 "ses_id_fields" => [],
                                 "text_fields" => ["field1", "field2"] } }
      it 'calls handle_non_aliased_terms' do
        allow(term_expander).to receive(:populate_text_fields)
        term_expander.expand_terms
        expect(term_expander).to have_received(:populate_text_fields).with(["field1", "field2"], ses_data, search_term).once
      end
    end

    context 'there are ses_id fields' do
      let!(:expanded_fields) { { "boolean_fields" => [],
                                 "date_fields" => [],
                                 "non_aliased_fields" => [],
                                 "ses_fields" => [],
                                 "ses_id_fields" => ["field1", "field2"],
                                 "text_fields" => [] } }
      it 'calls handle_non_aliased_terms' do
        allow(term_expander).to receive(:populate_ses_id_fields)
        term_expander.expand_terms
        expect(term_expander).to have_received(:populate_ses_id_fields).with(["field1", "field2"], search_term).once
      end
    end

    context 'there are boolean fields' do
      let!(:expanded_fields) { { "boolean_fields" => ["field1", "field2"],
                                 "date_fields" => [],
                                 "non_aliased_fields" => [],
                                 "ses_fields" => [],
                                 "ses_id_fields" => [],
                                 "text_fields" => [] } }
      it 'calls handle_non_aliased_terms' do
        allow(term_expander).to receive(:populate_boolean_fields)
        term_expander.expand_terms
        expect(term_expander).to have_received(:populate_boolean_fields).with(["field1", "field2"], search_term).once
      end
    end

    context 'there are date fields' do
      let!(:expanded_fields) { { "boolean_fields" => [],
                                 "date_fields" => ["field1", "field2"],
                                 "non_aliased_fields" => [],
                                 "ses_fields" => [],
                                 "ses_id_fields" => [],
                                 "text_fields" => [] } }
      it 'calls handle_non_aliased_terms' do
        allow(term_expander).to receive(:populate_date_fields)
        term_expander.expand_terms
        expect(term_expander).to have_received(:populate_date_fields).with(["field1", "field2"], search_term).once
      end
    end

    context 'there are ses fields' do
      let!(:expanded_fields) { { "boolean_fields" => [],
                                 "date_fields" => [],
                                 "non_aliased_fields" => [],
                                 "ses_fields" => ["field1", "field2"],
                                 "ses_id_fields" => [],
                                 "text_fields" => [] } }
      it 'calls handle_non_aliased_terms' do
        allow(term_expander).to receive(:populate_ses_fields)
        term_expander.expand_terms
        expect(term_expander).to have_received(:populate_ses_fields).with(["field1", "field2"], ses_data).once
      end
    end

    context 'multiple terms are generated' do
      let!(:expanded_fields) { { "boolean_fields" => [],
                                 "date_fields" => [],
                                 "non_aliased_fields" => [],
                                 "ses_fields" => ["field1", "field2"],
                                 "ses_id_fields" => [],
                                 "text_fields" => [] } }
      it 'flattens and joins terms with OR' do
        expect(term_expander.expand_terms).to eq("field1:91569 OR field2:91569")
      end
    end
  end

  describe 'populate_text_fields' do
    let!(:text_fields) { ['department_t'] }

    context 'where there is a preferred term' do
      let!(:ses_data) { [{ equivalent_terms: [["Accommodation", "Houses"]], preferred_term_id: "91569", preferred_term: "Housing", topic_id: "95629" }] }

      it 'returns a search for preferred term and any equivalent terms' do
        expect(term_expander.populate_text_fields(text_fields, ses_data, 'house')).to eq(["department_t:\"Housing\"", "department_t:\"Accommodation\"", "department_t:\"Houses\""])
      end
    end
    context 'where there is no preferred term' do
      let!(:ses_data) { [{ equivalent_terms: [["Accommodation", "Houses"]], preferred_term_id: "91569", topic_id: "95629" }] }

      it 'returns a search for the search term and any equivalent terms' do
        expect(term_expander.populate_text_fields(text_fields, ses_data, 'house')).to eq(["department_t:\"house\"", "department_t:\"Accommodation\"", "department_t:\"Houses\""])
      end
    end
  end

  describe 'populate_ses_id_fields' do
    let!(:ses_id_fields) { ['subject_ses'] }
    it 'returns a search across those fields for the search term' do
      expect(term_expander.populate_ses_id_fields(ses_id_fields, 91569)).to eq(["subject_ses:91569"])
    end
  end

  describe 'populate_boolean_fields' do
    let!(:boolean_fields) { ["containsEM_b"] }

    context 'where the user searches for a "true" equivalent' do
      it 'returns a search string for 1' do
        expect(term_expander.populate_boolean_fields(boolean_fields, "true")).to eq(["containsEM_b:1"])
        expect(term_expander.populate_boolean_fields(boolean_fields, "yes")).to eq(["containsEM_b:1"])
        expect(term_expander.populate_boolean_fields(boolean_fields, "y")).to eq(["containsEM_b:1"])
        expect(term_expander.populate_boolean_fields(boolean_fields, "1")).to eq(["containsEM_b:1"])
      end
    end

    context 'where the user searches for a "false" equivalent' do
      it 'returns a search string for 1' do
        expect(term_expander.populate_boolean_fields(boolean_fields, "false")).to eq(["containsEM_b:0"])
        expect(term_expander.populate_boolean_fields(boolean_fields, "no")).to eq(["containsEM_b:0"])
        expect(term_expander.populate_boolean_fields(boolean_fields, "n")).to eq(["containsEM_b:0"])
        expect(term_expander.populate_boolean_fields(boolean_fields, "0")).to eq(["containsEM_b:0"])
      end
    end
  end

  describe 'populate_date_fields' do
    let!(:search_today) { "today" }
    let!(:search_yesterday) { "yesterday" }
    let!(:search_this_week) { "thisweek" }
    let!(:search_last_week) { "lastweek" }
    let!(:search_this_month) { "thismonth" }
    let!(:search_last_month) { "lastmonth" }
    let!(:search_this_year) { "thisyear" }
    let!(:search_last_year) { "lastyear" }

    context 'with a single date field' do
      let!(:date_fields) { ["date_dt"] }

      it "searches the provided date field for the relevant date range" do
        expect(term_expander.populate_date_fields(date_fields, search_today)).to eq ["date_dt:NOW/DAY"]
        expect(term_expander.populate_date_fields(date_fields, search_yesterday)).to eq ["date_dt:NOW/DAY-1DAY"]
        expect(term_expander.populate_date_fields(date_fields, search_this_week)).to eq ["date_dt:[NOW/WEEK TO NOW/WEEK+6DAYS]"]
        expect(term_expander.populate_date_fields(date_fields, search_last_week)).to eq ["date_dt:[NOW/WEEK-1WEEK TO NOW/WEEK-1DAY]"]
        expect(term_expander.populate_date_fields(date_fields, search_this_month)).to eq ["date_dt:[NOW/MONTH TO NOW/MONTH+1MONTH-1MILLISECOND]"]
        expect(term_expander.populate_date_fields(date_fields, search_last_month)).to eq ["date_dt:[NOW/MONTH-1MONTH TO NOW/MONTH-1MILLISECOND]"]
        expect(term_expander.populate_date_fields(date_fields, search_this_year)).to eq ["date_dt:[NOW/YEAR TO NOW/YEAR+1YEAR-1MILLISECOND]"]
        expect(term_expander.populate_date_fields(date_fields, search_last_year)).to eq ["date_dt:[NOW/YEAR-1YEAR TO NOW/YEAR-1MILLISECOND]"]
      end
    end
    context 'with multiple date fields' do
      let!(:date_fields) { ["dateCertified_dt", "certifiedDate_dt"] }

      it "applies the search across all provided date fields" do
        expect(term_expander.populate_date_fields(date_fields, search_today)).to eq ["dateCertified_dt:NOW/DAY", "certifiedDate_dt:NOW/DAY"]
      end
    end
  end

  describe 'handle_non_aliased_terms' do
    let!(:non_aliased_fields) { ["none"] }
    let!(:search_term) { "house" }

    context 'where there is a preferred term' do
      # ses_data is generated by the .data method of SesQuery
      let!(:ses_data) { [{ equivalent_terms: [["Accommodation", "Houses"]], preferred_term_id: "91569", preferred_term: "Housing", topic_id: "95629" }] }

      it 'returns the preferred term and equivalent terms' do
        expect(term_expander.handle_non_aliased_terms(non_aliased_fields, ses_data, search_term)).to eq(["\"Housing\"", "\"Accommodation\"", "\"Houses\""])
      end
    end

    context 'where there is no preferred term' do
      let!(:ses_data) { [{ equivalent_terms: [["Accommodation", "Houses"]], preferred_term_id: "91569", topic_id: "95629" }] }

      it 'returns equivalent terms and the original search term' do
        expect(term_expander.handle_non_aliased_terms(non_aliased_fields, ses_data, search_term)).to eq(["\"house\"", "\"Accommodation\"", "\"Houses\""])
      end
    end
  end

  describe 'populate_ses_fields' do
    let!(:ses_fields) { ["subject_ses"] }

    context 'where there is a preferred term ID' do
      # ses_data is generated by the .data method of SesQuery
      let!(:ses_data) { [{ equivalent_terms: ["Accommodation", "Houses"], preferred_term_id: "91569", preferred_term: "Housing", topic_id: "95629" }] }

      it 'assembles a search for ses fields using preferred term ID' do
        expect(term_expander.populate_ses_fields(ses_fields, ses_data)).to eq(["subject_ses:91569"])
      end
    end

    context 'where there is no preferred term ID' do
      let!(:ses_data) {}

      it 'returns an empty array' do
        expect(term_expander.populate_ses_fields(ses_fields, ses_data)).to eq([])
      end
    end
  end
end
