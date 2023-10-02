require 'rails_helper'

RSpec.describe ParliamentaryPaperReported, type: :model do
  let!(:parliamentary_paper_reported) { ParliamentaryPaperReported.new({}) }

  describe 'template' do
    it 'returns a string' do
      expect(parliamentary_paper_reported.template).to be_a(String)
    end
  end

  describe 'object_name' do
    it 'returns a string' do
      expect(parliamentary_paper_reported.object_name).to be_a(String)
    end
  end

  describe 'reference' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(parliamentary_paper_reported.reference).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:parliamentary_paper_reported) { ParliamentaryPaperReported.new({ 'identifier_t' => [] }) }
      it 'returns nil' do
        expect(parliamentary_paper_reported.reference).to be_nil
      end
    end

    context 'where data exists' do
      let!(:parliamentary_paper_reported) { ParliamentaryPaperReported.new({ 'identifier_t' => ['first item', 'second item'] }) }

      it 'returns the first item' do
        expect(parliamentary_paper_reported.reference).to eq('first item')
      end
    end
  end

  describe 'subjects' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(parliamentary_paper_reported.subjects).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:parliamentary_paper_reported) { ParliamentaryPaperReported.new({ 'subject_ses' => [] }) }
      it 'returns nil' do
        expect(parliamentary_paper_reported.subjects).to be_nil
      end
    end

    context 'where data exists' do
      let!(:parliamentary_paper_reported) { ParliamentaryPaperReported.new({ 'subject_ses' => ['first item', 'second item'] }) }

      it 'returns all items as an array' do
        expect(parliamentary_paper_reported.subjects).to eq(['first item', 'second item'])
      end
    end
  end

  describe 'legislation' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(parliamentary_paper_reported.legislation).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:parliamentary_paper_reported) { ParliamentaryPaperReported.new({ 'legislationTitle_ses' => [] }) }
      it 'returns nil' do
        expect(parliamentary_paper_reported.legislation).to be_nil
      end
    end

    context 'where data exists' do
      let!(:parliamentary_paper_reported) { ParliamentaryPaperReported.new({ 'legislationTitle_ses' => [12345, 67890] }) }

      it 'returns all items as an array' do
        expect(parliamentary_paper_reported.legislation).to eq([12345, 67890])
      end
    end
  end
end