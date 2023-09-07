require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do

  describe 'boolean_yes_no' do
    context 'when given nil' do
      it 'returns no' do
        expect(helper.boolean_yes_no(nil)).to eq('No')
      end
    end
    context 'when given true' do
      it 'returns yes' do
        expect(helper.boolean_yes_no(true)).to eq('Yes')
      end
    end
    context 'when given false' do
      it 'returns no' do
        expect(helper.boolean_yes_no(false)).to eq('No')
      end
    end
  end

end