require 'rails_helper'

RSpec.describe ContentObject, type: :model do

  describe 'self.generate' do
    context 'when passed invalid data' do
      let!(:test_data) { { "some_data" => [12345] } }
      it 'returns an instance of the ContentObject class' do
        expect(ContentObject.generate(test_data)).to be_an_instance_of(ContentObject)
      end
    end
    context 'when passed an unknown object type' do
      let!(:test_data) { { "type_ses" => [12345] } }

      it 'returns an instance of the ContentObject class' do
        expect(ContentObject.generate(test_data)).to be_an_instance_of(ContentObject)
      end
    end
    context 'when passed a known object type' do
      let!(:test_data) { { "type_ses" => [90996] } }

      it 'returns an instance of the type class' do
        expect(ContentObject.generate(test_data)).to be_an_instance_of(Edm)
      end
    end
  end

  describe 'page_title' do
    context 'when passed invalid data' do
      let!(:content_object) { ContentObject.new(test_data) }
      let!(:test_data) { { "some_data" => [12345] } }
      it 'returns nil' do
        expect(content_object.page_title).to be_nil
      end
    end
    context 'when title is present in the data' do
      let!(:content_object) { ContentObject.new(test_data) }
      let!(:test_data) { { "title_t" => ['The Title'] } }

      it 'returns the title text as an array item' do
        expect(content_object.page_title).to be_an(Array)
        expect(content_object.page_title.first).to eq('The Title')
      end
    end
  end

end