require 'rails_helper'

RSpec.describe ProceedingContribution, type: :model do
  let!(:contribution) { ProceedingContribution.new({}) }

  describe 'template' do
    it 'returns a string' do
      expect(contribution.template).to be_a(String)
    end
  end

  describe 'object_name' do
    context 'where there are no subtypes' do
      let!(:contribution) { ProceedingContribution.new({ 'subtype_ses' => [], 'type_ses' => [54321] }) }

      it 'returns the type in an array' do
        expect(contribution.object_name).to eq({ value: 54321, field_name: 'type_ses' })
      end
    end
    context 'where there is a subtype' do
      let!(:contribution) { ProceedingContribution.new({ 'subtype_ses' => [12345] }) }

      it 'returns the subtype' do
        expect(contribution.object_name).to eq({ value: 12345, field_name: 'subtype_ses' })
      end
    end
  end

  describe 'reference' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(contribution.reference).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:contribution) { ProceedingContribution.new({ 'identifier_t' => [] }) }
      it 'returns nil' do
        expect(contribution.reference).to be_nil
      end
    end

    context 'where data exists' do
      let!(:contribution) { ProceedingContribution.new({ 'identifier_t' => ['first item', 'second item'] }) }

      it 'returns all items' do
        expect(contribution.reference).to eq([{ :field_name => "identifier_t", :value => "first item" }, { :field_name => "identifier_t", :value => "second item" }])
      end
    end
  end

  describe 'subjects' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(contribution.subjects).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:contribution) { ProceedingContribution.new({ 'subject_ses' => [] }) }
      it 'returns nil' do
        expect(contribution.subjects).to be_nil
      end
    end

    context 'where data exists' do
      let!(:contribution) { ProceedingContribution.new({ 'subject_ses' => ['first item', 'second item'] }) }

      it 'returns all items as an array' do
        expect(contribution.subjects).to eq([{:field_name=>"subject_ses", :value=>"first item"}, {:field_name=>"subject_ses", :value=>"second item"}])
      end
    end
  end

  describe 'legislation' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(contribution.legislation).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:contribution) { ProceedingContribution.new({ 'legislationTitle_ses' => [] }) }
      it 'returns nil' do
        expect(contribution.legislation).to be_nil
      end
    end

    context 'where data exists' do
      let!(:contribution) { ProceedingContribution.new({ 'legislationTitle_ses' => [12345, 67890] }) }

      it 'returns all items as an array' do
        expect(contribution.legislation).to eq([{:field_name=>"legislationTitle_ses", :value=>12345}, {:field_name=>"legislationTitle_ses", :value=>67890}])
      end
    end
  end
end