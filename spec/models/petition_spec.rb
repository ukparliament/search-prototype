require 'rails_helper'

RSpec.describe Petition, type: :model do
  let!(:petition) { Petition.new({}) }

  describe 'template' do
    it 'returns a string' do
      expect(petition.template).to be_a(String)
    end
  end

  describe 'object_name' do
    it 'returns object type' do
      allow(petition).to receive(:type).and_return({ value: 12345, field_name: 'type_ses' })
      allow(petition).to receive(:subtype).and_return({ value: 23456, field_name: 'subtype_ses' })
      expect(petition.object_name).to eq({ value: 23456, field_name: 'subtype_ses' })
    end
  end

  describe 'reference' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(petition.reference).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:petition) { Petition.new({ 'identifier_t' => [] }) }
      it 'returns nil' do
        expect(petition.reference).to be_nil
      end
    end

    context 'where data exists' do
      let!(:petition) { Petition.new({ 'identifier_t' => ['first item', 'second item'] }) }

      it 'returns all items' do
        expect(petition.reference).to eq([{ :field_name => "identifier_t", :value => "first item" }, { :field_name => "identifier_t", :value => "second item" }])
      end
    end
  end

  describe 'subjects' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(petition.subjects).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:petition) { Petition.new({ 'subject_ses' => [] }) }
      it 'returns nil' do
        expect(petition.subjects).to be_nil
      end
    end

    context 'where data exists' do
      let!(:petition) { Petition.new({ 'subject_ses' => ['first item', 'second item'] }) }

      it 'returns all items as an array' do
        expect(petition.subjects).to eq([{ :field_name => "subject_ses", :value => "first item" }, { :field_name => "subject_ses", :value => "second item" }])
      end
    end
  end

  describe 'legislation' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(petition.legislation).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:petition) { Petition.new({ 'legislationTitle_ses' => [] }) }
      it 'returns nil' do
        expect(petition.legislation).to be_nil
      end
    end

    context 'where data exists' do
      let!(:petition) { Petition.new({ 'legislationTitle_ses' => [12345, 67890] }) }

      it 'returns all items as an array' do
        expect(petition.legislation).to eq([{ :field_name => "legislationTitle_ses", :value => 12345 }, { :field_name => "legislationTitle_ses", :value => 67890 }])
      end
    end
  end

  describe 'content' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(petition.content).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:petition) { Petition.new({ 'abstract_t' => [], 'petitionText_t' => [] }) }
      it 'returns nil' do
        expect(petition.content).to be_nil
      end
    end

    context 'where data exists' do
      context 'where abstract is populated but petition text is not' do
        let!(:petition) { Petition.new({ 'abstract_t' => 'test', 'petitionText_t' => [] }) }

        it 'returns abstract' do
          expect(petition.content).to eq({ :field_name => "abstract_t", :value => 'test' })
        end
      end
      context 'where petition text is populated but abstract is not' do
        let!(:petition) { Petition.new({ 'abstract_t' => nil, 'petitionText_t' => ['test 1', 'test 2'] }) }

        it 'returns first petition text item' do
          expect(petition.content).to eq({ :field_name => "petitionText_t", :value => 'test 1' })
        end
      end
      context 'where both petition text and abstract are populated' do
        let!(:petition) { Petition.new({ 'abstract_t' => 'test 1', 'petitionText_t' => ['test 2', 'test 3'] }) }

        it 'returns abstract' do
          expect(petition.content).to eq({ :field_name => "abstract_t", :value => 'test 1' })
        end
      end
    end
  end

end