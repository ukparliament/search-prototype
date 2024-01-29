require 'rails_helper'

RSpec.describe StatutoryInstrument, type: :model do
  let!(:statutory_instrument) { StatutoryInstrument.new({}) }

  describe 'template' do
    it 'returns a string' do
      expect(statutory_instrument.template).to be_a(String)
    end
  end

  describe 'object_name' do
    context 'where there are no subtypes' do
      let!(:statutory_instrument) { StatutoryInstrument.new({ 'subtype_ses' => [], 'type_ses' => [54321] }) }

      it 'returns the type in an array' do
        expect(statutory_instrument.object_name).to eq([{ value: 54321, field_name: 'type_ses' }])
      end
    end
    context 'where there is one subtype' do
      let!(:statutory_instrument) { StatutoryInstrument.new({ 'subtype_ses' => [12345] }) }

      it 'returns the subtype' do
        expect(statutory_instrument.object_name).to eq([{ value: 12345, field_name: 'subtype_ses' }])
      end
    end
    context 'where there are multiple subtypes' do
      let!(:statutory_instrument) { StatutoryInstrument.new({ 'subtype_ses' => [12345, 67890] }) }

      it 'returns the subtypes' do
        expect(statutory_instrument.object_name).to eq([{ value: 12345, field_name: 'subtype_ses' }, { value: 67890, field_name: 'subtype_ses' }])
      end
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

      it 'returns all items' do
        expect(statutory_instrument.reference).to eq([{ :field_name => "identifier_t", :value => "first item" }, { :field_name => "identifier_t", :value => "second item" }])
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
        expect(statutory_instrument.subjects).to eq([{ :field_name => "subject_ses", :value => "first item" }, { :field_name => "subject_ses", :value => "second item" }])
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
        expect(statutory_instrument.legislation).to eq([{ :field_name => "legislationTitle_ses", :value => 12345 }, { :field_name => "legislationTitle_ses", :value => 67890 }])
      end
    end
  end

  describe 'withdrawn?' do
    context 'where withdrawn boolean is true' do
      let!(:statutory_instrument) { StatutoryInstrument.new({ 'withdrawn_b' => ['true'] }) }

      it 'returns a hash with a value of true' do
        expect(statutory_instrument.is_withdrawn).to eq({ field_name: 'withdrawn_b', value: true })
      end
    end
    context 'where withdrawn boolean is false' do
      let!(:statutory_instrument) { StatutoryInstrument.new({ 'withdrawn_b' => ['false'] }) }

      it 'returns a hash with a value of false' do
        expect(statutory_instrument.is_withdrawn).to eq({ field_name: 'withdrawn_b', value: false })
      end
    end
  end
end