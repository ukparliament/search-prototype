require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do

  describe 'boolean_yes_no' do
    context 'when given nil' do
      it 'returns no' do
        expect(helper.boolean_yes_no(nil)).to eq('No')
      end
    end
    context 'when given a value of true' do
      let!(:data) { { value: true, field_name: 'field_name' } }
      it 'returns yes' do
        expect(helper.boolean_yes_no(data)).to eq('Yes')
      end
    end
    context 'when given a value of false' do
      let!(:data) { { value: false, field_name: 'field_name' } }
      it 'returns no' do
        expect(helper.boolean_yes_no(data)).to eq('No')
      end
    end
  end

end