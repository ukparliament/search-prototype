require 'rails_helper'

RSpec.describe LinkHelper, type: :helper do
  let!(:mock_ses_data) { { 123 => 'Ses test return' } }

  describe 'ses_object_link' do
    context 'when given nil' do
      it 'returns nil' do
        allow(helper).to receive(:ses_data).and_return(mock_ses_data)
        expect(helper.ses_object_link(nil)).to eq(nil)
      end
    end
    context 'when given an integer' do
      it 'returns a link' do
        allow(helper).to receive(:ses_data).and_return(mock_ses_data)
        expect(helper.ses_object_link(123)).to eq("<a href=\"/search-prototype/search?query=Ses+test+return\">Ses test return</a>")
      end
    end
  end

  describe 'ses_object_name' do
    context 'when given nil' do
      it 'returns nil' do
        allow(helper).to receive(:ses_data).and_return(mock_ses_data)
        expect(helper.ses_object_name(nil)).to eq(nil)
      end
    end
    context 'when given an integer' do
      it 'returns a link' do
        allow(helper).to receive(:ses_data).and_return(mock_ses_data)
        expect(helper.ses_object_name(123)).to eq('ses test return')
      end
    end
  end

  describe 'ses_object_name_link' do
    context 'when given nil' do
      it 'returns nil' do
        allow(helper).to receive(:ses_data).and_return(mock_ses_data)
        expect(helper.ses_object_name_link(nil)).to eq(nil)
      end
    end
    context 'when given an integer' do
      it 'returns a link' do
        allow(helper).to receive(:ses_data).and_return(mock_ses_data)
        expect(helper.ses_object_name_link(123)).to eq("<a href=\"/\">ses test return</a>")
      end
    end
  end

  describe 'display_name' do
    context 'with a standard SES formatted name' do
      it 'returns first name then last name' do
        expect(helper.display_name('Last, First')).to eq("First Last")
      end
    end

    context 'where there are disambiguation brackets' do
      it 'returns first name then last name with brackets afterwards' do
        expect(helper.display_name('Last, First (Constituency)')).to eq("First Last (Constituency)")
      end
    end
  end

end