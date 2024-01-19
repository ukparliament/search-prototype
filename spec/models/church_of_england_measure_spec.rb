require 'rails_helper'

RSpec.describe ChurchOfEnglandMeasure, type: :model do
  let!(:church_of_england_measure) { ChurchOfEnglandMeasure.new({}) }

  describe 'template' do
    it 'returns a string' do
      expect(church_of_england_measure.template).to be_a(String)
    end
  end

  describe 'object_name' do
    it 'returns object type' do
      allow(church_of_england_measure).to receive(:type).and_return({ value: 12345, field_name: 'type_ses' })
      expect(church_of_england_measure.object_name).to eq({ value: 12345, field_name: 'type_ses' })
    end
  end

  describe 'reference' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(church_of_england_measure.reference).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:church_of_england_measure) { ChurchOfEnglandMeasure.new({ 'identifier_t' => [] }) }
      it 'returns nil' do
        expect(church_of_england_measure.reference).to be_nil
      end
    end

    context 'where data exists' do
      let!(:church_of_england_measure) { ChurchOfEnglandMeasure.new({ 'identifier_t' => ['first item', 'second item'] }) }

      it 'returns the first item' do
        expect(church_of_england_measure.reference).to eq({:field_name=>"identifier_t", :value=>"first item"})
      end
    end
  end

  describe 'subjects' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(church_of_england_measure.subjects).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:church_of_england_measure) { ChurchOfEnglandMeasure.new({ 'subject_ses' => [] }) }
      it 'returns nil' do
        expect(church_of_england_measure.subjects).to be_nil
      end
    end

    context 'where data exists' do
      let!(:church_of_england_measure) { ChurchOfEnglandMeasure.new({ 'subject_ses' => ['first item', 'second item'] }) }

      it 'returns all items as an array' do
        expect(church_of_england_measure.subjects).to eq([{:field_name=>"subject_ses", :value=>"first item"}, {:field_name=>"subject_ses", :value=>"second item"}])
      end
    end
  end

  describe 'legislation' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(church_of_england_measure.legislation).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:church_of_england_measure) { ChurchOfEnglandMeasure.new({ 'legislationTitle_ses' => [] }) }
      it 'returns nil' do
        expect(church_of_england_measure.legislation).to be_nil
      end
    end

    context 'where data exists' do
      let!(:church_of_england_measure) { ChurchOfEnglandMeasure.new({ 'legislationTitle_ses' => [12345, 67890] }) }

      it 'returns all items as an array' do
        expect(church_of_england_measure.legislation).to eq([{:field_name=>"legislationTitle_ses", :value=>12345}, {:field_name=>"legislationTitle_ses", :value=>67890}])
      end
    end
  end

  describe 'date_of_royal_assent' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(church_of_england_measure.date_of_royal_assent).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:church_of_england_measure) { ChurchOfEnglandMeasure.new({ 'dateOfRoyalAssent_dt' => [] }) }
      it 'returns nil' do
        expect(church_of_england_measure.date_of_royal_assent).to be_nil
      end
    end

    context 'where data exists' do
      context 'where data is parsable as a datetime (BST)' do
        let!(:church_of_england_measure) { ChurchOfEnglandMeasure.new({ 'dateOfRoyalAssent_dt' => ["2015-06-01T18:00:15.73Z", "2014-06-01T18:00:15.73Z"] }) }

        it 'returns the first string parsed as a datetime in the London timezone' do
          expect(church_of_england_measure.date_of_royal_assent[:value]).to eq("Mon, 01 Jun 2015, 19:00:15.73".in_time_zone('London').to_datetime)
        end
      end
      context 'where data is parsable as a datetime (GMT)' do
        let!(:church_of_england_measure) { ChurchOfEnglandMeasure.new({ 'dateOfRoyalAssent_dt' => ["2015-02-01T18:00:15.73Z", "2014-06-01T18:00:15.73Z"] }) }

        it 'returns the first string parsed as a datetime in the London timezone' do
          expect(church_of_england_measure.date_of_royal_assent[:value]).to eq("Sun, 01 Feb 2015, 18:00:15.73".in_time_zone('London').to_datetime)
        end
      end
      context 'where data is not parsable as a datetime' do
        let!(:church_of_england_measure) { ChurchOfEnglandMeasure.new({ 'dateOfRoyalAssent_dt' => ["first item", "second item"] }) }

        it 'returns nil' do
          expect(church_of_england_measure.date_of_royal_assent).to be_nil
        end
      end
    end
  end
end