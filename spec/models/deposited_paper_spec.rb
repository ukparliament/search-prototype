require 'rails_helper'

RSpec.describe DepositedPaper, type: :model do
  let!(:deposited_paper) { DepositedPaper.new({}) }

  describe 'template' do
    it 'returns a string' do
      expect(deposited_paper.template).to be_a(String)
    end
  end

  describe 'object_name' do
    it 'returns object type' do
      allow(deposited_paper).to receive(:type).and_return({ value: 12345, field_name: 'type_ses' })
      expect(deposited_paper.object_name).to eq({ value: 12345, field_name: 'type_ses' })
    end
  end

  describe 'reference' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(deposited_paper.reference).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:deposited_paper) { DepositedPaper.new({ 'identifier_t' => [] }) }
      it 'returns nil' do
        expect(deposited_paper.reference).to be_nil
      end
    end

    context 'where data exists' do
      let!(:deposited_paper) { DepositedPaper.new({ 'identifier_t' => ['first item', 'second item'] }) }

      it 'returns all items' do
        expect(deposited_paper.reference).to eq([{ :field_name => "identifier_t", :value => "first item" }, { :field_name => "identifier_t", :value => "second item" }])
      end
    end
  end

  describe 'commons_library_location' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(deposited_paper.commons_library_location).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:deposited_paper) { DepositedPaper.new({ 'physicalLocationCommons_t' => [] }) }
      it 'returns nil' do
        expect(deposited_paper.commons_library_location).to be_nil
      end
    end

    context 'where data exists' do
      let!(:deposited_paper) { DepositedPaper.new({ 'physicalLocationCommons_t' => ['first item', 'second item'] }) }

      it 'returns first item' do
        expect(deposited_paper.commons_library_location).to eq({ :field_name => "physicalLocationCommons_t", :value => "first item" })
      end
    end
  end

  describe 'lords_library_location' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(deposited_paper.lords_library_location).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:deposited_paper) { DepositedPaper.new({ 'physicalLocationLords_t' => [] }) }
      it 'returns nil' do
        expect(deposited_paper.lords_library_location).to be_nil
      end
    end

    context 'where data exists' do
      let!(:deposited_paper) { DepositedPaper.new({ 'physicalLocationLords_t' => ['first item', 'second item'] }) }

      it 'returns first item' do
        expect(deposited_paper.lords_library_location).to eq({ :field_name => "physicalLocationLords_t", :value => "first item" })
      end
    end
  end

  describe 'personal_author' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(deposited_paper.personal_author).to be_nil
      end
    end

    context 'where both fields are empty' do
      let!(:deposited_paper) { DepositedPaper.new({ 'personalAuthor_ses' => [], 'personalAuthor_t' => [] }) }
      it 'returns nil' do
        expect(deposited_paper.personal_author).to be_nil
      end
    end

    context 'where personal author ses is present' do
      let!(:deposited_paper) { DepositedPaper.new({ 'personalAuthor_ses' => [12345, 23456], 'personalAuthor_t' => [] }) }
      it 'returns all authors from ses' do
        expect(deposited_paper.personal_author).to eq([{ :field_name => "personalAuthor_ses", :value => 12345 }, { :field_name => "personalAuthor_ses", :value => 23456 }])
      end
    end

    context 'where personal author text is present' do
      let!(:deposited_paper) { DepositedPaper.new({ 'personalAuthor_ses' => [], 'personalAuthor_t' => [45678, 67890] }) }
      it 'returns all authors from text field' do
        expect(deposited_paper.personal_author).to match_array([{ :field_name => "personalAuthor_t", :value => 45678 },
                                                                { :field_name => "personalAuthor_t", :value => 67890 }])
      end
    end

    context 'where both fields are present' do
      let!(:deposited_paper) { DepositedPaper.new({ 'personalAuthor_ses' => [12345, 23456], 'personalAuthor_t' => [45678, 67890] }) }
      it 'returns all authors from both fields' do
        expect(deposited_paper.personal_author).to match_array([{ :field_name => "personalAuthor_ses", :value => 12345 },
                                                                { :field_name => "personalAuthor_ses", :value => 23456 },
                                                                { :field_name => "personalAuthor_t", :value => 45678 },
                                                                { :field_name => "personalAuthor_t", :value => 67890 }])
      end
    end
  end

  describe 'authors' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(deposited_paper.authors).to be_nil
      end
    end

    context 'where there is personal author data' do
      let!(:deposited_paper) { DepositedPaper.new({ 'personalAuthor_ses' => [12345, 23456], 'personalAuthor_t' => [45678, 67890] }) }
      it 'returns all authors from both fields' do
        expect(deposited_paper.authors).to match_array([{ :field_name => "personalAuthor_ses", :value => 12345 },
                                                        { :field_name => "personalAuthor_ses", :value => 23456 },
                                                        { :field_name => "personalAuthor_t", :value => 45678 },
                                                        { :field_name => "personalAuthor_t", :value => 67890 }])
      end
    end

    context 'where there is corporate author data' do
      let!(:deposited_paper) { DepositedPaper.new({ 'corporateAuthor_ses' => [54321, 65432], 'corporateAuthor_t' => [87654, 9876] }) }
      it 'returns all authors from both fields' do
        expect(deposited_paper.authors).to match_array([{ :field_name => "corporateAuthor_ses", :value => 54321 },
                                                        { :field_name => "corporateAuthor_ses", :value => 65432 },
                                                        { :field_name => "corporateAuthor_t", :value => 87654 },
                                                        { :field_name => "corporateAuthor_t", :value => 9876 }])
      end
    end

    context 'where there is corporate and personal author data' do
      let!(:deposited_paper) { DepositedPaper.new({ 'corporateAuthor_ses' => [54321, 65432], 'personalAuthor_ses' => [87654, 9876] }) }
      it 'returns all authors from both fields' do
        expect(deposited_paper.authors).to match_array([{ :field_name => "corporateAuthor_ses", :value => 54321 },
                                                        { :field_name => "corporateAuthor_ses", :value => 65432 },
                                                        { :field_name => "personalAuthor_ses", :value => 87654 },
                                                        { :field_name => "personalAuthor_ses", :value => 9876 }])
      end
    end
  end

  describe 'subjects' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(deposited_paper.subjects).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:deposited_paper) { DepositedPaper.new({ 'subject_ses' => [] }) }
      it 'returns nil' do
        expect(deposited_paper.subjects).to be_nil
      end
    end

    context 'where data exists' do
      let!(:deposited_paper) { DepositedPaper.new({ 'subject_ses' => ['first item', 'second item'] }) }

      it 'returns all items as an array' do
        expect(deposited_paper.subjects).to eq([{ :field_name => "subject_ses", :value => "first item" }, { :field_name => "subject_ses", :value => "second item" }])
      end
    end
  end

  describe 'legislation' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(deposited_paper.legislation).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:deposited_paper) { DepositedPaper.new({ 'legislationTitle_ses' => [] }) }
      it 'returns nil' do
        expect(deposited_paper.legislation).to be_nil
      end
    end

    context 'where data exists' do
      let!(:deposited_paper) { DepositedPaper.new({ 'legislationTitle_ses' => [12345, 67890] }) }

      it 'returns all items as an array' do
        expect(deposited_paper.legislation).to eq([{ :field_name => "legislationTitle_ses", :value => 12345 }, { :field_name => "legislationTitle_ses", :value => 67890 }])
      end
    end
  end

  describe 'deposited_date' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(deposited_paper.deposited_date).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:deposited_paper) { DepositedPaper.new({ 'dateReceived_dt' => nil }) }
      it 'returns nil' do
        expect(deposited_paper.deposited_date).to be_nil
      end
    end

    context 'where data exists' do
      context 'where data is parsable as a datetime' do
        let!(:deposited_paper) { DepositedPaper.new({ 'dateReceived_dt' => ["2015-06-01T18:00:15.73Z"] }) }

        it 'returns the string parsed as a datetime in the London time zone' do
          expect(deposited_paper.deposited_date).to eq({ :field_name => "dateReceived_dt", :value => "Mon, 01 Jun 2015, 19:00:15.73".in_time_zone('London').to_datetime })
        end
      end
      context 'where data is not parsable as a datetime' do
        let!(:deposited_paper) { DepositedPaper.new({ 'dateReceived_dt' => "not a datetime" }) }

        it 'returns nil' do
          expect(deposited_paper.deposited_date).to be_nil
        end
      end
    end
  end

  describe 'commitment_to_deposit_date' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(deposited_paper.commitment_to_deposit_date).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:deposited_paper) { DepositedPaper.new({ 'dateOfCommittmentToDeposit_dt' => nil }) }
      it 'returns nil' do
        expect(deposited_paper.commitment_to_deposit_date).to be_nil
      end
    end

    context 'where data exists' do
      context 'where data is parsable as a datetime' do
        let!(:deposited_paper) { DepositedPaper.new({ 'dateOfCommittmentToDeposit_dt' => ["2015-06-01T18:00:15.73Z"] }) }

        it 'returns the string parsed as a datetime in the London time zone' do
          expect(deposited_paper.commitment_to_deposit_date).to eq({ :field_name => "dateOfCommittmentToDeposit_dt", :value => "Mon, 01 Jun 2015, 19:00:15.73".in_time_zone('London').to_datetime })
        end
      end
      context 'where data is not parsable as a datetime' do
        let!(:deposited_paper) { DepositedPaper.new({ 'dateOfCommittmentToDeposit_dt' => "not a datetime" }) }

        it 'returns nil' do
          expect(deposited_paper.commitment_to_deposit_date).to be_nil
        end
      end
    end
  end

  describe 'date_originated' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(deposited_paper.date_originated).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:deposited_paper) { DepositedPaper.new({ 'dateOfOrigin_dt' => nil }) }
      it 'returns nil' do
        expect(deposited_paper.date_originated).to be_nil
      end
    end

    context 'where data exists' do
      context 'where data is parsable as a datetime' do
        let!(:deposited_paper) { DepositedPaper.new({ 'dateOfOrigin_dt' => ["2015-06-01T18:00:15.73Z"] }) }

        it 'returns the string parsed as a datetime in the London time zone' do
          expect(deposited_paper.date_originated).to eq({ :field_name => "dateOfOrigin_dt", :value => "Mon, 01 Jun 2015, 19:00:15.73".in_time_zone('London').to_datetime })
        end
      end
      context 'where data is not parsable as a datetime' do
        let!(:deposited_paper) { DepositedPaper.new({ 'dateOfOrigin_dt' => "not a datetime" }) }

        it 'returns nil' do
          expect(deposited_paper.date_originated).to be_nil
        end
      end
    end
  end

  describe 'deposited_file' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(deposited_paper.deposited_file).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:deposited_paper) { DepositedPaper.new({ 'depositedFile_uri' => [] }) }
      it 'returns nil' do
        expect(deposited_paper.deposited_file).to be_nil
      end
    end

    context 'where data exists' do
      let!(:deposited_paper) { DepositedPaper.new({ 'depositedFile_uri' => ['http://www.test1.com', 'https://www.test2.com'] }) }

      it 'returns an array of HTTPS URIs' do
        expect(deposited_paper.deposited_file.map(&:to_s)).to eq(['https://www.test1.com', 'https://www.test2.com'])
      end
    end
  end
end