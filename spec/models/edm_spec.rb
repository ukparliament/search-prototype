require 'rails_helper'

RSpec.describe Edm, type: :model do
  let!(:edm) { Edm.new({}) }

  describe 'template' do
    it 'returns a string' do
      expect(edm.template).to be_a(String)
    end
  end

  describe 'motion_text' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(edm.motion_text).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:edm) { Edm.new({ 'motionText_t' => [] }) }
      it 'returns nil' do
        expect(edm.motion_text).to be_nil
      end
    end

    context 'where data exists' do
      let!(:edm) { Edm.new({ 'motionText_t' => ['first item', 'second item'] }) }

      it 'returns the first item' do
        expect(edm.motion_text).to eq('first item')
      end
    end
  end

  describe 'primary_sponsor' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(edm.primary_sponsor).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:edm) { Edm.new({ 'primarySponsorPrinted_s' => [] }) }
      it 'returns nil' do
        expect(edm.primary_sponsor).to be_nil
      end
    end

    context 'where data exists' do
      let!(:edm) { Edm.new({ 'primarySponsorPrinted_s' => ['first item', 'second item'] }) }

      it 'returns the first item' do
        expect(edm.primary_sponsor).to eq('first item')
      end
    end
  end

  describe 'date_tabled' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(edm.date_tabled).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:edm) { Edm.new({ 'dateTabled_dt' => [] }) }
      it 'returns nil' do
        expect(edm.date_tabled).to be_nil
      end
    end

    context 'where data exists' do

      context 'where data is a valid date' do
        let!(:edm) { Edm.new({ 'dateTabled_dt' => [Date.today, Date.yesterday] }) }
        it 'returns the first item' do
          expect(edm.date_tabled).to eq(Date.today)
        end
      end
      context 'where data is not a valid date' do
        let!(:edm) { Edm.new({ 'dateTabled_dt' => ['date', 'another date'] }) }
        it 'raises an error' do
          expect { edm.date_tabled }.to raise_error(Date::Error, 'invalid date')
        end
      end
    end
  end

  describe 'bibliographic_citations' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(edm.bibliographic_citations).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:edm) { Edm.new({ 'bibliographicCitation_s' => [] }) }
      it 'returns nil' do
        expect(edm.bibliographic_citations).to be_nil
      end
    end

    context 'where data exists' do
      let!(:edm) { Edm.new({ 'bibliographicCitation_s' => ['first item', 'second item'] }) }

      it 'returns all items as an array' do
        expect(edm.bibliographic_citations).to eq(['first item', 'second item'])
      end
    end
  end

  describe 'subjects' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(edm.subjects).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:edm) { Edm.new({ 'subject_sesrollup' => [] }) }
      it 'returns nil' do
        expect(edm.subjects).to be_nil
      end
    end

    context 'where data exists' do
      let!(:edm) { Edm.new({ 'subject_sesrollup' => ['first item', 'second item'] }) }

      it 'returns all items as an array' do
        expect(edm.subjects).to eq(['first item', 'second item'])
      end
    end
  end

  describe 'external_location_uri' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(edm.external_location_uri).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:edm) { Edm.new({ 'externalLocation_uri' => [] }) }
      it 'returns nil' do
        expect(edm.external_location_uri).to be_nil
      end
    end

    context 'where data exists' do
      let!(:edm) { Edm.new({ 'externalLocation_uri' => ['first item', 'second item'] }) }

      it 'returns the first item' do
        expect(edm.external_location_uri).to eq('first item')
      end
    end
  end

end