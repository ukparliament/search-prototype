require 'rails_helper'

RSpec.describe EuropeanScrutiny, type: :model do
  let!(:european_scrutiny) { EuropeanScrutiny.new({}) }

  describe 'regarding_link' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(european_scrutiny.regarding_link).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:european_scrutiny) { EuropeanScrutiny.new({ 'regardingDD_uri' => [] }) }
      it 'returns nil' do
        expect(european_scrutiny.regarding_link).to be_nil
      end
    end

    context 'where data exists' do
      let!(:european_scrutiny) { EuropeanScrutiny.new({ 'regardingDD_uri' => ['first item', 'second item'] }) }

      it 'returns the first item' do
        expect(european_scrutiny.regarding_link).to eq({ :field_name => "regardingDD_uri", :value => "first item" })
      end
    end
  end

  describe 'regarding_title' do
    context 'where regarding link exists' do
      let!(:european_scrutiny) { EuropeanScrutiny.new({ 'regardingDD_uri' => ['test url'] }) }

      context 'where regarding object exists and has a title' do
        let!(:deposited_document) { { "type_ses" => [347028], "title_t" => 'regarding object title' } }
        let!(:solr_return) { deposited_document }
        let!(:ses_return) { { 347028 => 'European deposited document' } }

        it 'returns the title' do
          allow_any_instance_of(SolrQuery).to receive(:object_data).and_return(solr_return)
          allow_any_instance_of(SesLookup).to receive(:data).and_return(ses_return)
          expect(european_scrutiny.regarding_title).to eq('regarding object title')
        end
      end
      context 'where regarding object exists but has no title' do
        let!(:deposited_document) { { "type_ses" => [347028] } }
        let!(:solr_return) { deposited_document }
        let!(:ses_return) { { 347028 => 'European deposited document' } }

        it 'returns a placeholder title based on object type' do
          allow_any_instance_of(SolrQuery).to receive(:object_data).and_return(solr_return)
          allow_any_instance_of(SesLookup).to receive(:data).and_return(ses_return)
          expect(european_scrutiny.regarding_title).to eq('an untitled European deposited document')
        end
      end
      context 'where regarding object does not exist' do
        let!(:solr_return) {}

        it 'returns nil' do
          allow_any_instance_of(SolrQuery).to receive(:object_data).and_return(solr_return)
          expect(european_scrutiny.regarding_title).to be_nil
        end
      end
    end

    context 'where regarding link does not exist' do
      let!(:european_scrutiny) { EuropeanScrutiny.new({}) }
      let!(:solr_return) {}

      it 'returns nil' do
        expect(european_scrutiny.regarding_title).to be_nil
      end
    end
  end
end