require 'rails_helper'

RSpec.describe PublicAct, type: :model do
  let!(:public_act) { PublicAct.new({}) }

  describe 'template' do
    it 'returns a string' do
      expect(public_act.template).to be_a(String)
    end
  end

  describe 'object_name' do
    it 'returns object type' do
      allow(public_act).to receive(:type).and_return({ value: 12345, field_name: 'type_ses' })
      expect(public_act.object_name).to eq({ value: 12345, field_name: 'type_ses' })
    end
  end

  describe 'reference' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(public_act.reference).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:public_act) { PublicAct.new({ 'identifier_t' => [] }) }
      it 'returns nil' do
        expect(public_act.reference).to be_nil
      end
    end

    context 'where data exists' do
      let!(:public_act) { PublicAct.new({ 'identifier_t' => ['first item', 'second item'] }) }

      it 'returns the first item' do
        expect(public_act.reference).to eq({:field_name=>"identifier_t", :value=>"first item"})
      end
    end
  end

  describe 'subjects' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(public_act.subjects).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:public_act) { PublicAct.new({ 'subject_ses' => [] }) }
      it 'returns nil' do
        expect(public_act.subjects).to be_nil
      end
    end

    context 'where data exists' do
      let!(:public_act) { PublicAct.new({ 'subject_ses' => ['first item', 'second item'] }) }

      it 'returns all items as an array' do
        expect(public_act.subjects).to eq([{:field_name=>"subject_ses", :value=>"first item"}, {:field_name=>"subject_ses", :value=>"second item"}])
      end
    end
  end

  describe 'legislation' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(public_act.legislation).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:public_act) { PublicAct.new({ 'legislationTitle_ses' => [] }) }
      it 'returns nil' do
        expect(public_act.legislation).to be_nil
      end
    end

    context 'where data exists' do
      let!(:public_act) { PublicAct.new({ 'legislationTitle_ses' => [12345, 67890] }) }

      it 'returns all items as an array' do
        expect(public_act.legislation).to eq([{:field_name=>"legislationTitle_ses", :value=>12345}, {:field_name=>"legislationTitle_ses", :value=>67890}])
      end
    end
  end
  
  describe 'bill' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(public_act.bill).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:public_act) { PublicAct.new({ 'legislationTitle_ses' => [] }) }
      it 'returns nil' do
        expect(public_act.bill).to be_nil
      end
    end

    context 'where data exists' do
      let!(:public_act) { PublicAct.new({ 'legislationTitle_ses' => [12345, 67890] }) }

      it 'returns the first legislation item' do
        expect(public_act.bill).to eq({:field_name=>"legislationTitle_ses", :value=>12345})
      end
    end
  end
end