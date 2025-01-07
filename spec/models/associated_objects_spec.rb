require 'rails_helper'

RSpec.describe AssociatedObjects, type: :model do
  let!(:oral_question) { OralQuestion.new('uri' => 'uri_of_oral_question', 'type_ses' => [23456], 'answerFor_uri' => ['uri_of_answer']) }
  let!(:proceeding_contribution) { ProceedingContribution.new('uri' => 'uri_of_proceeding_contribution', 'type_ses' => [56789], 'parentProceeding_t' => ['uri_of_parent_proceeding']) }
  let!(:parent_proceeding) { ProceedingContribution.new('uri' => 'uri_of_parent_proceeding', 'all_ses' => [456, 123]) }
  let!(:answer) { OralAnswerToQuestion.new('uri' => 'uri_of_answer', 'all_ses' => [654, 123]) }
  let!(:associated_objects) { AssociatedObjects.new(objects) }

  context 'when objects is a single object' do
    let!(:objects) { oral_question }

    describe 'normalised_objects' do
      it 'ensures objects is an array' do
        expect(associated_objects.normalised_objects).to be_an(Array)
      end
    end

    describe 'associated_object_ids' do
      it 'returns an array of related item uris' do
        expect(associated_objects.associated_object_ids).to eq(['uri_of_answer'])
      end
    end

    describe 'get_associated_objects' do
      it 'makes a Solr request' do
        allow_any_instance_of(SolrQueryWrapper).to receive(:get_objects).and_return({ items: 'test response' })
        expect(associated_objects.get_associated_objects).to eq('test response')
      end
    end
  end

  context 'when objects is an array of objects' do
    let!(:objects) { [oral_question, proceeding_contribution] }

    describe 'normalised_objects' do
      it 'ensures objects is an array' do
        expect(associated_objects.normalised_objects).to be_an(Array)
        expect(associated_objects.normalised_objects).to match_array(objects)
      end
    end

    describe 'associated_object_ids' do
      it 'returns an array of related item uris' do
        expect(associated_objects.associated_object_ids).to eq(['uri_of_answer', 'uri_of_parent_proceeding'])
      end
    end

    describe 'get_associated_objects' do
      it 'makes a Solr request' do
        allow_any_instance_of(SolrQueryWrapper).to receive(:get_objects).and_return({ items: 'test response' })
        expect(associated_objects.get_associated_objects).to eq('test response')
      end
    end

    describe 'data' do
      let!(:test_response) { [parent_proceeding, answer] }

      it 'returns structured data' do
        allow_any_instance_of(SolrQueryWrapper).to receive(:get_objects).and_return({ items: test_response })
        expect(associated_objects.data[:object_data]).to eq({ 'uri_of_answer' => answer, 'uri_of_parent_proceeding' => parent_proceeding })
        expect(associated_objects.data[:ses_ids]).to match_array([{ :field_name => "all_ses", :value => 123 }, { :field_name => "all_ses", :value => 456 }, { :field_name => "all_ses", :value => 654 }])
      end
    end
  end
end
