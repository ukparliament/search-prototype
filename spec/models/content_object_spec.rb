require 'rails_helper'

RSpec.describe ContentObject, type: :model do
  let!(:content_object) { ContentObject.new({}) }

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

  describe 'has_link?' do
    context 'when display link is nil' do
      let!(:content_object) { ContentObject.new(test_data) }
      let!(:test_data) { { "some_data" => [12345] } }

      it 'returns false' do
        allow(content_object).to receive(:display_link).and_return(nil)
        expect(content_object.has_link?).to eq(false)
      end
    end

    context 'when display link is populated' do
      let!(:content_object) { ContentObject.new(test_data) }
      let!(:test_data) { { "some_data" => [12345] } }

      it 'returns true' do
        allow(content_object).to receive(:display_link).and_return('www.example.com')
        expect(content_object.has_link?).to eq(true)
      end
    end
  end

  describe 'date_of_royal_assent' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(content_object.date_of_royal_assent).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:content_object) { ContentObject.new({ 'dateOfRoyalAssent_dt' => [] }) }
      it 'returns nil' do
        expect(content_object.date_of_royal_assent).to be_nil
      end
    end

    context 'where data exists' do
      context 'where data is parsable as a date' do
        let!(:content_object) { ContentObject.new({ 'dateOfRoyalAssent_dt' => ["2015-06-01T18:00:15.73Z", "2014-06-01T18:00:15.73Z"] }) }

        it 'returns the first string parsed as a date' do
          expect(content_object.date_of_royal_assent).to eq("Mon, 01 Jun 2015".to_date)
        end
      end
      context 'where data is not parsable as a date' do
        let!(:content_object) { ContentObject.new({ 'dateOfRoyalAssent_dt' => ["first item", "second item"] }) }

        it 'returns nil' do
          expect(content_object.date_of_royal_assent).to be_nil
        end
      end
    end
  end

end