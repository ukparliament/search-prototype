require 'rails_helper'

RSpec.describe EuropeanDepositedDocument, type: :model do
  let!(:european_deposited_document) { EuropeanDepositedDocument.new({}) }

  describe 'template' do
    it 'returns a string' do
      expect(european_deposited_document.template).to be_a(String)
    end
  end

  describe 'object_name' do
    it 'returns object type' do
      allow(european_deposited_document).to receive(:type).and_return({ value: 12345, field_name: 'type_ses' })
      expect(european_deposited_document.object_name).to eq({ value: 12345, field_name: 'type_ses' })
    end
  end

  describe 'commission_number' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(european_deposited_document.commission_number).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:european_deposited_document) { EuropeanDepositedDocument.new({ 'commissionNumber_t' => [] }) }
      it 'returns nil' do
        expect(european_deposited_document.commission_number).to be_nil
      end
    end

    context 'where data exists' do
      let!(:european_deposited_document) { EuropeanDepositedDocument.new({ 'commissionNumber_t' => ['first item', 'second item'] }) }

      it 'returns the first item' do
        expect(european_deposited_document.commission_number).to eq({ :field_name => "commissionNumber_t", :value => "first item" })
      end
    end
  end
  
  describe 'elc_number' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(european_deposited_document.elc_number).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:european_deposited_document) { EuropeanDepositedDocument.new({ 'elcNumber_t' => [] }) }
      it 'returns nil' do
        expect(european_deposited_document.elc_number).to be_nil
      end
    end

    context 'where data exists' do
      let!(:european_deposited_document) { EuropeanDepositedDocument.new({ 'elcNumber_t' => ['first item', 'second item'] }) }

      it 'returns the first item' do
        expect(european_deposited_document.elc_number).to eq({ :field_name => "elcNumber_t", :value => "first item" })
      end
    end
  end

  describe 'council_number' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(european_deposited_document.council_number).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:european_deposited_document) { EuropeanDepositedDocument.new({ 'councilNumber_t' => [] }) }
      it 'returns nil' do
        expect(european_deposited_document.council_number).to be_nil
      end
    end

    context 'where data exists' do
      let!(:european_deposited_document) { EuropeanDepositedDocument.new({ 'councilNumber_t' => ['first item', 'second item'] }) }

      it 'returns the first item' do
        expect(european_deposited_document.council_number).to eq({ :field_name => "councilNumber_t", :value => "first item" })
      end
    end
  end

  describe 'other_number' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(european_deposited_document.other_number).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:european_deposited_document) { EuropeanDepositedDocument.new({ 'otherNumber_t' => [] }) }
      it 'returns nil' do
        expect(european_deposited_document.other_number).to be_nil
      end
    end

    context 'where data exists' do
      let!(:european_deposited_document) { EuropeanDepositedDocument.new({ 'otherNumber_t' => ['first item', 'second item'] }) }

      it 'returns the first item' do
        expect(european_deposited_document.other_number).to eq({ :field_name => "otherNumber_t", :value => "first item" })
      end
    end
  end

  describe 'date_of_origin' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(european_deposited_document.date_originated).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:european_deposited_document) { EuropeanDepositedDocument.new({ 'dateOriginated_dt' => [] }) }
      it 'returns nil' do
        expect(european_deposited_document.date_originated).to be_nil
      end
    end

    context 'where data exists' do
      context 'where data is parsable as a datetime (BST)' do
        let!(:european_deposited_document) { EuropeanDepositedDocument.new({ 'dateOriginated_dt' => ["2015-06-01T18:00:15.73Z", "2014-06-01T18:00:15.73Z"] }) }

        it 'returns the first string parsed as a datetime in the London timezone' do
          expect(european_deposited_document.date_originated[:value]).to eq("Mon, 01 Jun 2015, 19:00:15.73".in_time_zone('London').to_datetime)
        end
      end
      context 'where data is parsable as a datetime (GMT)' do
        let!(:european_deposited_document) { EuropeanDepositedDocument.new({ 'dateOriginated_dt' => ["2015-02-01T18:00:15.73Z", "2014-06-01T18:00:15.73Z"] }) }

        it 'returns the first string parsed as a datetime in the London timezone' do
          expect(european_deposited_document.date_originated[:value]).to eq("Sun, 01 Feb 2015, 18:00:15.73".in_time_zone('London').to_datetime)
        end
      end
      context 'where data is not parsable as a datetime' do
        let!(:european_deposited_document) { EuropeanDepositedDocument.new({ 'dateOriginated_dt' => ["first item", "second item"] }) }

        it 'returns nil' do
          expect(european_deposited_document.date_originated).to be_nil
        end
      end
    end
  end

  describe 'subsidiarity_from_date' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(european_deposited_document.subsidiarity_from_date).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:european_deposited_document) { EuropeanDepositedDocument.new({ 'subsidiarityFromDate_dt' => [] }) }
      it 'returns nil' do
        expect(european_deposited_document.subsidiarity_from_date).to be_nil
      end
    end

    context 'where data exists' do
      context 'where data is parsable as a datetime (BST)' do
        let!(:european_deposited_document) { EuropeanDepositedDocument.new({ 'subsidiarityFromDate_dt' => ["2015-06-01T18:00:15.73Z", "2014-06-01T18:00:15.73Z"] }) }

        it 'returns the first string parsed as a datetime in the London timezone' do
          expect(european_deposited_document.subsidiarity_from_date[:value]).to eq("Mon, 01 Jun 2015, 19:00:15.73".in_time_zone('London').to_datetime)
        end
      end
      context 'where data is parsable as a datetime (GMT)' do
        let!(:european_deposited_document) { EuropeanDepositedDocument.new({ 'subsidiarityFromDate_dt' => ["2015-02-01T18:00:15.73Z", "2014-06-01T18:00:15.73Z"] }) }

        it 'returns the first string parsed as a datetime in the London timezone' do
          expect(european_deposited_document.subsidiarity_from_date[:value]).to eq("Sun, 01 Feb 2015, 18:00:15.73".in_time_zone('London').to_datetime)
        end
      end
      context 'where data is not parsable as a datetime' do
        let!(:european_deposited_document) { EuropeanDepositedDocument.new({ 'subsidiarityFromDate_dt' => ["first item", "second item"] }) }

        it 'returns nil' do
          expect(european_deposited_document.subsidiarity_from_date).to be_nil
        end
      end
    end
  end

  describe 'subsidiarity_to_date' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(european_deposited_document.subsidiarity_to_date).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:european_deposited_document) { EuropeanDepositedDocument.new({ 'subsidiarityToDate_dt' => [] }) }
      it 'returns nil' do
        expect(european_deposited_document.subsidiarity_to_date).to be_nil
      end
    end

    context 'where data exists' do
      context 'where data is parsable as a datetime (BST)' do
        let!(:european_deposited_document) { EuropeanDepositedDocument.new({ 'subsidiarityToDate_dt' => ["2015-06-01T18:00:15.73Z", "2014-06-01T18:00:15.73Z"] }) }

        it 'returns the first string parsed as a datetime in the London timezone' do
          expect(european_deposited_document.subsidiarity_to_date[:value]).to eq("Mon, 01 Jun 2015, 19:00:15.73".in_time_zone('London').to_datetime)
        end
      end
      context 'where data is parsable as a datetime (GMT)' do
        let!(:european_deposited_document) { EuropeanDepositedDocument.new({ 'subsidiarityToDate_dt' => ["2015-02-01T18:00:15.73Z", "2014-06-01T18:00:15.73Z"] }) }

        it 'returns the first string parsed as a datetime in the London timezone' do
          expect(european_deposited_document.subsidiarity_to_date[:value]).to eq("Sun, 01 Feb 2015, 18:00:15.73".in_time_zone('London').to_datetime)
        end
      end
      context 'where data is not parsable as a datetime' do
        let!(:european_deposited_document) { EuropeanDepositedDocument.new({ 'subsidiarityToDate_dt' => ["first item", "second item"] }) }

        it 'returns nil' do
          expect(european_deposited_document.subsidiarity_to_date).to be_nil
        end
      end
    end
  end

  describe 'deposited_date' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(european_deposited_document.deposited_date).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:european_deposited_document) { EuropeanDepositedDocument.new({ 'dateDeposited_dt' => [] }) }
      it 'returns nil' do
        expect(european_deposited_document.deposited_date).to be_nil
      end
    end

    context 'where data exists' do
      context 'where data is parsable as a datetime (BST)' do
        let!(:european_deposited_document) { EuropeanDepositedDocument.new({ 'dateDeposited_dt' => ["2015-06-01T18:00:15.73Z", "2014-06-01T18:00:15.73Z"] }) }

        it 'returns the first string parsed as a datetime in the London timezone' do
          expect(european_deposited_document.deposited_date[:value]).to eq("Mon, 01 Jun 2015, 19:00:15.73".in_time_zone('London').to_datetime)
        end
      end
      context 'where data is parsable as a datetime (GMT)' do
        let!(:european_deposited_document) { EuropeanDepositedDocument.new({ 'dateDeposited_dt' => ["2015-02-01T18:00:15.73Z", "2014-06-01T18:00:15.73Z"] }) }

        it 'returns the first string parsed as a datetime in the London timezone' do
          expect(european_deposited_document.deposited_date[:value]).to eq("Sun, 01 Feb 2015, 18:00:15.73".in_time_zone('London').to_datetime)
        end
      end
      context 'where data is not parsable as a datetime' do
        let!(:european_deposited_document) { EuropeanDepositedDocument.new({ 'dateDeposited_dt' => ["first item", "second item"] }) }

        it 'returns nil' do
          expect(european_deposited_document.deposited_date).to be_nil
        end
      end
    end
  end
end