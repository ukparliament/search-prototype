require 'rails_helper'

RSpec.describe OralAnswerToQuestion, type: :model do
  let!(:oral_answer_to_question) { OralAnswerToQuestion.new({}) }

  describe 'template' do
    it 'returns a string' do
      expect(oral_answer_to_question.template).to be_a(String)
    end
  end

  describe 'object_name' do
    it 'returns object type' do
      allow(oral_answer_to_question).to receive(:type).and_return({ value: 12345, field_name: 'type_ses' })
      expect(oral_answer_to_question.object_name).to eq({ value: 12345, field_name: 'type_ses' })
    end
  end

  describe 'has_question?' do
    let!(:oral_answer_to_question) { OralAnswerToQuestion.new({}) }
    context 'where question_url returns data' do
      let!(:url) { { field_name: 'answerFor_uri', value: 'test url' } }
      it 'returns true' do
        allow(oral_answer_to_question).to receive(:question_url).and_return(url)
        expect(oral_answer_to_question.has_question?).to eq(true)
      end
    end
    context 'where question_url is nil' do
      it 'returns false' do
        allow(oral_answer_to_question).to receive(:question_url).and_return(nil)
        expect(oral_answer_to_question.has_question?).to eq(false)
      end
    end
  end

  describe 'question_url' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(oral_answer_to_question.question_url).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:oral_answer_to_question) { OralAnswerToQuestion.new({ 'answerFor_uri' => [] }) }
      it 'returns nil' do
        expect(oral_answer_to_question.question_url).to be_nil
      end
    end

    context 'where data exists' do
      let!(:oral_answer_to_question) { OralAnswerToQuestion.new({ 'answerFor_uri' => ['first item', 'second item'] }) }

      it 'returns the first item' do
        expect(oral_answer_to_question.question_url).to eq({ :field_name => "answerFor_uri", :value => "first item" })
      end
    end
  end

  describe 'question_object' do
    context 'where has_question? is false' do
      let!(:oral_answer_to_question) { OralAnswerToQuestion.new({}) }

      it 'returns nil' do
        allow(oral_answer_to_question).to receive(:has_question?).and_return(false)
        expect(oral_answer_to_question.question_object).to be_nil
      end
    end

    context 'where has_question is true' do
      let!(:oral_answer_to_question) { OralAnswerToQuestion.new({ 'answerFor_uri' => ['object_uri'] }) }
      let!(:oral_question_data) { { 'type_ses' => [92277] } }

      it 'performs a new Solr query to retrieve the object' do
        allow_any_instance_of(SolrQuery).to receive(:object_data).and_return(oral_question_data)
        allow(SolrQuery).to receive(:new).and_return(SolrQuery.new(object_uri: 'object_uri'))
        expect(SolrQuery).to receive(:new).with(object_uri: 'object_uri')
        oral_answer_to_question.question_object
      end

      it 'passes the returned data to ContentObject to be inflated' do
        allow_any_instance_of(SolrQuery).to receive(:object_data).and_return(oral_question_data)
        expect(ContentObject).to receive(:generate).with(oral_question_data)
        oral_answer_to_question.question_object
      end

      it 'returns the created object' do
        allow_any_instance_of(SolrQuery).to receive(:object_data).and_return(oral_question_data)
        expect(oral_answer_to_question.question_object).to be_a(OralQuestion)
      end
    end
  end
end