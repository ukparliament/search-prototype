require 'rails_helper'

RSpec.describe LinkHelper, type: :helper do
  let!(:mock_ses_data) { { 123 => 'Ses test return' } }
  let!(:input_data_ses) { { value: 123, field_name: 'type_ses' } }
  let!(:input_data_string) { { value: 'Test string', field_name: 'abstract_t' } }

  describe 'search link' do
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
        expect(helper.search_link(input_data_ses)).to eq("<a href=\"/search-prototype/search?filter%5Bfield_name%5D=type_ses&amp;filter%5Bvalue%5D=123\">Ses test return</a>")
      end
    end
    context 'when given a string value and a field name' do
      it 'returns a link to a new search using the string as a query' do
        expect(helper.search_link(input_data_string)).to eq("<a href=\"/search-prototype/search?query=Test+string\">Test string</a>")
      end
    end
  end

  describe 'ses_object_name' do
    context 'when given nil' do
      it 'returns nil' do
        allow(helper).to receive(:ses_data).and_return(mock_ses_data)
        expect(helper.object_display_name(nil)).to eq(nil)
      end
    end
    context 'when given a SES ID and field name' do
      it 'returns the SES name in sentence case' do
        # requires SES data to have been preloaded on the page - this is done for performance reasons
        allow(helper).to receive(:ses_data).and_return(mock_ses_data)
        expect(helper.object_display_name(input_data_ses)).to eq('Ses test return')
      end
    end
    context 'when given string and field name' do
      it 'returns the formatted string' do
        expect(helper.object_display_name(input_data_string)).to eq('Test string')
      end
    end
  end

  describe 'ses_object_name_link' do
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
        expect(helper.object_display_name_link(input_data_ses)).to eq("<a href=\"/search-prototype/search?filter%5Bfield_name%5D=type_ses&amp;filter%5Bvalue%5D=123\">Ses test return</a>")
      end
    end
    context 'when given string and field name' do
      it 'returns a link to search using the string as a query' do
        expect(helper.object_display_name_link(input_data_string)).to eq("<a href=\"/search-prototype/search?filter%5Bfield_name%5D=abstract_t&amp;filter%5Bvalue%5D=Test+string\">Test string</a>")
      end
    end
  end

  describe 'display_name' do
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