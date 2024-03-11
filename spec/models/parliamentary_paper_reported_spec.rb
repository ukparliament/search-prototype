require 'rails_helper'

RSpec.describe ParliamentaryPaperReported, type: :model do
  let!(:parliamentary_paper_reported) { ParliamentaryPaperReported.new({}) }

  describe 'template' do
    it 'returns a string' do
      expect(parliamentary_paper_reported.template).to be_a(String)
    end
  end

  describe 'object_name' do
    context 'where a single type is present' do
      let!(:parliamentary_paper_reported) { ParliamentaryPaperReported.new({ 'type_ses' => [12345] }) }

      it 'returns object type' do
        expect(parliamentary_paper_reported.object_name).to eq({ value: 12345, field_name: 'type_ses' })
      end
    end
    context 'where subtypes are present' do
      let!(:parliamentary_paper_reported) { ParliamentaryPaperReported.new({ 'type_ses' => [12345], 'subtype_ses' => [23456, 91561, 67890] }) }

      context 'subtypes includes any of: 91561, 91563, 51288' do
        it 'returns the first subtype not equal to 91561, 91563 or 51288' do
          expect(parliamentary_paper_reported.object_name).to eq({ value: 23456, field_name: 'subtype_ses' })
        end
      end
      context 'subtypes does not include any of: 91561, 91563, 51288' do
        let!(:parliamentary_paper_reported) { ParliamentaryPaperReported.new({ 'type_ses' => [12345], 'subtype_ses' => [23456, 56789, 67890] }) }
        it 'returns the first subtype' do
          expect(parliamentary_paper_reported.object_name).to eq({ value: 23456, field_name: 'subtype_ses' })
        end
      end
    end
  end

  describe 'paper_type' do
    context 'where a single type is present' do
      let!(:parliamentary_paper_reported) { ParliamentaryPaperReported.new({ 'type_ses' => [12345] }) }

      it 'returns nil' do
        expect(parliamentary_paper_reported.paper_type).to be_nil
      end
    end
    context 'where subtypes are present' do
      let!(:parliamentary_paper_reported) { ParliamentaryPaperReported.new({ 'type_ses' => [12345], 'subtype_ses' => [23456, 91561, 67890, 51288] }) }

      context 'subtypes includes any of: 91561, 91563, 51288' do
        it 'returns all subtypes matching 91561, 91563 or 51288' do
          expect(parliamentary_paper_reported.paper_type).to eq([{ value: 91561, field_name: 'subtype_ses' }, { value: 51288, field_name: 'subtype_ses' }])
        end
      end
      context 'subtypes does not include any of: 91561, 91563, 51288' do
        let!(:parliamentary_paper_reported) { ParliamentaryPaperReported.new({ 'type_ses' => [12345], 'subtype_ses' => [23456, 67890] }) }
        it 'returns nil' do
          expect(parliamentary_paper_reported.paper_type).to be_nil
        end
      end
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

      it 'returns all items' do
        expect(parliamentary_paper_reported.reference).to eq([{ :field_name => "identifier_t", :value => "first item" }, { :field_name => "identifier_t", :value => "second item" }])
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
        expect(parliamentary_paper_reported.subjects).to eq([{ :field_name => "subject_ses", :value => "first item" }, { :field_name => "subject_ses", :value => "second item" }])
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
        expect(parliamentary_paper_reported.legislation).to eq([{ :field_name => "legislationTitle_ses", :value => 12345 }, { :field_name => "legislationTitle_ses", :value => 67890 }])
      end
    end
  end
end