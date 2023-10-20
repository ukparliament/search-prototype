require 'rails_helper'

RSpec.describe ObservationsOnAPetition, type: :model do
  let!(:observations_on_a_petition) { ObservationsOnAPetition.new({}) }

  describe 'template' do
    it 'returns a string' do
      expect(observations_on_a_petition.template).to be_a(String)
    end
  end

  describe 'reference' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(observations_on_a_petition.reference).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:observations_on_a_petition) { ObservationsOnAPetition.new({ 'identifier_t' => [] }) }
      it 'returns nil' do
        expect(observations_on_a_petition.reference).to be_nil
      end
    end

    context 'where data exists' do
      let!(:observations_on_a_petition) { ObservationsOnAPetition.new({ 'identifier_t' => ['first item', 'second item'] }) }

      it 'returns the first item' do
        expect(observations_on_a_petition.reference).to eq('first item')
      end
    end
  end

  describe 'subjects' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(observations_on_a_petition.subjects).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:observations_on_a_petition) { ObservationsOnAPetition.new({ 'subject_ses' => [] }) }
      it 'returns nil' do
        expect(observations_on_a_petition.subjects).to be_nil
      end
    end

    context 'where data exists' do
      let!(:observations_on_a_petition) { ObservationsOnAPetition.new({ 'subject_ses' => ['first item', 'second item'] }) }

      it 'returns all items as an array' do
        expect(observations_on_a_petition.subjects).to eq(['first item', 'second item'])
      end
    end
  end

  describe 'legislation' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(observations_on_a_petition.legislation).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:observations_on_a_petition) { ObservationsOnAPetition.new({ 'legislationTitle_ses' => [] }) }
      it 'returns nil' do
        expect(observations_on_a_petition.legislation).to be_nil
      end
    end

    context 'where data exists' do
      let!(:observations_on_a_petition) { ObservationsOnAPetition.new({ 'legislationTitle_ses' => [12345, 67890] }) }

      it 'returns all items as an array' do
        expect(observations_on_a_petition.legislation).to eq([12345, 67890])
      end
    end
  end
end