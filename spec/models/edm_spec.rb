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

  describe 'session' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(edm.session).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:edm) { Edm.new({ 'session_t' => [] }) }
      it 'returns nil' do
        expect(edm.session).to be_nil
      end
    end

    context 'where data exists' do
      let!(:edm) { Edm.new({ 'session_t' => ['first item', 'second item'] }) }

      it 'returns the first item' do
        expect(edm.session).to eq('first item')
      end
    end
  end

  describe 'reference' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(edm.reference).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:edm) { Edm.new({ 'identifier_t' => [] }) }
      it 'returns nil' do
        expect(edm.reference).to be_nil
      end
    end

    context 'where data exists' do
      let!(:edm) { Edm.new({ 'identifier_t' => ['first item', 'second item'] }) }

      it 'returns the first item' do
        expect(edm.reference).to eq('first item')
      end
    end
  end

  describe 'other_supporters' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(edm.other_supporters).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:edm) { Edm.new({ 'signedMember_ses' => [] }) }
      it 'returns nil' do
        expect(edm.other_supporters).to be_nil
      end
    end

    context 'where data exists' do
      let!(:edm) { Edm.new({ 'signedMember_ses' => ['first item', 'second item'] }) }

      it 'returns all items' do
        expect(edm.other_supporters).to eq(['first item', 'second item'])
      end
    end
  end

  describe 'registered_interest_declared' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(edm.registered_interest_declared).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:edm) { Edm.new({ 'registeredInterest_b' => [] }) }
      it 'returns nil' do
        expect(edm.registered_interest_declared).to be_nil
      end
    end

    context 'where data exists' do
      context 'where first item is false' do
        let!(:edm) { Edm.new({ 'registeredInterest_b' => ['false'] }) }

        it 'returns "no"' do
          expect(edm.registered_interest_declared).to eq('No')
        end
      end
      context 'where first item is true' do
        let!(:edm) { Edm.new({ 'registeredInterest_b' => ['true'] }) }

        it 'returns "yes"' do
          expect(edm.registered_interest_declared).to eq('Yes')
        end
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
        it 'returns a date object for the first item' do
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

  describe 'legislation' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(edm.legislation).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:edm) { Edm.new({ 'legislationTitle_ses' => [] }) }
      it 'returns nil' do
        expect(edm.legislation).to be_nil
      end
    end

    context 'where data exists' do
      let!(:edm) { Edm.new({ 'legislationTitle_ses' => [12345, 67890] }) }

      it 'returns all items as an array' do
        expect(edm.legislation).to eq([12345, 67890])
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

  describe 'amendment_text' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(edm.amendment_text).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:edm) { Edm.new({ 'amendmentText_t' => [] }) }
      it 'returns nil' do
        expect(edm.amendment_text).to be_nil
      end
    end

    context 'where data exists' do
      let!(:edm) { Edm.new({ 'amendmentText_t' => ['first item', 'second item'] }) }

      it 'returns all items' do
        expect(edm.amendment_text).to eq(['first item', 'second item'])
      end
    end
  end

  describe 'amendments' do
    context 'where there  is missing data' do
      let!(:edm) { Edm.new({}) }

      it 'returns nil' do
        expect(edm.amendments).to eq(nil)
      end
    end

    context 'where there is more than one amendment' do
      let!(:edm) { Edm.new({
                             'amendmentText_t' => ['first item', 'second item'],
                             'amendment_numberOfSignatures_s' => [20, 10],
                             'amendment_primarySponsorPrinted_t' => ['sponsor one', 'sponsor two'],
                             'amendment_primarySponsorParty_ses' => [12345, 54321],
                             'identifier_t' => ['main id', 'amendment 1 id', 'amendment 2 id'],
                             'amendment_dateTabled_dt' => [DateTime.commercial(2022), DateTime.commercial(2021)],
                           }) }

      it 'returns nil' do
        expect(edm.amendments).to be_nil
      end
    end

    context 'where all data is present for one amendment' do
      let!(:edm) { Edm.new({
                             'amendmentText_t' => ['first item'],
                             'amendment_numberOfSignatures_s' => [20],
                             'amendment_primarySponsorPrinted_t' => ['sponsor one'],
                             'amendment_primarySponsorParty_ses' => [12345],
                             'identifier_t' => ['main id', 'amendment 1 id'],
                             'amendment_dateTabled_dt' => [DateTime.commercial(2022)],
                           }) }

      it 'returns all data grouped by amendment' do
        expect(edm.amendments).to eq(
                                    [{
                                       date_tabled: DateTime.commercial(2022),
                                       index: 0,
                                       number_of_signatures: 20,
                                       primary_sponsor: 'sponsor one',
                                       primary_sponsor_party: 12345,
                                       reference: 'amendment 1 id',
                                       text: 'first item'
                                     }
                                    ]
                                  )
      end
    end
  end

  describe 'display_link' do
    context 'no links are present' do
      let!(:edm) { Edm.new({ 'internalLocation_uri' => [], 'externalLocation_uri' => [] }) }

      it 'returns nil' do
        expect(edm.display_link).to be_nil
      end
    end

    context 'internal link is present, external link is not present' do
      let!(:edm) { Edm.new({ 'internalLocation_uri' => ['www.example.com'], 'externalLocation_uri' => [] }) }

      it 'returns nil' do
        expect(edm.display_link).to be_nil
      end
    end

    context 'internal link is present, external link is present' do
      let!(:edm) { Edm.new({ 'internalLocation_uri' => ['www.example.com'], 'externalLocation_uri' => ['www.test.com'] }) }

      it 'returns the external link' do
        expect(edm.display_link).to eq('www.test.com')
      end
    end

    context 'internal link is not present, external link is present' do
      let!(:edm) { Edm.new({ 'internalLocation_uri' => [], 'externalLocation_uri' => ['www.test.com'] }) }

      it 'returns the external link' do
        expect(edm.display_link).to eq('www.test.com')
      end
    end
  end

end