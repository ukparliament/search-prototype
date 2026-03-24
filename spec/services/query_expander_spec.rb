# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'QueryExpander' do
  let(:query_expander) { QueryExpander.new(search_query, ses_test_class, tokeniser_test_class,
                                           field_expander_test_class, term_expander_test_class,
                                           term_combiner_test_class) }

  let(:ses_test_class) { class_double(SesQuery, new: ses_test_instance) }
  let(:ses_test_instance) { instance_double(SesQuery, data: ses_response) }
  let(:ses_response) { 'test ses response' }

  let(:tokeniser_test_class) { class_double(Tokeniser, new: tokeniser_test_instance) }
  let(:tokeniser_test_instance) { instance_double(Tokeniser) }

  let(:field_expander_test_class) { class_double(FieldExpander, new: field_expander_test_instance) }
  let(:field_expander_test_instance) { instance_double(FieldExpander, expand_fields: expanded_fields) }
  let(:expanded_fields) { {
    'text_fields' => [],
    'ses_fields' => [],
    'ses_id_fields' => [],
    'boolean_fields' => [],
    'date_fields' => [],
    'non_aliased_fields' => []
  } }

  let(:term_expander_test_class) { class_double(TermExpander, new: term_expander_test_instance) }
  let(:term_expander_test_instance) { instance_double(TermExpander, expand_terms: expanded_term) }
  let(:expanded_term) { 'this OR that' }

  let(:term_combiner_test_class) { class_double(TermCombiner, new: term_combiner_test_instance) }
  let(:term_combiner_test_instance) { instance_double(TermCombiner, combine_terms: expanded_query_string) }
  let(:expanded_query_string) { 'this OR that AND they OR them' }

  describe 'expand_query' do
    context 'where the term is a solr query operator' do
      let(:search_query) { "OR NOT AND" }
      it 'adds the term to returned_terms as-is' do
        # tokeniser is initialised with the query string
        expect(tokeniser_test_class).to receive(:new).with("OR NOT AND")

        # tokeniser instance receives call to tokenise
        expect(tokeniser_test_instance).to receive(:tokenise).and_return([[:operator, 'OR'], [:operator, 'NOT'], [:operator, 'AND']])

        # the term combiner is initialised with the unmodified operators returned from the tokeniser
        expect(term_combiner_test_class).to receive(:new).with(["OR", "NOT", "AND"])

        # the term combiner recieves call to combine the terms
        expect(term_combiner_test_instance).to receive(:combine_terms).and_return("combined terms")

        # the method returns the result from the term combiner
        expect(query_expander.expand_query).to eq("combined terms")
      end
    end

    context 'where the term is a double-quoted phrase with a specified field' do
      let(:search_query) { ['subject:"housing crisis"'] }
      it 'expands on fields and terms' do
        # tokeniser is initialised with the query string
        expect(tokeniser_test_class).to receive(:new).with(["subject:\"housing crisis\""])

        # tokeniser instance receives call to tokenise
        expect(tokeniser_test_instance).to receive(:tokenise).and_return([[:specified_field_with_quoted_phrase, 'subject:"housing crisis"']])

        # SES query class is initialised with the search term (only)
        expect(ses_test_class).to receive(:new).with({ value: "\"housing crisis\"" })

        # SES query instance receives call for data
        expect(ses_test_instance).to receive(:data).and_return(ses_response)

        # field expander class is initialised with the field name (only)
        expect(field_expander_test_class).to receive(:new).with('subject')

        # field expander instance receives call to expand_fields
        expect(field_expander_test_instance).to receive(:expand_fields).and_return(expanded_fields)

        # the term expander is initialised with the result of the field expansion & ses data, as well as the search
        # term
        expect(term_expander_test_class).to receive(:new).with(expanded_fields: expanded_fields, ses_data: ses_response, search_term: "\"housing crisis\"")

        # term expander receives call to expand terms
        expect(term_expander_test_instance).to receive(:expand_terms).and_return('processed tokens')

        # the term combiner is initialised with the response from expand terms in an array
        expect(term_combiner_test_class).to receive(:new).with(['processed tokens'])

        # the term combiner recieves call to combine the terms
        expect(term_combiner_test_instance).to receive(:combine_terms).and_return("combined terms")

        # the method returns the result from the term combiner
        expect(query_expander.expand_query).to eq("combined terms")
      end
    end

    context 'where the term is a single-quoted phrase with a specified field' do
      let(:search_query) { ["subject:'housing crisis'"] }
      it 'expands on fields and terms' do
        # tokeniser is initialised with the query string
        expect(tokeniser_test_class).to receive(:new).with(["subject:'housing crisis'"])

        # tokeniser instance receives call to tokenise
        expect(tokeniser_test_instance).to receive(:tokenise).and_return([[:specified_field_with_quoted_phrase, "subject:'housing crisis'"]])

        # SES query class is initialised with the search term (only)
        expect(ses_test_class).to receive(:new).with({ value: "'housing crisis'" })

        # SES query instance receives call for data
        expect(ses_test_instance).to receive(:data).and_return(ses_response)

        # field expander class is initialised with the field name (only)
        expect(field_expander_test_class).to receive(:new).with('subject')

        # field expander instance receives call to expand_fields
        expect(field_expander_test_instance).to receive(:expand_fields).and_return(expanded_fields)

        # the term expander is initialised with the result of the field expansion & ses data, as well as the search
        # term
        expect(term_expander_test_class).to receive(:new).with(expanded_fields: expanded_fields, ses_data: ses_response, search_term: "'housing crisis'")

        # term expander receives call to expand terms
        expect(term_expander_test_instance).to receive(:expand_terms).and_return('processed tokens')

        # the term combiner is initialised with the response from expand terms in an array
        expect(term_combiner_test_class).to receive(:new).with(['processed tokens'])

        # the term combiner recieves call to combine the terms
        expect(term_combiner_test_instance).to receive(:combine_terms).and_return("combined terms")

        # the method returns the result from the term combiner
        expect(query_expander.expand_query).to eq("combined terms")
      end
    end

    context "where the term is a phrase wrapped in square brackets with a specified field" do
      let(:search_query) { ["subject:[housing crisis]"] }
      it 'expands the field only' do
        # tokeniser is initialised with the query string
        expect(tokeniser_test_class).to receive(:new).with(["subject:[housing crisis]"])

        # tokeniser instance receives call to tokenise
        expect(tokeniser_test_instance).to receive(:tokenise).and_return([[:specified_field_no_expansion, "subject:[housing crisis]"]])

        # SES query class is not initialised
        expect(ses_test_class).not_to receive(:new)

        # SES query instance does not receive call for data
        expect(ses_test_instance).not_to receive(:data)

        # field expander class is initialised with the field name (only)
        expect(field_expander_test_class).to receive(:new).with('subject')

        # field expander instance receives call to expand_fields
        expect(field_expander_test_instance).to receive(:expand_fields).and_return(expanded_fields)

        # the term expander is initialised with the result of the field expansion & blank ses data, as well as the search
        # term
        expect(term_expander_test_class).to receive(:new).with(expanded_fields: expanded_fields, search_term: "housing crisis")

        # term expander receives call to expand terms
        expect(term_expander_test_instance).to receive(:expand_terms).and_return('processed tokens')

        # the term combiner is initialised with the response from expand terms in an array
        expect(term_combiner_test_class).to receive(:new).with(['processed tokens'])

        # the term combiner recieves call to combine the terms
        expect(term_combiner_test_instance).to receive(:combine_terms).and_return("combined terms")

        # the method returns the result from the term combiner
        expect(query_expander.expand_query).to eq("combined terms")
      end
    end

    context 'where the term is an unquoted string with a specified field' do
      let(:search_query) { ['subject:housing'] }
      it 'expands on fields and terms' do
        # tokeniser is initialised with the query string
        expect(tokeniser_test_class).to receive(:new).with(["subject:housing"])

        # tokeniser instance receives call to tokenise
        expect(tokeniser_test_instance).to receive(:tokenise).and_return([[:specified_field, 'subject:housing']])

        # SES query class is initialised with the search term (only)
        expect(ses_test_class).to receive(:new).with({ value: "housing" })

        # SES query instance receives call for data
        expect(ses_test_instance).to receive(:data).and_return(ses_response)

        # field expander class is initialised with the field name (only)
        expect(field_expander_test_class).to receive(:new).with('subject')

        # field expander instance receives call to expand_fields
        expect(field_expander_test_instance).to receive(:expand_fields).and_return(expanded_fields)

        # the term expander is initialised with the result of the field expansion & ses data, as well as the search
        # term
        expect(term_expander_test_class).to receive(:new).with(expanded_fields: expanded_fields, ses_data: ses_response, search_term: "housing")

        # term expander receives call to expand terms
        expect(term_expander_test_instance).to receive(:expand_terms).and_return('processed tokens')

        # the term combiner is initialised with the response from expand terms in an array
        expect(term_combiner_test_class).to receive(:new).with(['processed tokens'])

        # the term combiner recieves call to combine the terms
        expect(term_combiner_test_instance).to receive(:combine_terms).and_return("combined terms")

        # the method returns the result from the term combiner
        expect(query_expander.expand_query).to eq("combined terms")
      end
    end

    context 'where the term is a double-quoted phrase without a specified field' do
      let(:search_query) { ['"housing crisis"'] }
      it 'expands on fields and terms' do
        # tokeniser is initialised with the query string
        expect(tokeniser_test_class).to receive(:new).with(["\"housing crisis\""])

        # tokeniser instance receives call to tokenise
        expect(tokeniser_test_instance).to receive(:tokenise).and_return([[:quoted_phrase, '"housing crisis"']])

        # SES query class is initialised with the search term (only)
        expect(ses_test_class).to receive(:new).with({ value: "\"housing crisis\"" })

        # SES query instance receives call for data
        expect(ses_test_instance).to receive(:data).and_return(ses_response)

        # field expander class is initialised with the field name "none"
        expect(field_expander_test_class).to receive(:new).with('none')

        # field expander instance receives call to expand_fields
        expect(field_expander_test_instance).to receive(:expand_fields).and_return(expanded_fields)

        # the term expander is initialised with the result of the field expansion & ses data, as well as the search
        # term
        expect(term_expander_test_class).to receive(:new).with(expanded_fields: expanded_fields, ses_data: ses_response, search_term: "\"housing crisis\"")

        # term expander receives call to expand terms
        expect(term_expander_test_instance).to receive(:expand_terms).and_return('processed tokens')

        # the term combiner is initialised with the response from expand terms in an array
        expect(term_combiner_test_class).to receive(:new).with(['processed tokens'])

        # the term combiner recieves call to combine the terms
        expect(term_combiner_test_instance).to receive(:combine_terms).and_return("combined terms")

        # the method returns the result from the term combiner
        expect(query_expander.expand_query).to eq("combined terms")
      end
    end

    context 'where the term is a single-quoted phrase without a specified field' do
      let(:search_query) { ["'housing crisis'"] }
      it 'expands on fields and terms' do
        # tokeniser is initialised with the query string
        expect(tokeniser_test_class).to receive(:new).with(["'housing crisis'"])

        # tokeniser instance receives call to tokenise
        expect(tokeniser_test_instance).to receive(:tokenise).and_return([[:quoted_phrase, "'housing crisis'"]])

        # SES query class is initialised with the search term (only)
        expect(ses_test_class).to receive(:new).with({ value: "'housing crisis'" })

        # SES query instance receives call for data
        expect(ses_test_instance).to receive(:data).and_return(ses_response)

        # field expander class is initialised with the field name "none"
        expect(field_expander_test_class).to receive(:new).with('none')

        # field expander instance receives call to expand_fields
        expect(field_expander_test_instance).to receive(:expand_fields).and_return(expanded_fields)

        # the term expander is initialised with the result of the field expansion & ses data, as well as the search
        # term
        expect(term_expander_test_class).to receive(:new).with(expanded_fields: expanded_fields, ses_data: ses_response, search_term: "'housing crisis'")

        # term expander receives call to expand terms
        expect(term_expander_test_instance).to receive(:expand_terms).and_return('processed tokens')

        # the term combiner is initialised with the response from expand terms in an array
        expect(term_combiner_test_class).to receive(:new).with(['processed tokens'])

        # the term combiner recieves call to combine the terms
        expect(term_combiner_test_instance).to receive(:combine_terms).and_return("combined terms")

        # the method returns the result from the term combiner
        expect(query_expander.expand_query).to eq("combined terms")
      end
    end

    context 'where the term is an unquoted string without a specified field' do
      let(:search_query) { ['housing crisis'] }
      it 'expands on fields and terms' do
        # tokeniser is initialised with the query string
        expect(tokeniser_test_class).to receive(:new).with(["housing crisis"])

        # tokeniser instance receives call to tokenise
        expect(tokeniser_test_instance).to receive(:tokenise).and_return([[:unquoted_phrase, 'housing crisis']])

        # SES query class is initialised with the search term (only)
        expect(ses_test_class).to receive(:new).with({ value: "housing crisis" })

        # SES query instance receives call for data
        expect(ses_test_instance).to receive(:data).and_return(ses_response)

        # field expander class is initialised with 'none' (only)
        expect(field_expander_test_class).to receive(:new).with('none')

        # field expander instance receives call to expand_fields
        expect(field_expander_test_instance).to receive(:expand_fields).and_return(expanded_fields)

        # the term expander is initialised with the result of the field expansion & ses data, as well as the search
        # term
        expect(term_expander_test_class).to receive(:new).with(expanded_fields: expanded_fields, ses_data: ses_response, search_term: "housing crisis")

        # term expander receives call to expand terms
        expect(term_expander_test_instance).to receive(:expand_terms).and_return('processed tokens')

        # the term combiner is initialised with the response from expand terms in an array
        expect(term_combiner_test_class).to receive(:new).with(['processed tokens'])

        # the term combiner recieves call to combine the terms
        expect(term_combiner_test_instance).to receive(:combine_terms).and_return("combined terms")

        # the method returns the result from the term combiner
        expect(query_expander.expand_query).to eq("combined terms")
      end
    end

    context 'where the term is wrapped in square brackets' do
      let(:search_query) { ["[housing crisis]"] }
      it 'no expansion needed' do
        # tokeniser is initialised with the query string
        expect(tokeniser_test_class).to receive(:new).with(["[housing crisis]"])

        # tokeniser instance receives call to tokenise
        expect(tokeniser_test_instance).to receive(:tokenise).and_return([[:no_expansion, "[housing crisis]"]])

        # SES query class is not initialised
        expect(ses_test_class).not_to receive(:new)

        # SES query instance does not receive call for data
        expect(ses_test_instance).not_to receive(:data)

        # field expander class is not initialised
        expect(field_expander_test_class).not_to receive(:new).with('none')

        # field expander instance doesn't receive call to expand_fields
        expect(field_expander_test_instance).not_to receive(:expand_fields)

        # the term expander is not initialised
        expect(term_expander_test_class).not_to receive(:new)

        # term expander does not receive call to expand terms
        expect(term_expander_test_instance).not_to receive(:expand_terms)

        # the term combiner is initialised with the terms from the tokeniser
        expect(term_combiner_test_class).to receive(:new).with(['housing crisis'])

        # the term combiner recieves call to combine the terms
        expect(term_combiner_test_instance).to receive(:combine_terms).and_return("combined terms")

        # the method returns the result from the term combiner
        expect(query_expander.expand_query).to eq("combined terms")
      end
    end
  end
end