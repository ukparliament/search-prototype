require 'rails_helper'

RSpec.describe Bill, type: :model do
  let!(:bill) { Bill.new({}) }

  describe 'template' do
    it 'returns a string' do
      expect(bill.template).to be_a(String)
    end
  end

  describe 'object_name' do
    it 'returns object type' do
      allow(bill).to receive(:type).and_return({ value: 12345, field_name: 'type_ses' })
      expect(bill.object_name).to eq({ value: 12345, field_name: 'type_ses' })
    end
  end

  describe 'reference' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(bill.reference).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:bill) { Bill.new({ 'identifier_t' => [] }) }
      it 'returns nil' do
        expect(bill.reference).to be_nil
      end
    end

    context 'where data exists' do
      let!(:bill) { Bill.new({ 'identifier_t' => ['first item', 'second item'] }) }

      it 'returns the first item' do
        expect(bill.reference).to eq({ :field_name => "identifier_t", :value => "first item" })
      end
    end
  end

  describe 'subjects' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(bill.subjects).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:bill) { Bill.new({ 'subject_ses' => [] }) }
      it 'returns nil' do
        expect(bill.subjects).to be_nil
      end
    end

    context 'where data exists' do
      let!(:bill) { Bill.new({ 'subject_ses' => ['first item', 'second item'] }) }

      it 'returns all items as an array' do
        expect(bill.subjects).to eq([{ :field_name => "subject_ses", :value => "first item" }, { :field_name => "subject_ses", :value => "second item" }])
      end
    end
  end

  describe 'legislation' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(bill.legislation).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:bill) { Bill.new({ 'legislationTitle_ses' => [] }) }
      it 'returns nil' do
        expect(bill.legislation).to be_nil
      end
    end

    context 'where data exists' do
      let!(:bill) { Bill.new({ 'legislationTitle_ses' => [12345, 67890] }) }

      it 'returns all items as an array' do
        expect(bill.legislation).to eq([{ :field_name => "legislationTitle_ses", :value => 12345 }, { :field_name => "legislationTitle_ses", :value => 67890 }])
      end
    end
  end
end