require 'rails_helper'

RSpec.describe WrittenCorrection, type: :model do
  let!(:written_correction) { WrittenCorrection.new({}) }

  describe 'template' do
    it 'returns a string' do
      expect(written_correction.template).to be_a(String)
    end
  end

  describe 'object_name' do
    it 'returns object type' do
      allow(written_correction).to receive(:type).and_return({ value: 12345, field_name: 'type_ses' })
      expect(written_correction.object_name).to eq({ value: 12345, field_name: 'type_ses' })
    end
  end

  describe 'reference' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(written_correction.reference).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:written_correction) { WrittenCorrection.new({ 'identifier_t' => [] }) }
      it 'returns nil' do
        expect(written_correction.reference).to be_nil
      end
    end

    context 'where data exists' do
      let!(:written_correction) { WrittenCorrection.new({ 'identifier_t' => ['first item', 'second item'] }) }

      it 'returns all items' do
        expect(written_correction.reference).to eq([{ :field_name => "identifier_t", :value => "first item" }, { :field_name => "identifier_t", :value => "second item" }])
      end
    end
  end

  describe 'correction_text' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(written_correction.correction_text).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:written_correction) { WrittenCorrection.new({ 'correctionText_t' => [] }) }
      it 'returns nil' do
        expect(written_correction.correction_text).to be_nil
      end
    end

    context 'where data exists' do
      let!(:written_correction) { WrittenCorrection.new({ 'correctionText_t' => ['first item', 'second item'] }) }

      it 'returns the first item' do
        expect(written_correction.correction_text).to eq({:field_name=>"correctionText_t", :value=>"first item"})
      end
    end
  end

  describe 'correcting_member' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(written_correction.correcting_member).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:written_correction) { WrittenCorrection.new({ 'member_ses' => [] }) }
      it 'returns nil' do
        expect(written_correction.correcting_member).to be_nil
      end
    end

    context 'where data exists' do
      let!(:written_correction) { WrittenCorrection.new({ 'correctingMember_ses' => [12345, 54321] }) }

      it 'returns the first item' do
        expect(written_correction.correcting_member).to eq({:field_name=>"correctingMember_ses", :value=>12345})
      end
    end
  end

  describe 'correcting_member_party' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(written_correction.correcting_member_party).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:written_correction) { WrittenCorrection.new({ 'memberParty_ses' => [] }) }
      it 'returns nil' do
        expect(written_correction.correcting_member_party).to be_nil
      end
    end

    context 'where data exists' do
      let!(:written_correction) { WrittenCorrection.new({ 'correctingMemberParty_ses' => [12345, 54321] }) }

      it 'returns the first item' do
        expect(written_correction.correcting_member_party).to eq({:field_name=>"correctingMemberParty_ses", :value=>12345})
      end
    end
  end

  describe 'subjects' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(written_correction.subjects).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:written_correction) { WrittenCorrection.new({ 'subject_ses' => [] }) }
      it 'returns nil' do
        expect(written_correction.subjects).to be_nil
      end
    end

    context 'where data exists' do
      let!(:written_correction) { WrittenCorrection.new({ 'subject_ses' => ['first item', 'second item'] }) }

      it 'returns all items as an array' do
        expect(written_correction.subjects).to eq([{:field_name=>"subject_ses", :value=>"first item"}, {:field_name=>"subject_ses", :value=>"second item"}])
      end
    end
  end

  describe 'legislation' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(written_correction.legislation).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:written_correction) { WrittenCorrection.new({ 'legislationTitle_ses' => [] }) }
      it 'returns nil' do
        expect(written_correction.legislation).to be_nil
      end
    end

    context 'where data exists' do
      let!(:written_correction) { WrittenCorrection.new({ 'legislationTitle_ses' => [12345, 67890] }) }

      it 'returns all items as an array' do
        expect(written_correction.legislation).to eq([{:field_name=>"legislationTitle_ses", :value=>12345}, {:field_name=>"legislationTitle_ses", :value=>67890}])
      end
    end
  end

  describe 'correction_date' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(written_correction.correction_date).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:written_correction) { WrittenCorrection.new({ 'date_dt' => nil }) }
      it 'returns nil' do
        expect(written_correction.correction_date).to be_nil
      end
    end

    context 'where data exists' do
      context 'where data is parsable as a datetime' do
        let!(:written_correction) { WrittenCorrection.new({ 'date_dt' => "2015-06-01T18:00:15.73Z" }) }

        it 'returns the string parsed as a datetime in the London time zone' do
          expect(written_correction.correction_date).to eq({:field_name=>"date_dt", :value=>"Mon, 01 Jun 2015, 19:00:15.73".in_time_zone('London').to_datetime})
        end
      end
      context 'where data is not parsable as a datetime' do
        let!(:written_correction) { WrittenCorrection.new({ 'date_dt' => "not a datetime" }) }

        it 'returns nil' do
          expect(written_correction.correction_date).to be_nil
        end
      end
    end
  end
end