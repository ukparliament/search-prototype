# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ExpandQuery' do
  let(:expand_query) { ExpandQuery.new(search_query, ses_test_class) }
  let(:ses_test_class) { class_double(SesQuery, new: ses_test_instance) }
  let(:ses_test_instance) { instance_double(SesQuery, data: 'ses_data') }
  let(:search_query) {}

  describe 'process_query' do
    context 'where the term is a solr query operator' do
      let(:terms) { ['OR', 'NOT', 'AND'] }
      it 'adds the term to returned_terms as-is' do
        allow(expand_query).to receive(:extract_terms).and_return(terms)
        expect(expand_query.process_query).to eq(["OR", "NOT", "AND"])
      end
    end

    context 'where the term is a double-quoted phrase with a specified field' do
      let(:terms) { ['subject_ses:"housing crisis"'] }
      it 'calls expand fields and expand terms' do
        # stub extract terms so that we start with the terms we want
        allow(expand_query).to receive(:extract_terms).and_return(terms)

        # check that expand_fields receives the field name
        # return test data
        allow(expand_query).to receive(:expand_fields).with('subject_ses').and_return(['expanded_fields'])

        # check that expand_terms receives the expanded_fields, (mock) ses response and search term
        # stub process term so that we just get 'result' back
        allow(expand_query).to receive(:expand_terms).with(["expanded_fields"], "ses_data", "\"housing crisis\"").and_return("result")

        # check that SES class receives a call to create a new instance
        expect(ses_test_class).to receive(:new).with(({ value: "\"housing crisis\"" }))
        # check that SES instance receives a call to data method
        expect(ses_test_instance).to receive(:data)

        # expect to see the (mock) result added to an array
        expect(expand_query.process_query).to eq(["result"])
      end
    end

    context "where the term is a single-quoted phrase with a specified field" do
      let(:terms) { ["subject_ses:'housing crisis'"] }
      it 'calls process term' do
        allow(expand_query).to receive(:extract_terms).and_return(terms)
        allow(expand_query).to receive(:expand_fields).with("subject_ses").and_return(['expanded_fields'])
        allow(expand_query).to receive(:expand_terms).with(['expanded_fields'], "ses_data", "'housing crisis'").and_return("result")
        expect(ses_test_class).to receive(:new).with(({ value: "'housing crisis'" }))
        expect(ses_test_instance).to receive(:data)
        expect(expand_query.process_query).to eq(["result"])
      end
    end

    context 'where the term is an unquoted string with a specified field' do
      let(:terms) { ["subject_ses:housing"] }
      it 'calls process term' do
        allow(expand_query).to receive(:extract_terms).and_return(terms)
        allow(expand_query).to receive(:expand_fields).with("subject_ses").and_return(['expanded_fields'])
        allow(expand_query).to receive(:expand_terms).with(['expanded_fields'], "ses_data", "housing").and_return("result")
        expect(ses_test_class).to receive(:new).with(({ value: "housing" }))
        expect(ses_test_instance).to receive(:data)
        expect(expand_query.process_query).to eq(["result"])
      end
    end

    context 'where the term is a double-quoted phrase without a specified field' do
      let(:terms) { ["\"housing crisis\""] }
      it 'calls SES for expanded terms; expands fields with "none" only' do
        allow(expand_query).to receive(:extract_terms).and_return(terms)
        allow(expand_query).to receive(:expand_fields).with("none").and_return(['expanded_fields'])
        allow(expand_query).to receive(:expand_terms).with(['expanded_fields'], "ses_data", "\"housing crisis\"").and_return("result")
        expect(ses_test_class).to receive(:new).with(({ value: "\"housing crisis\"" }))
        expect(ses_test_instance).to receive(:data)
        expect(expand_query.process_query).to eq(["result"])
      end
    end

    context 'where the term is a single-quoted phrase without a specified field' do
      let(:terms) { ["'housing crisis'"] }
      it 'calls SES for expanded terms; expands fields with "none" only' do
        allow(expand_query).to receive(:extract_terms).and_return(terms)
        allow(expand_query).to receive(:expand_fields).with("none").and_return(['expanded_fields'])
        expect(ses_test_class).to receive(:new).with(({ value: "'housing crisis'" }))
        expect(ses_test_instance).to receive(:data)
        allow(expand_query).to receive(:expand_terms).with(['expanded_fields'], "ses_data", "'housing crisis'").and_return("result")
        expect(expand_query.process_query).to eq(["result"])
      end
    end

    context 'where the term is an unquoted string without a specified field' do
      let(:terms) { ["housing"] }
      it 'calls process term with the field_name "none"' do
        allow(expand_query).to receive(:extract_terms).and_return(terms)
        allow(expand_query).to receive(:expand_fields).with("none").and_return(['expanded_fields'])
        allow(expand_query).to receive(:expand_terms).with(['expanded_fields'], "ses_data", "housing").and_return("result")
        expect(ses_test_class).to receive(:new).with(({ value: "housing" }))
        expect(ses_test_instance).to receive(:data)
        expect(expand_query.process_query).to eq(["result"])
      end
    end

    pending 'where the term is wrapped in square brackets' do
      it 'does not expand the terms using SES' do

      end
    end
  end

  describe 'expand_fields' do
    context 'field name is title' do
      it 'populates text_fields' do
        expect(expand_query.expand_fields('title')).to eq(
                                                         { "boolean_fields" => [],
                                                           "date_fields" => [],
                                                           "non_aliased_fields" => [],
                                                           "ses_fields" => [],
                                                           "ses_id_fields" => [],
                                                           "text_fields" => ["title_t"] })
      end
    end
    context 'field name is subject' do
      it 'populates text_fields and ses_fields' do
        expect(expand_query.expand_fields('subject')).to eq(
                                                           { "boolean_fields" => [],
                                                             "date_fields" => [],
                                                             "non_aliased_fields" => [],
                                                             "ses_fields" => ["subject_ses"],
                                                             "ses_id_fields" => [],
                                                             "text_fields" => ["subject_t"] })
      end
    end
    context 'field name is author' do
      it 'populates text_fields and ses_fields' do
        expect(expand_query.expand_fields('author')).to eq(
                                                          { "boolean_fields" => [],
                                                            "date_fields" => [],
                                                            "non_aliased_fields" => [],
                                                            "ses_fields" => ["creator_ses", "contributor_ses", "corporateAuthor_ses", "mep_ses", "section_ses", "tablingMember_ses", "askingMember_ses", "answeringMember_ses", "department_ses", "member_ses", "leadMember_ses", "correspondingMinister_ses"],
                                                            "ses_id_fields" => [],
                                                            "text_fields" => ["creator_t", "contributor_t", "corporateAuthor_t", "epCommittee_t", "department_t", "correspondingMinister_t"] })
      end
    end
    context 'field name is explanatorymemorandum' do
      it 'populates boolean_fields' do
        expect(expand_query.expand_fields('explanatorymemorandum')).to eq(
                                                                         { "boolean_fields" => ["containsEM_b"],
                                                                           "date_fields" => [],
                                                                           "non_aliased_fields" => [],
                                                                           "ses_fields" => [],
                                                                           "ses_id_fields" => [],
                                                                           "text_fields" => [] })
      end
    end
    context 'field name is datecertified' do
      it 'populates date_fields' do
        expect(expand_query.expand_fields('datecertified')).to eq(
                                                                 { "boolean_fields" => [],
                                                                   "date_fields" => ["dateCertified_dt", "certifiedDate_dt"],
                                                                   "non_aliased_fields" => [],
                                                                   "ses_fields" => [],
                                                                   "ses_id_fields" => [],
                                                                   "text_fields" => [] })
      end
    end
    context 'field name is date' do
      it 'populates date_fields' do
        expect(expand_query.expand_fields('date')).to eq(
                                                        { "boolean_fields" => [],
                                                          "date_fields" => ["date_dt"],
                                                          "non_aliased_fields" => [],
                                                          "ses_fields" => [],
                                                          "ses_id_fields" => [],
                                                          "text_fields" => [] })
      end
    end
    context 'field name ends in _dt' do
      it 'populates date_fields' do
        expect(expand_query.expand_fields('anything_dt')).to eq(
                                                               { "boolean_fields" => [],
                                                                 "date_fields" => ["anything_dt"],
                                                                 "non_aliased_fields" => [],
                                                                 "ses_fields" => [],
                                                                 "ses_id_fields" => [],
                                                                 "text_fields" => [] })
      end
    end
    context 'field name ends in _ses' do
      it 'populates ses_id_fields' do
        expect(expand_query.expand_fields('anything_ses')).to eq(
                                                                { "boolean_fields" => [],
                                                                  "date_fields" => [],
                                                                  "non_aliased_fields" => [],
                                                                  "ses_fields" => [],
                                                                  "ses_id_fields" => ["anything_ses"],
                                                                  "text_fields" => [] })
      end
    end
    context 'field name is none' do
      it 'populates non-aliased fields and ses_fields with all_ses' do
        expect(expand_query.expand_fields('none')).to eq(
                                                        { "boolean_fields" => [],
                                                          "date_fields" => [],
                                                          "non_aliased_fields" => ["none"],
                                                          "ses_fields" => ['all_ses'],
                                                          "ses_id_fields" => [],
                                                          "text_fields" => [] })
      end
    end
    context 'field name is other text' do
      it 'populates text fields' do
        expect(expand_query.expand_fields('unrecognised_field_name')).to eq(
                                                                           { "boolean_fields" => [],
                                                                             "date_fields" => [],
                                                                             "non_aliased_fields" => [],
                                                                             "ses_fields" => [],
                                                                             "ses_id_fields" => [],
                                                                             "text_fields" => ["unrecognised_field_name"] })
      end
    end
  end

  describe 'expand_terms' do
    let!(:ses_data) { [{ equivalent_terms: [["Accommodation", "Houses"]], preferred_term_id: "91569", preferred_term: "Housing", topic_id: "95629" }] }
    let!(:search_term) { 'housing' }

    context 'there are non-aliased fields' do
      let!(:expanded_fields) { { "boolean_fields" => [],
                                 "date_fields" => [],
                                 "non_aliased_fields" => ["field1", "field2"],
                                 "ses_fields" => [],
                                 "ses_id_fields" => [],
                                 "text_fields" => [] } }
      it 'calls handle_non_aliased_terms' do
        allow(expand_query).to receive(:handle_non_aliased_terms)
        expand_query.expand_terms(expanded_fields, ses_data, search_term)
        expect(expand_query).to have_received(:handle_non_aliased_terms).with(["field1", "field2"], ses_data, search_term).once
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
        allow(expand_query).to receive(:populate_text_fields)
        expand_query.expand_terms(expanded_fields, ses_data, search_term)
        expect(expand_query).to have_received(:populate_text_fields).with(["field1", "field2"], ses_data, search_term).once
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
        allow(expand_query).to receive(:populate_ses_id_fields)
        expand_query.expand_terms(expanded_fields, ses_data, search_term)
        expect(expand_query).to have_received(:populate_ses_id_fields).with(["field1", "field2"], search_term).once
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
        allow(expand_query).to receive(:populate_boolean_fields)
        expand_query.expand_terms(expanded_fields, ses_data, search_term)
        expect(expand_query).to have_received(:populate_boolean_fields).with(["field1", "field2"], search_term).once
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
        allow(expand_query).to receive(:populate_date_fields)
        expand_query.expand_terms(expanded_fields, ses_data, search_term)
        expect(expand_query).to have_received(:populate_date_fields).with(["field1", "field2"], search_term).once
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
        allow(expand_query).to receive(:populate_ses_fields)
        expand_query.expand_terms(expanded_fields, ses_data, search_term)
        expect(expand_query).to have_received(:populate_ses_fields).with(["field1", "field2"], ses_data).once
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
        expect(expand_query.expand_terms(expanded_fields, ses_data, search_term)).to eq("field1:91569 OR field2:91569")
      end
    end
  end

  describe 'populate_text_fields' do
    let!(:text_fields) { ['department_t'] }

    context 'where there is a preferred term' do
      let!(:ses_data) { [{ equivalent_terms: [["Accommodation", "Houses"]], preferred_term_id: "91569", preferred_term: "Housing", topic_id: "95629" }] }

      it 'returns a search for preferred term and any equivalent terms' do
        expect(expand_query.populate_text_fields(text_fields, ses_data, 'house')).to eq(["department_t:\"Housing\"", "department_t:\"Accommodation\"", "department_t:\"Houses\""])
      end
    end
    context 'where there is no preferred term' do
      let!(:ses_data) { [{ equivalent_terms: [["Accommodation", "Houses"]], preferred_term_id: "91569", topic_id: "95629" }] }

      it 'returns a search for the search term and any equivalent terms' do
        expect(expand_query.populate_text_fields(text_fields, ses_data, 'house')).to eq(["department_t:\"house\"", "department_t:\"Accommodation\"", "department_t:\"Houses\""])
      end
    end
  end

  describe 'populate_ses_id_fields' do
    let!(:ses_id_fields) { ['subject_ses'] }
    it 'returns a search across those fields for the search term' do
      expect(expand_query.populate_ses_id_fields(ses_id_fields, 91569)).to eq(["subject_ses:91569"])
    end
  end

  describe 'populate_boolean_fields' do
    let!(:boolean_fields) { ["containsEM_b"] }

    context 'where the user searches for a "true" equivalent' do
      it 'returns a search string for 1' do
        expect(expand_query.populate_boolean_fields(boolean_fields, "true")).to eq(["containsEM_b:1"])
        expect(expand_query.populate_boolean_fields(boolean_fields, "yes")).to eq(["containsEM_b:1"])
        expect(expand_query.populate_boolean_fields(boolean_fields, "y")).to eq(["containsEM_b:1"])
        expect(expand_query.populate_boolean_fields(boolean_fields, "1")).to eq(["containsEM_b:1"])
      end
    end

    context 'where the user searches for a "false" equivalent' do
      it 'returns a search string for 1' do
        expect(expand_query.populate_boolean_fields(boolean_fields, "false")).to eq(["containsEM_b:0"])
        expect(expand_query.populate_boolean_fields(boolean_fields, "no")).to eq(["containsEM_b:0"])
        expect(expand_query.populate_boolean_fields(boolean_fields, "n")).to eq(["containsEM_b:0"])
        expect(expand_query.populate_boolean_fields(boolean_fields, "0")).to eq(["containsEM_b:0"])
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
        expect(expand_query.populate_date_fields(date_fields, search_today)).to eq ["date_dt:NOW/DAY"]
        expect(expand_query.populate_date_fields(date_fields, search_yesterday)).to eq ["date_dt:NOW/DAY-1DAY"]
        expect(expand_query.populate_date_fields(date_fields, search_this_week)).to eq ["date_dt:[NOW/WEEK TO NOW/WEEK+6DAYS]"]
        expect(expand_query.populate_date_fields(date_fields, search_last_week)).to eq ["date_dt:[NOW/WEEK-1WEEK TO NOW/WEEK-1DAY]"]
        expect(expand_query.populate_date_fields(date_fields, search_this_month)).to eq ["date_dt:[NOW/MONTH TO NOW/MONTH+1MONTH-1MILLISECOND]"]
        expect(expand_query.populate_date_fields(date_fields, search_last_month)).to eq ["date_dt:[NOW/MONTH-1MONTH TO NOW/MONTH-1MILLISECOND]"]
        expect(expand_query.populate_date_fields(date_fields, search_this_year)).to eq ["date_dt:[NOW/YEAR TO NOW/YEAR+1YEAR-1MILLISECOND]"]
        expect(expand_query.populate_date_fields(date_fields, search_last_year)).to eq ["date_dt:[NOW/YEAR-1YEAR TO NOW/YEAR-1MILLISECOND]"]
      end
    end
    context 'with multiple date fields' do
      let!(:date_fields) { ["dateCertified_dt", "certifiedDate_dt"] }

      it "applies the search across all provided date fields" do
        expect(expand_query.populate_date_fields(date_fields, search_today)).to eq ["dateCertified_dt:NOW/DAY", "certifiedDate_dt:NOW/DAY"]
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
        expect(expand_query.handle_non_aliased_terms(non_aliased_fields, ses_data, search_term)).to eq(["\"Housing\"", "\"Accommodation\"", "\"Houses\""])
      end
    end

    context 'where there is no preferred term' do
      let!(:ses_data) { [{ equivalent_terms: [["Accommodation", "Houses"]], preferred_term_id: "91569", topic_id: "95629" }] }

      it 'returns equivalent terms and the original search term' do
        expect(expand_query.handle_non_aliased_terms(non_aliased_fields, ses_data, search_term)).to eq(["\"house\"", "\"Accommodation\"", "\"Houses\""])
      end
    end
  end

  describe 'populate_ses_fields' do
    let!(:ses_fields) { ["subject_ses"] }

    context 'where there is a preferred term ID' do
      # ses_data is generated by the .data method of SesQuery
      let!(:ses_data) { [{ equivalent_terms: ["Accommodation", "Houses"], preferred_term_id: "91569", preferred_term: "Housing", topic_id: "95629" }] }

      it 'assembles a search for ses fields using preferred term ID' do
        expect(expand_query.populate_ses_fields(ses_fields, ses_data)).to eq(["subject_ses:91569"])
      end
    end

    context 'where there is no preferred term ID' do
      let!(:ses_data) {}

      it 'returns an empty array' do
        expect(expand_query.populate_ses_fields(ses_fields, ses_data)).to eq([])
      end
    end
  end

  describe 'extract_terms' do
    context 'with no search query' do
      it 'returns nil' do
        expect(expand_query.extract_terms).to be_nil
      end
    end
    context 'with an empty search query' do
      let!(:search_query) { "" }

      it 'returns nil' do
        expect(expand_query.extract_terms).to be_nil
      end
    end
    context 'with a search query' do
      context 'with a single term' do
        let!(:search_query) { "housing" }

        it 'returns the term in an array' do
          expect(expand_query.extract_terms).to eq(["housing"])
        end
      end
      context 'with multiple field scoped terms and unscoped terms' do
        let!(:search_query) { "subject:housing subject:\"old houses\" subject:\"houses\" houses \"old houses\" \"houses\"" }

        it 'extracts the individual terms into an array of strings' do
          expect(expand_query.extract_terms).to eq(["subject:housing", "subject:\"old houses\"", "subject:\"houses\"", "houses", "old houses", "houses"])
        end
      end
    end
  end
end
