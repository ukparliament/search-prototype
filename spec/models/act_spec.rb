require 'rails_helper'

RSpec.describe Act, type: :model do
  let!(:act) { Act.new({}) }

  describe 'template' do
    it 'returns a string' do
      expect(act.template).to be_a(String)
    end
  end

  describe 'object_name' do
    it 'returns a string' do
      expect(act.object_name).to be_a(String)
    end
  end

  describe 'reference' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(act.reference).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:act) { Act.new({ 'identifier_t' => [] }) }
      it 'returns nil' do
        expect(act.reference).to be_nil
      end
    end

    context 'where data exists' do
      let!(:act) { Act.new({ 'identifier_t' => ['first item', 'second item'] }) }

      it 'returns the first item' do
        expect(act.reference).to eq('first item')
      end
    end
  end

  describe 'subjects' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(act.subjects).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:act) { Act.new({ 'subject_ses' => [] }) }
      it 'returns nil' do
        expect(act.subjects).to be_nil
      end
    end

    context 'where data exists' do
      let!(:act) { Act.new({ 'subject_ses' => ['first item', 'second item'] }) }

      it 'returns all items as an array' do
        expect(act.subjects).to eq(['first item', 'second item'])
      end
    end
  end

  describe 'legislation' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(act.legislation).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:act) { Act.new({ 'legislationTitle_ses' => [] }) }
      it 'returns nil' do
        expect(act.legislation).to be_nil
      end
    end

    context 'where data exists' do
      let!(:act) { Act.new({ 'legislationTitle_ses' => [12345, 67890] }) }

      it 'returns all items as an array' do
        expect(act.legislation).to eq([12345, 67890])
      end
    end
  end
end