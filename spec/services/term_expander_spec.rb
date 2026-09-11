# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'TermExpander' do
  let(:term_expander) { TermExpander.new(expanded_fields: expanded_fields, ses_data: ses_data, search_term: search_term) }
  let(:ses_data) { [{ equivalent_terms: [["Accommodation", "Houses"]], preferred_term_id: "91569", preferred_term: "Housing", topic_id: "95629" }] }
  let(:search_term) { 'housing' }
  let(:expanded_fields) { { boolean_fields: boolean_fields, date_fields: date_fields,
                            fixed_fields: fixed_fields, ses_fields: ses_fields,
                            ses_id_fields: ses_id_fields, text_fields: text_fields,
                            transformations: transformations, process_without_field: process_without_field, } }
  let(:boolean_fields) { [] }
  let(:date_fields) { [] }
  let(:ses_fields) { [] }
  let(:ses_id_fields) { [] }
  let(:text_fields) { [] }
  let(:fixed_fields) { [] }
  let(:transformations) { [] }
  let(:process_without_field) { false }

  describe 'expand_terms' do

    before do
      allow(term_expander).to receive(:process_expanded_terms).and_return('processed terms')
    end

    context 'process_without_field is true' do
      let(:process_without_field) { true }
      it 'calls handle_non_aliased_terms' do
        allow(term_expander).to receive(:handle_non_aliased_terms)
        expect(term_expander.expand_terms).to eq('processed terms')
        expect(term_expander).to have_received(:handle_non_aliased_terms).once
      end
    end

    context 'there are text fields' do
      let(:text_fields) { ["field1", "field2"] }

      it 'calls populate_text_fields' do
        allow(term_expander).to receive(:populate_text_fields)
        expect(term_expander.expand_terms).to eq('processed terms')
        expect(term_expander).to have_received(:populate_text_fields).once
      end
    end

    context 'there are ses_id fields' do
      let(:ses_id_fields) { ["field1", "field2"] }
      it 'calls populate_ses_id_fields' do
        allow(term_expander).to receive(:populate_ses_id_fields)
        expect(term_expander.expand_terms).to eq('processed terms')
        expect(term_expander).to have_received(:populate_ses_id_fields).once
      end
    end

    context 'there are boolean fields' do
      let(:boolean_fields) { ["field1", "field2"] }

      it 'calls populate_boolean_fields' do
        allow(term_expander).to receive(:populate_boolean_fields)
        expect(term_expander.expand_terms).to eq('processed terms')
        expect(term_expander).to have_received(:populate_boolean_fields).once
      end
    end

    context 'there are date fields' do
      let(:date_fields) { ["field1", "field2"] }

      it 'calls populate_date_fields' do
        allow(term_expander).to receive(:populate_date_fields)
        expect(term_expander.expand_terms).to eq('processed terms')
        expect(term_expander).to have_received(:populate_date_fields).once
      end
    end

    context 'there are ses fields' do
      let(:ses_fields) { ["field1", "field2"] }
      it 'calls populate_ses_fields' do
        allow(term_expander).to receive(:populate_ses_fields)
        expect(term_expander.expand_terms).to eq('processed terms')
        expect(term_expander).to have_received(:populate_ses_fields).once
      end
    end
  end

  describe 'process_expanded_terms' do
    context 'where expanded terms is empty' do
      let(:expanded_terms_array) { [] }
      it 'returns nil' do
        expect(term_expander.process_expanded_terms(expanded_terms_array)).to be_nil
      end
    end

    context 'where expanded terms contains matched data' do
      let(:populate_text_fields_data) { [["91569", ["subject_t:\"Housing\"", "subject_t:\"Accommodation\"", "subject_t:\"Houses\""]]] }
      let(:populate_ses_fields_data) { [["91569", "subject_ses:91569"]] }
      let(:expanded_terms_array) { [populate_text_fields_data, populate_ses_fields_data] }

      it 'returns a structured query string that combines searches across the matched fields with "OR"' do
        expect(term_expander.process_expanded_terms(expanded_terms_array)).to eq("subject_t:\"Housing\" OR subject_t:\"Accommodation\" OR subject_t:\"Houses\" OR subject_ses:91569")
      end
    end

    context 'where expanded terms contains unmatched data' do
      let(:populate_text_fields_data) { [["91569", ["subject_t:\"Housing\"", "subject_t:\"Accommodation\"", "subject_t:\"Houses\""]]] }
      let(:populate_ses_fields_data) { [["12345", "subject_ses:12345"]] }
      let(:arbitrary_unmatched_data) { [[:a_unique_key, "a_field:a_term"]] }
      let(:expanded_terms_array) { [populate_text_fields_data, populate_ses_fields_data, arbitrary_unmatched_data] }

      it 'returns a structured query string that combines searches across the unmatched fields with "AND"' do
        expect(term_expander.process_expanded_terms(expanded_terms_array)).to eq("(subject_t:\"Housing\" OR subject_t:\"Accommodation\" OR subject_t:\"Houses\") AND subject_ses:12345 AND a_field:a_term")
      end
    end
  end

  describe 'populate_text_fields' do
    let(:text_fields) { ['department_t'] }
    let(:search_term) { 'house' }

    context 'where there is a preferred term' do
      let(:ses_data) { [{ equivalent_terms: [["Accommodation", "Houses"]], preferred_term_id: "91569", preferred_term: "Housing", topic_id: "95629" }] }

      it 'returns a search for preferred term and any equivalent terms' do
        expect(term_expander.populate_text_fields).to eq([["91569", ["department_t:Housing", "department_t:Accommodation", "department_t:Houses"]]])
      end
    end

    context 'where there is no preferred term' do
      let(:ses_data) { [{ equivalent_terms: [["Accommodation", "Houses"]], preferred_term_id: "91569", topic_id: "95629" }] }

      it 'returns a search for the search term and any equivalent terms' do
        expect(term_expander.populate_text_fields).to eq([["91569", ["department_t:house", "department_t:Accommodation", "department_t:Houses"]]])
      end
    end

    context 'where the SES data does not match all terms' do
      let(:search_term) { 'Large houses' }
      let(:ses_data) { [{ equivalent_terms: [["Accommodation", "Houses"]], preferred_term_id: "91569", preferred_term: "Housing", topic_id: "95629" }] }

      it 'includes terms not represented by any found via SES separately' do
        expect(term_expander.populate_text_fields).to eq([["91569", ["department_t:Housing", "department_t:Accommodation", "department_t:Houses"]], [:Large, ["department_t:Large"]]])
      end
    end

    context 'where there is no SES data at all' do
      let(:ses_data) { [] }

      it 'returns a search for the unexpanded term against the provided fields' do
        expect(term_expander.populate_text_fields).to eq([[:house, ["department_t:house"]]])
      end

    end

    context 'for a field-exists search' do
      let!(:search_term) { '*' }
      let(:ses_data) { [] }

      it 'returns a search for the wildcard operator against the provided field' do
        expect(term_expander.populate_text_fields).to eq([[:*, ["department_t:*"]]])
      end
    end
  end

  describe 'populate_ses_id_fields' do
    let(:ses_id_fields) { ['subject_ses'] }
    let(:search_term) { '91569' }
    it 'returns a search across those fields for the search term' do
      expect(term_expander.populate_ses_id_fields).to eq([[:ses_id, "subject_ses:91569"]])
    end
  end

  describe 'populate_boolean_fields' do
    let(:boolean_fields) { ["containsEM_b"] }

    context 'where the user searches for "true"' do
      let(:search_term) { 'true' }

      it 'returns a search string for 1' do
        expect(term_expander.populate_boolean_fields).to eq([[:boolean, "containsEM_b:1"]])
      end
    end

    context 'where the user searches for "true"' do
      let(:search_term) { 'yes' }

      it 'returns a search string for 1' do
        expect(term_expander.populate_boolean_fields).to eq([[:boolean, "containsEM_b:1"]])
      end
    end

    context 'where the user searches for "true"' do
      let(:search_term) { 'y' }

      it 'returns a search string for 1' do
        expect(term_expander.populate_boolean_fields).to eq([[:boolean, "containsEM_b:1"]])
      end
    end

    context 'where the user searches for "true"' do
      let(:search_term) { '1' }

      it 'returns a search string for 1' do
        expect(term_expander.populate_boolean_fields).to eq([[:boolean, "containsEM_b:1"]])
      end
    end

    context 'where the user searches for "false"' do
      let(:search_term) { 'false' }

      it 'returns a search string for 0' do
        expect(term_expander.populate_boolean_fields).to eq([[:boolean, "containsEM_b:0"]])
      end
    end

    context 'where the user searches for "no"' do
      let(:search_term) { 'no' }

      it 'returns a search string for 0' do
        expect(term_expander.populate_boolean_fields).to eq([[:boolean, "containsEM_b:0"]])
      end
    end

    context 'where the user searches for "n"' do
      let(:search_term) { 'n' }

      it 'returns a search string for 0' do
        expect(term_expander.populate_boolean_fields).to eq([[:boolean, "containsEM_b:0"]])
      end
    end

    context 'where the user searches for "0"' do
      let(:search_term) { '0' }

      it 'returns a search string for 0' do
        expect(term_expander.populate_boolean_fields).to eq([[:boolean, "containsEM_b:0"]])
      end
    end

    context 'for a field-exists search' do
      let!(:search_term) { '*' }

      it 'returns a search for the wildcard operator against the provided field' do
        expect(term_expander.populate_boolean_fields).to eq([[:boolean, "containsEM_b:*"]])
      end
    end
  end

  describe 'populate_date_fields' do
    context 'with a single date field' do
      let(:date_fields) { ["date_dt"] }

      context 'when searching "today"' do
        let(:search_term) { "today" }

        it "searches the provided date field for the relevant date range" do
          expect(term_expander.populate_date_fields).to eq [[:date, "date_dt:NOW/DAY"]]
        end
      end

      context 'when searching "yesterday"' do
        let(:search_term) { "yesterday" }

        it "searches the provided date field for the relevant date range" do
          expect(term_expander.populate_date_fields).to eq [[:date, "date_dt:NOW/DAY-1DAY"]]
        end
      end

      context 'when searching "thisweek"' do
        let(:search_term) { "thisweek" }

        it "searches the provided date field for the relevant date range" do
          expect(term_expander.populate_date_fields).to eq [[:date, "date_dt:[NOW/WEEK TO NOW/WEEK+6DAYS]"]]
        end
      end

      context 'when searching "lastweek"' do
        let(:search_term) { "lastweek" }

        it "searches the provided date field for the relevant date range" do
          expect(term_expander.populate_date_fields).to eq [[:date, "date_dt:[NOW/WEEK-1WEEK TO NOW/WEEK-1DAY]"]]
        end
      end

      context 'when searching "thismonth"' do
        let(:search_term) { "thismonth" }

        it "searches the provided date field for the relevant date range" do
          expect(term_expander.populate_date_fields).to eq [[:date, "date_dt:[NOW/MONTH TO NOW/MONTH+1MONTH-1MILLISECOND]"]]
        end
      end

      context 'when searching "lastmonth"' do
        let(:search_term) { "lastmonth" }

        it "searches the provided date field for the relevant date range" do
          expect(term_expander.populate_date_fields).to eq [[:date, "date_dt:[NOW/MONTH-1MONTH TO NOW/MONTH-1MILLISECOND]"]]
        end
      end

      context 'when searching "thisyear"' do
        let(:search_term) { "thisyear" }

        it "searches the provided date field for the relevant date range" do
          expect(term_expander.populate_date_fields).to eq [[:date, "date_dt:[NOW/YEAR TO NOW/YEAR+1YEAR-1MILLISECOND]"]]
        end
      end

      context 'when searching "lastyear"' do
        let(:search_term) { "lastyear" }

        it "searches the provided date field for the relevant date range" do
          expect(term_expander.populate_date_fields).to eq [[:date, "date_dt:[NOW/YEAR-1YEAR TO NOW/YEAR-1MILLISECOND]"]]
        end
      end

      context 'for field-exists search' do
        let!(:search_term) { '*' }

        it 'returns a search for the wildcard operator against the provided field' do
          expect(term_expander.populate_date_fields).to eq([[:date, "date_dt:*"]])
        end
      end
    end

    context 'with multiple date fields' do
      let(:date_fields) { ["dateCertified_dt", "certifiedDate_dt"] }
      let(:search_term) { "today" }

      it "applies the search across all provided date fields" do
        expect(term_expander.populate_date_fields).to eq [[:date, "dateCertified_dt:NOW/DAY"], [:date, "certifiedDate_dt:NOW/DAY"]]
      end
    end
  end

  describe 'handle_non_aliased_terms' do
    let(:non_aliased_fields) { ["none"] }

    context 'where there is a preferred term' do
      let(:search_term) { "house" }
      # ses_data is generated by the .data method of SesQuery
      let(:ses_data) { [{ equivalent_terms: [["Accommodation", "Houses"]], preferred_term_id: "91569", preferred_term: "Housing", topic_id: "95629" }] }

      it 'returns the preferred term and equivalent terms' do
        expect(term_expander.handle_non_aliased_terms).to eq([["91569", ["Housing", "Accommodation", "Houses"]]])
      end
    end

    context 'where there is no preferred term' do
      let(:search_term) { "house" }
      let(:ses_data) { [{ equivalent_terms: [["Accommodation", "Houses"]], preferred_term_id: "91569", topic_id: "95629" }] }

      it 'returns equivalent terms and the original search term' do
        expect(term_expander.handle_non_aliased_terms).to eq([["91569", ["house", "Accommodation", "Houses"]]])
      end
    end

    context 'where the search term was represented during expansion' do
      let(:ses_data) { [{ equivalent_terms: [["Accommodation", "Houses"]], preferred_term_id: "91569", preferred_term: "Housing", topic_id: "95629" }] }

      context 'in exact match mode' do
        let(:term_expander) { TermExpander.new(expanded_fields: expanded_fields, ses_data: ses_data, search_term: search_term, exact_match: true) }
        let(:search_term) { "\"houses\"" }

        it 'returns preferred term and equivalent terms only because they include the search term' do
          expect(term_expander.handle_non_aliased_terms).to eq([["91569", ["Housing", "Accommodation", "Houses"]]])
        end
      end

      context 'not in exact match mode' do
        let(:search_term) { "houses" }

        it 'returns preferred term, equivalent terms only because they include the search term' do
          expect(term_expander.handle_non_aliased_terms).to eq([["91569", ["Housing", "Accommodation", "Houses"]]])
        end
      end
    end

    context 'where the search term was not represented perfectly during expansion' do
      let(:ses_data) { [{ equivalent_terms: [["Accommodation", "Houses"]], preferred_term_id: "91569", preferred_term: "Housing", topic_id: "95629" }] }

      context "in exact match mode" do
        # we need an exact match from query expansion - it must include house as a distinct word
        # because we want to make sure it's passed to Solr as entered regardless
        let(:term_expander) { TermExpander.new(expanded_fields: expanded_fields, ses_data: ses_data, search_term: search_term, exact_match: true) }
        let(:search_term) { "\"house\"" }
        it 'returns preferred term, equivalent terms and the original search term in quotes' do
          expect(term_expander.handle_non_aliased_terms).to eq([["91569", ["Housing", "Accommodation", "Houses"]], [:"\"house\"", ["\"house\""]]])
        end
      end

      context "not in exact match mode" do
        # we're happy for it to be included within something else, like houses
        let(:search_term) { "house" }
        it 'returns preferred term, equivalent terms and the original search term' do
          expect(term_expander.handle_non_aliased_terms).to eq([["91569", ["Housing", "Accommodation", "Houses"]]])
        end
      end
    end
  end

  describe 'populate_ses_fields' do
    let(:ses_fields) { ["subject_ses"] }

    context 'where there is a preferred term ID' do
      # ses_data is generated by the .data method of SesQuery
      let(:ses_data) { [{ equivalent_terms: ["Accommodation", "Houses"], preferred_term_id: "91569", preferred_term: "Housing", topic_id: "95629" }] }

      it 'assembles a search for ses fields using preferred term ID' do
        expect(term_expander.populate_ses_fields).to eq([["91569", ["subject_ses:91569"]]])
      end
    end

    context 'where there is no preferred term ID' do
      let(:ses_data) {}

      it 'returns an empty array' do
        expect(term_expander.populate_ses_fields).to eq([])
      end
    end

    context 'for a field-exists search' do
      let!(:search_term) { '*' }
      let(:ses_data) {}

      it 'returns a field-exists search against the provided field' do
        expect(term_expander.populate_ses_fields).to eq([[:*, ["subject_ses:*"]]])
      end
    end
  end

  describe 'populate_fixed_fields' do
    context 'for chair' do
      let!(:fixed_fields) { ["chair"] }

      context 'for true' do
        let!(:search_term) { 'YES' }
        it 'returns member_ses:303704' do
          expect(term_expander.populate_fixed_fields).to eq([[:ses_id, "member_ses:303704"]])
        end
      end

      context 'for false' do
        let!(:search_term) { "0" }
        it 'returns "-" member_ses:303704' do
          expect(term_expander.populate_fixed_fields).to eq([[:ses_id, "-member_ses:303704"]])
        end
      end
    end

    context 'for from' do
      let!(:fixed_fields) { ["fromdate"] }
      let!(:search_term) { "2022-05-20" }
      it 'returns an open ended date range beginning with the provided date' do
        expect(term_expander.populate_fixed_fields).to eq([[:date, "date_dt:2022-05-20T00:00:00Z TO *"]])
      end
    end

    context 'for to' do
      let!(:fixed_fields) { ["todate"] }
      let!(:search_term) { "2022-05-20" }
      it 'returns an open ended date range ending with the provided date' do
        expect(term_expander.populate_fixed_fields).to eq([[:date, "* TO date_dt:2022-05-20T00:00:00Z"]])
      end
    end

    context 'for opqtype' do
      let!(:fixed_fields) { ["opqtype"] }

      context 'for supp' do
        let!(:search_term) { 'supp' }

        it 'returns a fixed value' do
          expect(term_expander.populate_fixed_fields).to eq([[:text, "contributionType_t:supplementary"]])
        end
      end

      context 'for othersupp' do
        let!(:search_term) { 'othersupp' }

        it 'returns a fixed value' do
          expect(term_expander.populate_fixed_fields).to eq([[:text, "contributionType_s:Supplementary"]])
        end
      end

      context 'for firstsupp' do
        let!(:search_term) { 'firstsupp' }

        it 'returns a fixed value' do
          expect(term_expander.populate_fixed_fields).to eq([[:text, "contributionType_s:\"1st Supplementary\""]])
        end
      end

      context 'for lead' do
        let!(:search_term) { 'lead' }

        it 'returns a fixed value' do
          expect(term_expander.populate_fixed_fields).to eq([[:text, "contributionType_s:Lead"]])
        end
      end
    end

    context 'for wpqtype' do
      let!(:fixed_fields) { ["wpqtype"] }

      context 'for ordinary' do
        let!(:search_term) { 'ordinary' }

        it 'returns a fixed value' do
          expect(term_expander.populate_fixed_fields).to eq([[:text, "wpqType_s:Ordinary"]])
        end
      end
      context 'for namedday' do
        let!(:search_term) { 'namedday' }

        it 'returns a fixed value' do
          expect(term_expander.populate_fixed_fields).to eq([[:text, "wpqType_s:Named Day"]])
        end
      end
      context 'for nextday' do
        let!(:search_term) { 'nextday' }

        it 'returns a fixed value' do
          expect(term_expander.populate_fixed_fields).to eq([[:text, "wpqType_s:daily"]])
        end
      end
    end
  end

  describe 'apply_transformations' do
    context 'for an unknown transformation name' do
      let!(:transformations) { ["string"] }

      it 'raises an error' do
        expect { term_expander.apply_transformations }.to raise_error(QueryExpansionError, "Unknown transformation type \"string\"")
      end
    end

    context 'for status' do
      let!(:transformations) { ["status"] }
      let!(:search_term) { 'test' }

      it 'titleizes the search term and applies it across three fields' do
        expect(term_expander.apply_transformations).to eq([[:status, "edmStatus_s:Test"], [:status, "pqStatus_s:Test"], [:status, "status_s:Test"]])
      end
    end

    context 'for timestamp' do
      let!(:transformations) { ["timestamp"] }

      context 'for a single date' do
        context 'formatted YYYY-MM-DD' do
          let!(:search_term) { '2022-05-04' }
          it 'returns a date range for the entire day using an exclusive range end' do
            expect(term_expander.apply_transformations).to eq([[:timestamp, "timestamp:[2022-05-04T00:00:00Z TO 2022-05-05T00:00:00Z}"]])
          end
        end
        context 'formatted YY-MM-DD' do
          let!(:search_term) { '22-05-04' }
          it 'returns a date range for the entire day using an exclusive range end' do
            expect(term_expander.apply_transformations).to eq([[:timestamp, "timestamp:[2022-05-04T00:00:00Z TO 2022-05-05T00:00:00Z}"]])
          end
        end
        context 'formatted as a full timestamp' do
          let!(:search_term) { '2022-05-04T00:00:00Z' }
          it 'returns a date range for the entire day using an exclusive range end' do
            expect(term_expander.apply_transformations).to eq([[:timestamp, "timestamp:[2022-05-04T00:00:00Z TO 2022-05-05T00:00:00Z}"]])
          end
        end
        context 'formatted as a full timestamp for a time other than midnight' do
          let!(:search_term) { '2022-05-04T07:28:02Z' }
          it 'returns a date range for the entire day using an exclusive range end' do
            expect(term_expander.apply_transformations).to eq([[:timestamp, "timestamp:[2022-05-04T00:00:00Z TO 2022-05-05T00:00:00Z}"]])
          end
        end
      end
      context 'for a date range' do
        context 'using ..' do
          let!(:search_term) { '2022-05-04..2022-05-09' }
          it 'returns a date range for the entire day using an exclusive range end' do
            expect(term_expander.apply_transformations).to eq([[:timestamp, "timestamp:[2022-05-04T00:00:00Z TO 2022-05-10T00:00:00Z}"]])
          end
        end
        context 'using TO' do
          let!(:search_term) { '2022-05-04 TO 2022-05-09' }
          it 'returns a date range for the entire day using an exclusive range end' do
            expect(term_expander.apply_transformations).to eq([[:timestamp, "timestamp:[2022-05-04T00:00:00Z TO 2022-05-10T00:00:00Z}"]])
          end
        end
      end
    end

    context 'for session' do
      let!(:transformations) { ["session"] }
      let!(:search_term) { '18/19' }

      it 'returns a session term string with the session name in the correct format' do
        expect(term_expander.apply_transformations).to eq([[:session, "session_s:2018-19"]])
      end

      context 'where the search term uses -' do
        let!(:search_term) { '18-19' }

        it 'returns a session term string with the session name in the correct format' do
          expect(term_expander.apply_transformations).to eq([[:session, "session_s:2018-19"]])
        end
      end

      context 'where the search term uses &' do
        let!(:search_term) { '18&19' }

        it 'returns a session term string with the session name in the correct format' do
          expect(term_expander.apply_transformations).to eq([[:session, "session_s:2018-19"]])
        end
      end

      context 'where the search term uses :' do
        let!(:search_term) { '18:19' }

        it 'returns a session term string with the session name in the correct format' do
          expect(term_expander.apply_transformations).to eq([[:session, "session_s:2018-19"]])
        end
      end

      context 'where the search term represents a start year more than a year in the future' do
        let!(:search_term) { "#{(Date.current.year + 2) % 100}/#{(Date.current.year + 3) % 100}" }

        it 'assumes the search is for a past year' do
          expect(term_expander.apply_transformations).to eq([[:session, "session_s:#{(Date.current.year - 98)}-#{(Date.current.year - 97) % 100}"]])
        end
      end

      context 'where the search term represents a start year less than one year in the future' do
        let!(:search_term) { "#{(Date.current.year) % 100}/#{(Date.current.year + 1) % 100}" }

        it 'assumes the search is for a future year' do
          expect(term_expander.apply_transformations).to eq([[:session, "session_s:#{(Date.current.year)}-#{(Date.current.year + 1) % 100}"]])
        end
      end

      context 'where the search term represents a start year in the past' do
        let!(:search_term) { "#{(Date.current.year - 30) % 100}/#{(Date.current.year - 29) % 100}" }

        it 'assumes the search is for a past year' do
          expect(term_expander.apply_transformations).to eq([[:session, "session_s:#{(Date.current.year - 30)}-#{(Date.current.year - 29) % 100}"]])
        end
      end
    end
  end
end
