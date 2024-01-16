require 'rails_helper'

RSpec.describe PrivateAct, type: :model do
  let!(:private_act) { PrivateAct.new({}) }

  describe 'template' do
    it 'returns a string' do
      expect(private_act.template).to be_a(String)
    end
  end

  describe 'object_name' do
    it 'returns object type' do
      allow(private_act).to receive(:type).and_return({ value: 12345, field_name: 'type_ses' })
      expect(private_act.object_name).to eq({ value: 12345, field_name: 'type_ses' })
    end
  end

  describe 'reference' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(private_act.reference).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:private_act) { PrivateAct.new({ 'identifier_t' => [] }) }
      it 'returns nil' do
        expect(private_act.reference).to be_nil
      end
    end

    context 'where data exists' do
      let!(:private_act) { PrivateAct.new({ 'identifier_t' => ['first item', 'second item'] }) }

      it 'returns the first item' do
        expect(private_act.reference).to eq({ :field_name => "identifier_t", :value => "first item" })
      end
    end
  end

  describe 'subjects' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(private_act.subjects).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:private_act) { PrivateAct.new({ 'subject_ses' => [] }) }
      it 'returns nil' do
        expect(private_act.subjects).to be_nil
      end
    end

    context 'where data exists' do
      let!(:private_act) { PrivateAct.new({ 'subject_ses' => ['first item', 'second item'] }) }

      it 'returns all items as an array' do
        expect(private_act.subjects).to eq([{ :field_name => "subject_ses", :value => "first item" }, { :field_name => "subject_ses", :value => "second item" }])
      end
    end
  end

  describe 'legislation' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(private_act.legislation).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:private_act) { PrivateAct.new({ 'legislationTitle_ses' => [] }) }
      it 'returns nil' do
        expect(private_act.legislation).to be_nil
      end
    end

    context 'where data exists' do
      let!(:private_act) { PrivateAct.new({ 'legislationTitle_ses' => [12345, 67890] }) }

      it 'returns all items as an array' do
        expect(private_act.legislation).to eq([{ :field_name => "legislationTitle_ses", :value => 12345 }, { :field_name => "legislationTitle_ses", :value => 67890 }])
      end
    end
  end

  describe 'bill' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(private_act.bill).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:private_act) { PrivateAct.new({ 'isVersionOf_t' => [] }) }
      it 'returns nil' do
        expect(private_act.bill).to be_nil
      end
    end

    context 'where data exists' do
      let!(:private_act) { PrivateAct.new({ 'isVersionOf_t' => ['uri'] }) }
      let!(:bill) { Bill.new({ 'title_t' => 'bill title' }) }
      let!(:response) { { items: [bill] } }

      it 'returns the associated object from the uri' do
        allow_any_instance_of(ObjectsFromUriList).to receive(:get_objects).and_return(response)
        expect(private_act.bill).to eq(bill)
      end
    end
  end
end