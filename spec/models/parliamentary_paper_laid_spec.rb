require 'rails_helper'

RSpec.describe ParliamentaryPaperLaid, type: :model do
  let!(:parliamentary_paper_laid) { ParliamentaryPaperLaid.new({}) }

  describe 'template' do
    it 'returns a string' do
      expect(parliamentary_paper_laid.template).to be_a(String)
    end
  end

  describe 'object_name' do
    it 'returns object type' do
      allow(parliamentary_paper_laid).to receive(:type).and_return({ value: 12345, field_name: 'type_ses' })
      expect(parliamentary_paper_laid.object_name).to eq({ value: 12345, field_name: 'type_ses' })
    end
  end

  describe 'reference' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(parliamentary_paper_laid.reference).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:parliamentary_paper_laid) { ParliamentaryPaperLaid.new({ 'identifier_t' => [] }) }
      it 'returns nil' do
        expect(parliamentary_paper_laid.reference).to be_nil
      end
    end

    context 'where data exists' do
      let!(:parliamentary_paper_laid) { ParliamentaryPaperLaid.new({ 'identifier_t' => ['first item', 'second item'] }) }

      it 'returns all items' do
        expect(parliamentary_paper_laid.reference).to eq([{ :field_name => "identifier_t", :value => "first item" }, { :field_name => "identifier_t", :value => "second item" }])
      end
    end
  end

  describe 'subjects' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(parliamentary_paper_laid.subjects).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:parliamentary_paper_laid) { ParliamentaryPaperLaid.new({ 'subject_ses' => [] }) }
      it 'returns nil' do
        expect(parliamentary_paper_laid.subjects).to be_nil
      end
    end

    context 'where data exists' do
      let!(:parliamentary_paper_laid) { ParliamentaryPaperLaid.new({ 'subject_ses' => ['first item', 'second item'] }) }

      it 'returns all items as an array' do
        expect(parliamentary_paper_laid.subjects).to eq([{:field_name=>"subject_ses", :value=>"first item"}, {:field_name=>"subject_ses", :value=>"second item"}])
      end
    end
  end

  describe 'legislation' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(parliamentary_paper_laid.legislation).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:parliamentary_paper_laid) { ParliamentaryPaperLaid.new({ 'legislationTitle_ses' => [] }) }
      it 'returns nil' do
        expect(parliamentary_paper_laid.legislation).to be_nil
      end
    end

    context 'where data exists' do
      let!(:parliamentary_paper_laid) { ParliamentaryPaperLaid.new({ 'legislationTitle_ses' => [12345, 67890] }) }

      it 'returns all items as an array' do
        expect(parliamentary_paper_laid.legislation).to eq([{:field_name=>"legislationTitle_ses", :value=>12345}, {:field_name=>"legislationTitle_ses", :value=>67890}])
      end
    end
  end
end