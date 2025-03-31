require 'rails_helper'

RSpec.describe SolrQueryWrapper, type: :model do
  let!(:instance) { SolrQueryWrapper.new({ object_uris: ['test_uri1'], solr_fields: ['test_solr_field'] }) }

  describe 'get_objects' do
    let!(:solr_query_object_data) { [
      { 'test_string' => 'test1', 'uri' => 'test_uri1', 'type_ses' => [346697], 'date_dt' => 3.days.ago.to_s },
      { 'test_string' => 'test2', 'uri' => 'test_uri2', 'type_ses' => [346697], 'date_dt' => 2.days.ago.to_s },
      { 'test_string' => 'test3', 'uri' => 'test_uri3', 'type_ses' => [346697], 'date_dt' => 1.day.ago.to_s },
    ] }
    it 'returns objects' do
      allow_any_instance_of(SolrMultiQuery).to receive(:object_data).and_return(solr_query_object_data)
      expect(instance.get_objects.map(&:class)).to eq([Array])
      expect(instance.get_objects.keys).to eq([:items])
      expect(instance.get_objects[:items].map(&:class)).to eq([ResearchBriefing, ResearchBriefing, ResearchBriefing])
    end
    it 'orders items by oldest first' do
      allow_any_instance_of(SolrMultiQuery).to receive(:object_data).and_return(solr_query_object_data)
      expect(instance.get_objects[:items].map { |item| item.date }).to eq([{ field_name: 'date_dt', value: 3.days.ago.to_s },
                                                                           { field_name: 'date_dt', value: 2.days.ago.to_s },
                                                                           { field_name: 'date_dt', value: 1.days.ago.to_s }])
    end
  end
end
