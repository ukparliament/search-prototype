require 'rails_helper'

RSpec.describe Edm, type: :model do
  let!(:edm) { Edm.new({}) }

  describe 'template' do
    it 'returns a string' do
      expect(edm.template).to be_a(String)
    end
  end

  describe 'motion_text' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(edm.motion_text).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:edm) { Edm.new({ 'motionText_t' => [] }) }
      it 'returns nil' do
        expect(edm.motion_text).to be_nil
      end
    end

    context 'where data exists' do
      let!(:edm) { Edm.new({ 'motionText_t' => ['first item', 'second item'] }) }

      it 'returns the first item' do
        expect(edm.motion_text).to eq('first item')
      end
    end
  end

end