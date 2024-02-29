require 'rails_helper'

RSpec.describe ObjectsFromUriList, type: :model do
  let!(:instance) { ObjectsFromUriList.new(['test_uri1']) }

  describe 'all_ses_ids' do
    let!(:returned_data) { [{ 'test_string' => 'test1', 'uri' => 'test_uri1', 'all_ses' => [123, 456] },
                            { 'test_string' => 'test2', 'uri' => 'test_uri2', 'all_ses' => [456, 789] },
                            { 'test_string' => 'test3', 'uri' => 'test_uri3', 'all_ses' => [234, 567] },
    ] }

    it 'returns an array of data hashes containing values and field names from all objects returned' do
      expect(instance.all_ses_ids(returned_data)).to match_array([{ :field_name => "all_ses", :value => [123, 456] },
                                                                  { :field_name => "all_ses", :value => [456, 789] },
                                                                  { :field_name => "all_ses", :value => [234, 567] }])
    end
  end

  describe 'get_objects' do
    let!(:solr_query_object_data) { [
      { 'test_string' => 'test1', 'uri' => 'test_uri1', 'type_ses' => [346697], 'all_ses' => [123, 456], 'date_dt' => 3.days.ago.to_s },
      { 'test_string' => 'test2', 'uri' => 'test_uri2', 'type_ses' => [346697], 'all_ses' => [456, 789], 'date_dt' => 2.days.ago.to_s },
      { 'test_string' => 'test3', 'uri' => 'test_uri3', 'type_ses' => [346697], 'all_ses' => [234, 567], 'date_dt' => 1.day.ago.to_s },
    ] }
    it 'returns objects and SES data' do
      allow_any_instance_of(SolrMultiQuery).to receive(:object_data).and_return(solr_query_object_data)
      allow_any_instance_of(SesLookup).to receive(:data).and_return('ses_lookup_return')
      expect(instance.get_objects.map(&:class)).to eq([Array, Array])
      expect(instance.get_objects.keys).to eq([:ses_lookup, :items])
      expect(instance.get_objects[:items].map(&:class)).to eq([ResearchBriefing, ResearchBriefing, ResearchBriefing])
    end
    it 'orders items by oldest first' do
      allow_any_instance_of(SolrMultiQuery).to receive(:object_data).and_return(solr_query_object_data)
      allow_any_instance_of(SesLookup).to receive(:data).and_return('ses_lookup_return')
      expect(instance.get_objects[:items].map { |item| item.date }).to eq([{ field_name: 'date_dt', value: 3.days.ago.to_s },
                                                                           { field_name: 'date_dt', value: 2.days.ago.to_s },
                                                                           { field_name: 'date_dt', value: 1.days.ago.to_s }])
    end
  end
end
