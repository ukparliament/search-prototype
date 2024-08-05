require 'rails_helper'

RSpec.describe SearchData, type: :model do
  let(:search_data) { SearchData.new(search_output) }
  let!(:search_output) { { search_parameters: { filter: ['type_ses:12345'], query: 'horse' },
                           data: {
                             "responseHeader" => {
                               "status" => 0,
                               "QTime" => 4,
                               "params" => { "q" => "externalLocation_uri:\"test_external_location_uri\"", "wt" => "json" }
                             },
                             "response" => {
                               "numFound" => 3,
                               "start" => 0,
                               "docs" => [
                                 { 'test_string' => 'test string 1', 'uri' => 'test1' },
                                 { 'test_string' => 'test string 2', 'uri' => 'test2' },
                                 { 'test_string' => 'test string 3', 'uri' => 'test3' },
                               ]
                             },
                             "highlighting" => { "test_url" => {} },
                             "facets" => {
                               "count" => 1234,
                               "type_ses" => { "buckets" => [{ "val" => 90996, "count" => 123 }, { "val" => 90995, "count" => 234 }] },
                               "subtype_ses" => { "buckets" => [{ "val" => 123456, "count" => 455 }, { "val" => 234556, "count" => 66 }] }
                             }
                           },
  }
  }
  let!(:hierarchy_test_response) { { [92424, "Personal statements"] => [{ "typeId" => "1", "qty" => "1", "name" => "Broader Term", "abbr" => "BT", "fields" => [{ "field" => { "name" => "Oral statements", "id" => "350073", "zid" => "52566919", "class" => "CTP", "freq" => "0", "facets" => [{ "id" => "346696", "name" => "Content type" }] } }] }] } }

  before do
    allow_any_instance_of(SesLookup).to receive(:extract_hierarchy_data).and_return(hierarchy_test_response)
  end

  describe 'solr_error?' do
    context 'with a successful search' do
      it 'returns false' do
        expect(search_data.solr_error?).to be false
      end
    end
    context 'when an error code is present' do
      let!(:search_output) { { search_parameters: { filter: ['type_ses:12345'] }, data: { "code" => 500, "msg" => "error_message" } } }
      it 'returns true' do
        expect(search_data.solr_error?).to be true
      end
    end
  end

  describe 'error_message' do
    context 'with a successful search' do
      it 'returns nil' do
        expect(search_data.error_message).to be nil
      end
    end
    context 'when an error code is present' do
      let!(:search_output) { { search_parameters: { filter: ['type_ses:12345'] }, data: { "code" => 500, "msg" => "error_message" } } }
      it 'returns the message' do
        expect(search_data.error_message).to eq('error_message')
      end
    end
  end

  describe 'error_code' do
    context 'with a successful search' do
      it 'returns nil' do
        expect(search_data.error_code).to be nil
      end
    end
    context 'when an error code is present' do
      let!(:search_output) { { search_parameters: { filter: ['type_ses:12345'] }, data: { "code" => 500, "msg" => "error_message" } } }
      it 'returns the code' do
        expect(search_data.error_code).to eq(500)
      end
    end
  end

  describe 'error_partial_path' do
    context 'with a successful search' do
      it 'returns nil' do
        expect(search_data.error_partial_path).to be nil
      end
    end
    context 'when an error code is present' do
      let!(:search_output) { { search_parameters: { filter: ['type_ses:12345'] }, data: { "code" => 500, "msg" => "error_message" } } }
      it 'returns the partial path' do
        expect(search_data.error_partial_path).to eq('layouts/shared/error/500')
      end
    end
  end

  describe 'object_data' do
    context 'where data is present' do
      it 'returns the array of docs' do
        expect(search_data.object_data).to eq([
                                                { 'test_string' => 'test string 1', 'uri' => 'test1' },
                                                { 'test_string' => 'test string 2', 'uri' => 'test2' },
                                                { 'test_string' => 'test string 3', 'uri' => 'test3' },
                                              ])
      end
    end
    context 'where data is missing' do
      let!(:search_output) { { search_parameters: { filter: ['type_ses:12345'] },
                               data: { "responseHeader" => {
                                 "status" => 0,
                                 "QTime" => 4,
                                 "params" => { "q" => "externalLocation_uri:\"test_external_location_uri\"", "wt" => "json" }
                               },
                                       "response" => {
                                         "numFound" => 1,
                                         "start" => 0
                                       },
                                       "highlighting" => { "test_url" => {} }
                               } }
      }
      it 'returns nil' do
        expect(search_data.object_data).to be nil
      end
    end
  end

  describe 'objects' do
    context 'where data is present' do
      it 'returns an array of object instances' do
        expect(search_data.objects.map(&:class)).to eq([ContentObject, ContentObject, ContentObject])
      end
    end
    context 'where data is missing' do
      let!(:search_output) { { search_parameters: { filter: ['type_ses:12345'] },
                               data: { "responseHeader" => {
                                 "status" => 0,
                                 "QTime" => 4,
                                 "params" => { "q" => "externalLocation_uri:\"test_external_location_uri\"", "wt" => "json" }
                               },
                                       "response" => {
                                         "numFound" => 1,
                                         "start" => 0
                                       },
                                       "highlighting" => { "test_url" => {} }
                               } }
      }
      it 'returns an empty array' do
        expect(search_data.objects).to eq([])
      end
    end
  end

  describe 'number_of_results' do
    context 'where data is present' do
      it 'returns the number of results' do
        expect(search_data.number_of_results).to eq(3)
      end
    end

    context 'where no data is present' do
      let!(:search_output) { { search_parameters: { filter: ['type_ses:12345'] } } }

      it 'returns nil' do
        expect(search_data.number_of_results).to be nil
      end
    end
  end

  describe 'query' do
    context 'where data is present' do
      it 'returns the number of results' do
        expect(search_data.query).to eq('horse')
      end
    end

    context 'where no query is present' do
      let!(:search_output) { { search_parameters: { filter: ['type_ses:12345'] } } }

      it 'returns nil' do
        expect(search_data.query).to be nil
      end
    end
  end

  describe 'sort' do
    context 'where data is present' do
      let!(:search_output) { { search_parameters: { 'sort_by' => 'date_asc' } } }
      it 'returns the number of results' do
        expect(search_data.sort).to eq('date_asc')
      end
    end

    context 'where no sort is present' do
      it 'returns nil' do
        expect(search_data.sort).to be nil
      end
    end
  end

  describe 'filter' do
    context 'where data is present' do
      let!(:search_output) { { search_parameters: { filter: ['type_ses:12345'] } } }
      it 'returns an array of filter strings' do
        expect(search_data.filter).to eq(["type_ses:12345"])
      end
    end

    context 'where no filter is present' do
      let!(:search_output) { { search_parameters: {} } }

      it 'returns nil' do
        expect(search_data.filter).to be nil
      end
    end
  end

  describe 'start' do
    context 'where no data is present' do
      it 'returns the number of results' do
        expect(search_data.start).to eq(0)
      end
    end

    context 'where data is present' do
      let!(:search_output) { { data: { 'response' => { 'start' => 15 } } } }
      it 'returns the number of results' do
        expect(search_data.start).to eq(15)
      end
    end
  end

  describe 'query_time' do
    context 'where no data is present' do
      let!(:search_output) { { data: { 'response' => { 'QTime' => nil } } } }
      it 'returns nil' do
        expect(search_data.query_time).to be nil
      end
    end

    context 'where data is present' do
      it 'returns the time in seconds' do
        expect(search_data.query_time).to eq(0.004)
      end
    end
  end

  describe 'end' do
    context 'where there is no data present' do
      it 'returns the number of results per page' do
        expect(search_data.end).to eq(20)
      end
    end

    context 'where data is present' do
      let!(:search_output) { { data: { 'response' => { 'start' => 15 } } } }
      it 'returns the start + per page' do
        expect(search_data.end).to eq(35)
      end
    end
  end

  describe 'facets' do
    context 'where search is nil' do
      let(:search_data) { SearchData.new(nil) }
      it 'returns an empty array' do
        expect(search_data.facets).to eq([])
      end
    end

    context 'where search is not nil' do
      it 'returns an array' do
        expect(search_data.facets.class).to eq(Array)
      end

      it 'has field_name and facets keys' do
        expect(search_data.facets.first.keys).to eq([:field_name, :facets])
      end

      it 'includes the field name string' do
        expect(search_data.facets.pluck(:field_name)).to eq(["type_ses", "subtype_ses"])
      end

      it 'includes facets sorted by count (descending)' do
        expect(search_data.facets.pluck(:facets)).to eq([[{ "count" => 234, "val" => 90995 }, { "count" => 123, "val" => 90996 }], [{ "count" => 455, "val" => 123456 }, { "count" => 66, "val" => 234556 }]])
      end
    end
  end

end
