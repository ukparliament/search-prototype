require 'rails_helper'

RSpec.describe TransportAndWorksActOrderApplication, type: :model do
  let!(:transport_and_works_act_order_application) { TransportAndWorksActOrderApplication.new({}) }

  describe 'template' do
    it 'returns a string' do
      expect(transport_and_works_act_order_application.template).to be_a(String)
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
        expect(transport_and_works_act_order_application.reference).to eq('first item')
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
        expect(transport_and_works_act_order_application.subjects).to eq(['first item', 'second item'])
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
        expect(transport_and_works_act_order_application.legislation).to eq([12345, 67890])
      end
    end
  end
end