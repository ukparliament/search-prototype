require 'rails_helper'

RSpec.describe EuropeanScrutiny, type: :model do
  let!(:european_scrutiny) { EuropeanScrutiny.new({}) }

  describe 'regarding_object_ids' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(european_scrutiny.regarding_object_ids).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:european_scrutiny) { EuropeanScrutiny.new({ 'regardingDD_uri' => [], 'regardingDD_t' => [] }) }
      it 'returns nil' do
        expect(european_scrutiny.regarding_object_ids).to be_nil
      end
    end

    context 'where data exists' do
      let!(:european_scrutiny) { EuropeanScrutiny.new({ 'regardingDD_uri' => ['first link'], 'regardingDD_t' => ['second link'] }) }

      it 'returns the URIs for the object' do
        expect(european_scrutiny.regarding_object_ids).to eq(['first link', 'second link'])
      end
    end
  end
end