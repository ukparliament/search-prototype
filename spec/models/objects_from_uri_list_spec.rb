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
end
