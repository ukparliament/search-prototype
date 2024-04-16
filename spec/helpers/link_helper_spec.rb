require 'rails_helper'

RSpec.describe LinkHelper, type: :helper do
  describe 'search link' do
    let!(:mock_ses_data) { { 123 => 'Smith, John' } }
    let!(:input_data_ses) { { value: 123, field_name: 'member_ses' } }
    let!(:input_data_string) { { value: 'John Smith', field_name: 'memberPrinted_t' } }

    # used for member names etc
    context 'when given nil' do
      it 'returns nil' do
        allow(helper).to receive(:ses_data).and_return(mock_ses_data)
        expect(helper.search_link(nil)).to eq(nil)
      end
    end
    context 'when given a SES ID & field name' do
      it 'returns a link to a new search using the SES ID as a filter for the given field' do
        # requires SES data to have been preloaded on the page - this is done for performance reasons
        allow(helper).to receive(:ses_data).and_return(mock_ses_data)
        expect(helper.search_link(input_data_ses)).to eq("<a href=\"/search-prototype/search?filter%5Bmember_ses%5D%5B%5D=123\">John Smith</a>")
      end
    end
    context 'when given a string value and a field name' do
      it 'returns a link to a new search using the string as a filter for the given field' do
        expect(helper.search_link(input_data_string)).to eq("<a href=\"/search-prototype/search?filter%5BmemberPrinted_t%5D%5B%5D=John+Smith\">John Smith</a>")
      end
    end
  end

  describe 'object_display_name' do
    # used for object names that aren't links, e.g. secondary information titles

    let!(:mock_ses_data) { { 123 => 'Early day motions' } }
    let!(:input_data_ses) { { value: 123, field_name: 'type_ses' } }
    let!(:input_data_string) { { value: 'Early day motions', field_name: 'type_t' } }

    context 'when given nil' do
      it 'returns nil' do
        allow(helper).to receive(:ses_data).and_return(mock_ses_data)
        expect(helper.object_display_name(nil)).to eq(nil)
      end
    end

    context 'when given a SES ID and field name' do
      # requires SES data to have been preloaded on the page - this is done for performance reasons
      context 'default behaviour' do
        it 'returns the SES name in lower case' do
          allow(helper).to receive(:ses_data).and_return(mock_ses_data)
          expect(helper.object_display_name(input_data_ses)).to eq('Early day motion')
        end
      end
      context 'when called with case formatting true' do
        it 'returns the SES name in lower case' do
          allow(helper).to receive(:ses_data).and_return(mock_ses_data)
          expect(helper.object_display_name(input_data_ses, case_formatting: true)).to eq('early day motion')
        end
        context 'where the SES data contains excluded words' do
          let!(:mock_ses_data) { { 123 => 'Church of England Measure' } }
          let!(:input_data_ses) { { value: 123, field_name: 'type_ses' } }
          it 'retains capitalisation for excluded words' do
            allow(helper).to receive(:ses_data).and_return(mock_ses_data)
            expect(helper.object_display_name(input_data_ses, case_formatting: true)).to eq('Church of England measure')
          end
        end
      end
      context 'where called with singularisation disabled' do
        let!(:mock_ses_data) { { 123 => 'Early day motions' } }
        let!(:input_data_ses) { { value: 123, field_name: 'type_ses' } }
        it 'returns the plural term' do
          allow(helper).to receive(:ses_data).and_return(mock_ses_data)
          expect(helper.object_display_name(input_data_ses, singular: false)).to eq('Early day motions')
        end
      end
    end

    context 'when given string and field name' do
      context 'default behaviour' do
        it 'returns the formatted string' do
          expect(helper.object_display_name(input_data_string)).to eq('Early day motion')
        end
      end
      context 'when called with case formatting true' do
        it 'returns the formatted string in lower case' do
          expect(helper.object_display_name(input_data_string, case_formatting: true)).to eq('early day motion')
        end
        context 'when given a string including excluded words' do
          let!(:input_data_string) { { value: 'Church of England Measure', field_name: 'type_t' } }
          it 'retains capitalisation of the excluded words' do
            expect(helper.object_display_name(input_data_string, case_formatting: true)).to eq('Church of England measure')
          end
        end
      end
      context 'where called with singularisation disabled' do
        it 'returns the plural term' do
          expect(helper.object_display_name(input_data_string, singular: false)).to eq('Early day motions')
        end
      end
    end
  end

  describe 'object_display_name_link' do
    let!(:mock_ses_data) { { 123 => 'Early day motions' } }
    let!(:input_data_ses) { { value: 123, field_name: 'type_ses' } }
    let!(:input_data_string) { { value: 'Early day motions', field_name: 'type_t' } }

    # used in preliminary sentences; defaults to singular
    context 'when given nil' do
      it 'returns nil' do
        allow(helper).to receive(:ses_data).and_return(mock_ses_data)
        expect(helper.object_display_name_link(nil)).to eq(nil)
      end
    end
    context 'when given a SES ID and field name' do
      it 'returns a link to search that SES field with the given ID' do
        # requires SES data to have been preloaded on the page - this is done for performance reasons
        allow(helper).to receive(:ses_data).and_return(mock_ses_data)
        expect(helper.object_display_name_link(input_data_ses)).to eq("<a href=\"/search-prototype/search?filter%5Btype_ses%5D%5B%5D=123\">Early day motion</a>")
      end
    end
    context 'when given string and field name' do
      it 'returns a link to search using the string as a query' do
        expect(helper.object_display_name_link(input_data_string)).to eq("<a href=\"/search-prototype/search?filter%5Btype_t%5D%5B%5D=Early+day+motions\">Early day motion</a>")
      end
    end
    context 'when called with singularisation disabled' do
      it 'returns a link to search using the string as a query, and a plural item name' do
        expect(helper.object_display_name_link(input_data_string, singular: false)).to eq("<a href=\"/search-prototype/search?filter%5Btype_t%5D%5B%5D=Early+day+motions\">Early day motions</a>")
      end
    end
  end

  describe 'format_name' do
    context 'with a SES name that is not a member name' do
      let!(:mock_ses_data) { { 123 => 'Department of One, Two and Three' } }
      let!(:input_data_ses) { { value: 123, field_name: 'department_ses' } }

      it 'returns the name as-is' do
        expect(helper.send(:format_name, input_data_ses, mock_ses_data)).to eq("Department of One, Two and Three")
      end
    end

    context 'with a SES name that is a member name' do
      let!(:mock_ses_data) { { 123 => 'Last, First' } }
      let!(:input_data_ses) { { value: 123, field_name: 'answeringMember_ses' } }

      it 'returns the name correctly formatted' do
        expect(helper.send(:format_name, input_data_ses, mock_ses_data)).to eq("First Last")
      end

      context 'where there are disambiguation brackets' do
        let!(:mock_ses_data) { { 123 => 'Last, First (Constituency)' } }
        let!(:input_data_ses) { { value: 123, field_name: 'answeringMember_ses' } }

        it 'returns first name then last name with brackets afterwards' do
          expect(helper.send(:format_name, input_data_ses, mock_ses_data)).to eq("First Last (Constituency)")
        end
      end
    end
  end

end