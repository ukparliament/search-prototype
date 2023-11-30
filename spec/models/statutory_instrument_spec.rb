require 'rails_helper'

RSpec.describe StatutoryInstrument, type: :model do
  let!(:statutory_instrument) { StatutoryInstrument.new({}) }

  describe 'template' do
    it 'returns a string' do
      expect(statutory_instrument.template).to be_a(String)
    end
  end

  describe 'object_name' do
    it 'returns object type' do
      allow(statutory_instrument).to receive(:type).and_return({ value: 12345, field_name: 'type_ses' })
      expect(statutory_instrument.object_name).to eq({ value: 12345, field_name: 'type_ses' })
    end
  end

  describe 'reference' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(statutory_instrument.reference).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:statutory_instrument) { StatutoryInstrument.new({ 'identifier_t' => [] }) }
      it 'returns nil' do
        expect(statutory_instrument.reference).to be_nil
      end
    end

    context 'where data exists' do
      let!(:statutory_instrument) { StatutoryInstrument.new({ 'identifier_t' => ['first item', 'second item'] }) }

      it 'returns the first item' do
        expect(statutory_instrument.reference).to eq({:field_name=>"identifier_t", :value=>"first item"})
      end
    end
  end

  describe 'subjects' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(statutory_instrument.subjects).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:statutory_instrument) { StatutoryInstrument.new({ 'subject_ses' => [] }) }
      it 'returns nil' do
        expect(statutory_instrument.subjects).to be_nil
      end
    end

    context 'where data exists' do
      let!(:statutory_instrument) { StatutoryInstrument.new({ 'subject_ses' => ['first item', 'second item'] }) }

      it 'returns all items as an array' do
        expect(statutory_instrument.subjects).to eq([{:field_name=>"subject_ses", :value=>"first item"}, {:field_name=>"subject_ses", :value=>"second item"}])
      end
    end
  end

  describe 'legislation' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(statutory_instrument.legislation).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:statutory_instrument) { StatutoryInstrument.new({ 'legislationTitle_ses' => [] }) }
      it 'returns nil' do
        expect(statutory_instrument.legislation).to be_nil
      end
    end

    context 'where data exists' do
      let!(:statutory_instrument) { StatutoryInstrument.new({ 'legislationTitle_ses' => [12345, 67890] }) }

      it 'returns all items as an array' do
        expect(statutory_instrument.legislation).to eq([{:field_name=>"legislationTitle_ses", :value=>12345}, {:field_name=>"legislationTitle_ses", :value=>67890}])
      end
    end
  end
end