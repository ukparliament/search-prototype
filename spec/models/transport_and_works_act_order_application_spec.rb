require 'rails_helper'

RSpec.describe TransportAndWorksActOrderApplication, type: :model do
  let!(:transport_and_works_act_order_application) { TransportAndWorksActOrderApplication.new({}) }

  describe 'template' do
    it 'returns a string' do
      expect(transport_and_works_act_order_application.template).to be_a(String)
    end
  end

  describe 'object_name' do
    it 'returns object type' do
      allow(transport_and_works_act_order_application).to receive(:type).and_return({ value: 12345, field_name: 'type_ses' })
      expect(transport_and_works_act_order_application.object_name).to eq({ value: 12345, field_name: 'type_ses' })
    end
  end

  describe 'reference' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(transport_and_works_act_order_application.reference).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:transport_and_works_act_order_application) { TransportAndWorksActOrderApplication.new({ 'identifier_t' => [] }) }
      it 'returns nil' do
        expect(transport_and_works_act_order_application.reference).to be_nil
      end
    end

    context 'where data exists' do
      let!(:transport_and_works_act_order_application) { TransportAndWorksActOrderApplication.new({ 'identifier_t' => ['first item', 'second item'] }) }

      it 'returns the first item' do
        expect(transport_and_works_act_order_application.reference).to eq({ :field_name => "identifier_t", :value => "first item" })
      end
    end
  end

  describe 'subjects' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(transport_and_works_act_order_application.subjects).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:transport_and_works_act_order_application) { TransportAndWorksActOrderApplication.new({ 'subject_ses' => [] }) }
      it 'returns nil' do
        expect(transport_and_works_act_order_application.subjects).to be_nil
      end
    end

    context 'where data exists' do
      let!(:transport_and_works_act_order_application) { TransportAndWorksActOrderApplication.new({ 'subject_ses' => ['first item', 'second item'] }) }

      it 'returns all items as an array' do
        expect(transport_and_works_act_order_application.subjects).to eq([{ :field_name => "subject_ses", :value => "first item" }, { :field_name => "subject_ses", :value => "second item" }])
      end
    end
  end

  describe 'legislation' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(transport_and_works_act_order_application.legislation).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:transport_and_works_act_order_application) { TransportAndWorksActOrderApplication.new({ 'legislationTitle_ses' => [] }) }
      it 'returns nil' do
        expect(transport_and_works_act_order_application.legislation).to be_nil
      end
    end

    context 'where data exists' do
      let!(:transport_and_works_act_order_application) { TransportAndWorksActOrderApplication.new({ 'legislationTitle_ses' => [12345, 67890] }) }

      it 'returns all items as an array' do
        expect(transport_and_works_act_order_application.legislation).to eq([{ :field_name => "legislationTitle_ses", :value => 12345 }, { :field_name => "legislationTitle_ses", :value => 67890 }])
      end
    end
  end

  describe 'depositing_agent' do
    context 'where agent_ses is populated' do
      let!(:transport_and_works_act_order_application) { TransportAndWorksActOrderApplication.new({ 'agent_ses' => [12345, 67890], 'agent_t' => ['test 1', 'test 2'] }) }
      it 'returns first ses id' do
        expect(transport_and_works_act_order_application.depositing_agent).to eq({ :field_name => "agent_ses", :value => 12345 })
      end
    end
    context 'where agent_ses is not populated' do
      let!(:transport_and_works_act_order_application) { TransportAndWorksActOrderApplication.new({ 'agent_ses' => [], 'agent_t' => ['test 1', 'test 2'] }) }
      it 'returns first string' do
        expect(transport_and_works_act_order_application.depositing_agent).to eq({ :field_name => "agent_t", :value => 'test 1' })
      end
    end
  end

  describe 'depositing_applicant' do
    context 'where applicant_ses is populated' do
      let!(:transport_and_works_act_order_application) { TransportAndWorksActOrderApplication.new({ 'applicant_ses' => [12345, 67890], 'applicant_t' => ['test 1', 'test 2'] }) }
      it 'returns first ses id' do
        expect(transport_and_works_act_order_application.depositing_applicant).to eq({ :field_name => "applicant_ses", :value => 12345 })
      end
    end
    context 'where applicant_ses is not populated' do
      let!(:transport_and_works_act_order_application) { TransportAndWorksActOrderApplication.new({ 'applicant_ses' => [], 'applicant_t' => ['test 1', 'test 2'] }) }
      it 'returns first string' do
        expect(transport_and_works_act_order_application.depositing_applicant).to eq({ :field_name => "applicant_t", :value => 'test 1' })
      end
    end
  end

  describe 'date_of_origin' do
    # example test - get first as date
    context 'where there is no data' do
      it 'returns nil' do
        expect(transport_and_works_act_order_application.date_of_origin).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:transport_and_works_act_order_application) { TransportAndWorksActOrderApplication.new({ 'dateOfOrigin_dt' => [] }) }
      it 'returns nil' do
        expect(transport_and_works_act_order_application.date_of_origin).to be_nil
      end
    end

    context 'where data exists' do
      context 'where data is parsable as a datetime (BST)' do
        let!(:transport_and_works_act_order_application) { TransportAndWorksActOrderApplication.new({ 'dateOfOrigin_dt' => ["2015-06-01T18:00:15.73Z", "2014-06-01T18:00:15.73Z"] }) }

        it 'returns the first string parsed as a datetime in the London timezone' do
          expect(transport_and_works_act_order_application.date_of_origin[:value]).to eq("Mon, 01 Jun 2015, 19:00:15.73".in_time_zone('London').to_datetime)
        end
      end
      context 'where data is parsable as a datetime (GMT)' do
        let!(:transport_and_works_act_order_application) { TransportAndWorksActOrderApplication.new({ 'dateOfOrigin_dt' => ["2015-02-01T18:00:15.73Z", "2014-06-01T18:00:15.73Z"] }) }

        it 'returns the first string parsed as a datetime in the London timezone' do
          expect(transport_and_works_act_order_application.date_of_origin[:value]).to eq("Sun, 01 Feb 2015, 18:00:15.73".in_time_zone('London').to_datetime)
        end
      end
      context 'where data is not parsable as a datetime' do
        let!(:transport_and_works_act_order_application) { TransportAndWorksActOrderApplication.new({ 'dateOfOrigin_dt' => ["first item", "second item"] }) }

        it 'returns nil' do
          expect(transport_and_works_act_order_application.date_of_origin).to be_nil
        end
      end
    end
  end
end