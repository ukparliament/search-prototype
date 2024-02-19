require 'rails_helper'

RSpec.describe EuropeanScrutiny, type: :model do
  let!(:european_scrutiny) { EuropeanScrutiny.new({}) }

  describe 'regarding_objects' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(european_scrutiny.regarding_objects).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:european_scrutiny) { EuropeanScrutiny.new({ 'regardingDD_uri' => [], 'regardingDD_t' => [] }) }
      it 'returns nil' do
        expect(european_scrutiny.regarding_objects).to be_nil
      end
    end

    context 'where data exists' do
      let!(:european_scrutiny) { EuropeanScrutiny.new({ 'regardingDD_uri' => ['first link'], 'regardingDD_t' => ['second link'] }) }

      it 'submits a Solr query for the objects' do
        allow_any_instance_of(ObjectsFromUriList).to receive(:get_objects).and_return({ items: ['first item', 'second item'] })
        allow(ObjectsFromUriList).to receive(:new).and_return(ObjectsFromUriList.new(['first link', 'second link']))

        expect(ObjectsFromUriList).to receive(:new).with(['first link', 'second link'])
        expect(european_scrutiny.regarding_objects).to eq({ items: ['first item', 'second item'] })
      end
    end
  end
end