require 'rails_helper'

RSpec.describe FormalProceeding, type: :model do
  let!(:formal_proceeding) { FormalProceeding.new({}) }

  describe 'template' do
    it 'returns a string' do
      expect(formal_proceeding.template).to be_a(String)
    end
  end

  describe 'object_name' do
    it 'returns object type' do
      allow(formal_proceeding).to receive(:type).and_return({ value: 12345, field_name: 'type_ses' })
      expect(formal_proceeding.object_name).to eq({ value: 12345, field_name: 'type_ses' })
    end
  end

  describe 'reference' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(formal_proceeding.reference).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:formal_proceeding) { FormalProceeding.new({ 'identifier_t' => [] }) }
      it 'returns nil' do
        expect(formal_proceeding.reference).to be_nil
      end
    end

    context 'where data exists' do
      let!(:formal_proceeding) { FormalProceeding.new({ 'identifier_t' => ['first item', 'second item'] }) }

      it 'returns all items' do
        expect(formal_proceeding.reference).to eq([{ :field_name => "identifier_t", :value => "first item" }, { :field_name => "identifier_t", :value => "second item" }])
      end
    end
  end

  describe 'subjects' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(formal_proceeding.subjects).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:formal_proceeding) { FormalProceeding.new({ 'subject_ses' => [] }) }
      it 'returns nil' do
        expect(formal_proceeding.subjects).to be_nil
      end
    end

    context 'where data exists' do
      let!(:formal_proceeding) { FormalProceeding.new({ 'subject_ses' => ['first item', 'second item'] }) }

      it 'returns all items as an array' do
        expect(formal_proceeding.subjects).to eq([{:field_name=>"subject_ses", :value=>"first item"}, {:field_name=>"subject_ses", :value=>"second item"}])
      end
    end
  end

  describe 'legislation' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(formal_proceeding.legislation).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:formal_proceeding) { FormalProceeding.new({ 'legislationTitle_ses' => [] }) }
      it 'returns nil' do
        expect(formal_proceeding.legislation).to be_nil
      end
    end

    context 'where data exists' do
      let!(:formal_proceeding) { FormalProceeding.new({ 'legislationTitle_ses' => [12345, 67890] }) }

      it 'returns all items as an array' do
        expect(formal_proceeding.legislation).to eq([{:field_name=>"legislationTitle_ses", :value=>12345}, {:field_name=>"legislationTitle_ses", :value=>67890}])
      end
    end
  end
end