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
        allow(oral_answer_to_question).to receive(:question_id).and_return(url)
        expect(oral_answer_to_question.has_question?).to eq(true)
      end
    end
    context 'where question_url is nil' do
      it 'returns false' do
        allow(oral_answer_to_question).to receive(:question_id).and_return(nil)
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
end