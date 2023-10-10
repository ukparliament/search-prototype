require 'rails_helper'

RSpec.describe WrittenQuestion, type: :model do
  let!(:written_question) { WrittenQuestion.new({}) }

  describe 'template' do
    it 'returns a string' do
      expect(written_question.template).to be_a(String)
    end
  end

  describe 'object_name' do
    it 'returns a string' do
      expect(written_question.object_name).to be_a(String)
    end
  end

  describe 'state' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(written_question.state).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:written_question) { WrittenQuestion.new({ 'pqStatus_t' => [] }) }
      it 'returns nil' do
        expect(written_question.state).to be_nil
      end
    end

    context 'where data exists' do
      let!(:written_question) { WrittenQuestion.new({ 'pqStatus_t' => ['Answered'] }) }

      it 'returns first item' do
        expect(written_question.state).to eq('Answered')
      end
    end
  end

  describe 'tabled?' do
    let!(:written_question) { WrittenQuestion.new({ 'pqStatus_t' => '' }) }
    context 'where state is tabled' do
      it 'returns true' do
        allow(written_question).to receive(:state).and_return('Tabled')
        expect(written_question.tabled?).to eq(true)
      end
    end
    context 'where state is missing' do
      it 'returns false' do
        allow(written_question).to receive(:state).and_return(nil)
        expect(written_question.tabled?).to eq(false)
      end
    end
    context 'where state is present but not tabled' do
      it 'returns false' do
        allow(written_question).to receive(:state).and_return('Answered')
        expect(written_question.tabled?).to eq(false)
      end
    end
  end

  describe 'answered?' do
    let!(:written_question) { WrittenQuestion.new({ 'pqStatus_t' => '' }) }
    context 'where state is answered' do
      it 'returns true' do
        allow(written_question).to receive(:state).and_return('Answered')
        expect(written_question.answered?).to eq(true)
      end
    end
    context 'where state is missing' do
      it 'returns false' do
        allow(written_question).to receive(:state).and_return(nil)
        expect(written_question.answered?).to eq(false)
      end
    end
    context 'where state is present but not answered' do
      it 'returns false' do
        allow(written_question).to receive(:state).and_return('Holding')
        expect(written_question.answered?).to eq(false)
      end
    end
  end

  describe 'holding?' do
    let!(:written_question) { WrittenQuestion.new({ 'pqStatus_t' => '' }) }
    context 'where state is holding' do
      it 'returns true' do
        allow(written_question).to receive(:state).and_return('Holding')
        expect(written_question.holding?).to eq(true)
      end
    end
    context 'where state is missing' do
      it 'returns false' do
        allow(written_question).to receive(:state).and_return(nil)
        expect(written_question.holding?).to eq(false)
      end
    end
    context 'where state is present but not holding' do
      it 'returns false' do
        allow(written_question).to receive(:state).and_return('Answered was holding')
        expect(written_question.holding?).to eq(false)
      end
    end
  end

  describe 'answered_was_holding?' do
    let!(:written_question) { WrittenQuestion.new({ 'pqStatus_t' => '' }) }
    context 'where state is answered' do
      context 'where answer is marked as holding and there is a holding answer date' do
        it 'returns true' do
          allow(written_question).to receive(:holding_answer?).and_return(true)
          allow(written_question).to receive(:date_of_holding_answer).and_return(Date.yesterday)
          allow(written_question).to receive(:state).and_return('Answered')
          expect(written_question.answered_was_holding?).to eq(true)
        end
      end
      context 'where other required fields are missing' do
        it 'returns false' do
          allow(written_question).to receive(:state).and_return('Answered')
          expect(written_question.answered_was_holding?).to eq(false)
        end
      end
    end
    context 'where state is missing' do
      it 'returns false' do
        allow(written_question).to receive(:state).and_return(nil)
        expect(written_question.answered_was_holding?).to eq(false)
      end
    end
    context 'where state is present but not answered_was_holding' do
      it 'returns false' do
        allow(written_question).to receive(:state).and_return('Withdrawn')
        expect(written_question.answered_was_holding?).to eq(false)
      end
    end
  end

  describe 'withdrawn?' do
    context 'where state is withdrawn' do
      let!(:written_question) { WrittenQuestion.new({ 'pqStatus_t' => '' }) }
      it 'returns true' do
        allow(written_question).to receive(:state).and_return('Withdrawn')
        expect(written_question.withdrawn?).to eq(true)
      end
    end
    context 'where state is missing' do
      it 'returns false' do
        allow(written_question).to receive(:state).and_return(nil)
        expect(written_question.withdrawn?).to eq(false)
      end
    end
    context 'where state is present but not withdrawn' do
      it 'returns false' do
        allow(written_question).to receive(:state).and_return('Corrected')
        expect(written_question.withdrawn?).to eq(false)
      end
    end
  end

  describe 'corrected?' do
    context 'where corrected boolean is true' do
      let!(:written_question) { WrittenQuestion.new({ 'correctedWmsMc_b' => 'true' }) }
      it 'returns true' do
        expect(written_question.corrected?).to eq(true)
      end
    end
    context 'where corrected boolean is missing' do
      it 'returns false' do
        expect(written_question.corrected?).to eq(false)
      end
    end
    context 'where state is present but not true' do
      let!(:written_question) { WrittenQuestion.new({ 'correctedWmsMc_b' => 'false' }) }
      it 'returns false' do
        expect(written_question.corrected?).to eq(false)
      end
    end
  end

  describe 'correcting_object' do
    context 'where corrected' do
      context 'where URI is missing' do
        let!(:written_question) { WrittenQuestion.new({ 'correctingItem_uri' => '' }) }
        it 'returns nil' do
          allow(written_question).to receive(:corrected?).and_return(true)
          expect(written_question.correcting_object).to be_nil
        end
      end
      context 'where URI is present' do
        let!(:written_question) { WrittenQuestion.new({ 'correctingItem_uri' => 'test' }) }
        let!(:test_data) { { "type_ses" => [93522] } }

        it 'returns a written question object' do
          allow(written_question).to receive(:corrected?).and_return(true)
          allow_any_instance_of(ApiCall).to receive(:object_data).and_return(test_data)
          expect(written_question.correcting_object).to be_an_instance_of(WrittenQuestion)
        end
      end
    end
    context 'where not corrected' do
      it 'returns nil' do
        allow(written_question).to receive(:corrected?).and_return(false)
        expect(written_question.correcting_object).to be_nil
      end
    end
  end

  describe 'department' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(written_question.department).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:written_question) { WrittenQuestion.new({ 'department_ses' => [] }) }
      it 'returns nil' do
        expect(written_question.department).to be_nil
      end
    end

    context 'where data exists' do
      let!(:written_question) { WrittenQuestion.new({ 'department_ses' => [12345, 67890] }) }

      it 'returns first item' do
        expect(written_question.department).to eq(12345)
      end
    end
  end

  describe 'prelim_partial' do
    let!(:written_question) { WrittenQuestion.new({ 'pqStatus_t' => '' }) }
    context 'where tabled' do
      it 'returns the correct path' do
        allow(written_question).to receive(:state).and_return('Tabled')
        expect(written_question.prelim_partial).to eq('/search/preliminary_sentences/written_question_tabled')
      end
    end
    context 'where answered' do
      it 'returns the correct path' do
        allow(written_question).to receive(:state).and_return('Answered')
        expect(written_question.prelim_partial).to eq('/search/preliminary_sentences/written_question_answered')
      end
    end
    context 'where holding' do
      it 'returns the correct path' do
        allow(written_question).to receive(:state).and_return('Holding')
        expect(written_question.prelim_partial).to eq('/search/preliminary_sentences/written_question_holding')
      end
    end
    context 'where answered_was_holding' do
      it 'returns the correct path' do
        allow(written_question).to receive(:answered_was_holding?).and_return(true)
        expect(written_question.prelim_partial).to eq('/search/preliminary_sentences/written_question_answered_was_holding')
      end
    end
    context 'where withdrawn' do
      it 'returns the correct path' do
        allow(written_question).to receive(:state).and_return('Withdrawn')
        expect(written_question.prelim_partial).to eq('/search/preliminary_sentences/written_question_withdrawn')
      end
    end
    context 'where corrected' do
      it 'returns the correct path' do
        allow(written_question).to receive(:corrected?).and_return(true)
        expect(written_question.prelim_partial).to eq('/search/preliminary_sentences/written_question_corrected')
      end
    end
  end

  describe 'uin' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(written_question.uin).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:written_question) { WrittenQuestion.new({ 'identifier_t' => [] }) }
      it 'returns nil' do
        expect(written_question.uin).to be_nil
      end
    end

    context 'where data exists' do
      let!(:written_question) { WrittenQuestion.new({ 'identifier_t' => ['item one', 'item two'] }) }

      it 'returns all items' do
        expect(written_question.uin).to eq(['item one', 'item two'])
      end
    end
  end

  describe 'date_of_question' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(written_question.date_of_question).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:written_question) { WrittenQuestion.new({ 'date_dt' => '' }) }
      it 'returns nil' do
        expect(written_question.date_of_question).to be_nil
      end
    end

    context 'where data exists' do
      context 'where data is a valid date' do
        let!(:written_question) { WrittenQuestion.new({ 'date_dt' => Date.yesterday.to_s }) }
        it 'returns the first object as a date' do
          expect(written_question.date_of_question).to eq(Date.yesterday)
        end
      end
      context 'where data is not a valid date' do
        let!(:written_question) { WrittenQuestion.new({ 'date_dt' => 'date' }) }
        it 'returns nil' do
          expect(written_question.date_of_question).to be_nil
        end
      end
    end
  end

  describe 'date_of_answer' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(written_question.date_of_answer).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:written_question) { WrittenQuestion.new({ 'dateOfAnswer_dt' => [] }) }
      it 'returns nil' do
        expect(written_question.date_of_answer).to be_nil
      end
    end

    context 'where data exists' do
      let!(:written_question) { WrittenQuestion.new({ 'dateOfAnswer_dt' => [Date.yesterday.to_s, Date.today.to_s] }) }

      context 'where data is a valid date' do
        let!(:written_question) { WrittenQuestion.new({ 'dateOfAnswer_dt' => [Date.yesterday.to_s, Date.today.to_s] }) }
        it 'returns the first object as a date' do
          expect(written_question.date_of_answer).to eq(Date.yesterday)
        end
      end
      context 'where data is not a valid date' do
        let!(:written_question) { WrittenQuestion.new({ 'dateOfAnswer_dt' => 'date' }) }
        it 'returns nil' do
          expect(written_question.date_of_answer).to be_nil
        end
      end
    end
  end

  describe 'date_for_answer' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(written_question.date_for_answer).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:written_question) { WrittenQuestion.new({ 'dateForAnswer_dt' => [] }) }
      it 'returns nil' do
        expect(written_question.date_for_answer).to be_nil
      end
    end

    context 'where data exists' do
      let!(:written_question) { WrittenQuestion.new({ 'dateForAnswer_dt' => [Date.yesterday.to_s, Date.today.to_s] }) }

      context 'where data is a valid date' do
        let!(:written_question) { WrittenQuestion.new({ 'dateForAnswer_dt' => [Date.yesterday.to_s, Date.today.to_s] }) }
        it 'returns the first object as a date' do
          expect(written_question.date_for_answer).to eq(Date.yesterday)
        end
      end
      context 'where data is not a valid date' do
        let!(:written_question) { WrittenQuestion.new({ 'dateForAnswer_dt' => 'date' }) }
        it 'returns nil' do
          expect(written_question.date_for_answer).to be_nil
        end
      end
    end
  end

  describe 'tabling_member' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(written_question.tabling_member).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:written_question) { WrittenQuestion.new({ 'tablingMember_ses' => [] }) }
      it 'returns nil' do
        expect(written_question.tabling_member).to be_nil
      end
    end

    context 'where data exists' do
      let!(:written_question) { WrittenQuestion.new({ 'tablingMember_ses' => [12345, 67890] }) }

      it 'returns first item' do
        expect(written_question.tabling_member).to eq(12345)
      end
    end
  end

  describe 'answering_member' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(written_question.answering_member).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:written_question) { WrittenQuestion.new({ 'answeringMember_ses' => [] }) }
      it 'returns nil' do
        expect(written_question.answering_member).to be_nil
      end
    end

    context 'where data exists' do
      let!(:written_question) { WrittenQuestion.new({ 'answeringMember_ses' => [12345, 67890] }) }

      it 'returns first item' do
        expect(written_question.answering_member).to eq(12345)
      end
    end
  end

  describe 'question_text' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(written_question.question_text).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:written_question) { WrittenQuestion.new({ 'answeringMember_ses' => [] }) }
      it 'returns nil' do
        expect(written_question.question_text).to be_nil
      end
    end

    context 'where data exists' do
      let!(:written_question) { WrittenQuestion.new({ 'answeringMember_ses' => [12345, 67890] }) }

      it 'returns first item' do
        expect(written_question.answering_member).to eq(12345)
      end
    end
  end

  describe 'attachment' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(written_question.attachment).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:written_question) { WrittenQuestion.new({ 'attachmentTitle_t' => [] }) }
      it 'returns nil' do
        expect(written_question.attachment).to be_nil
      end
    end

    context 'where data exists' do
      let!(:written_question) { WrittenQuestion.new({ 'attachmentTitle_t' => ['first item', 'second item'] }) }

      it 'returns all items' do
        expect(written_question.attachment).to eq(['first item', 'second item'])
      end
    end
  end

  describe 'transferred?' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(written_question.transferred?).to be_nil
      end
    end

    context 'where there is no value' do
      let!(:written_question) { WrittenQuestion.new({ 'transferredQuestion_b' => nil }) }
      it 'returns nil' do
        expect(written_question.transferred?).to be_nil
      end
    end

    context 'where data exists' do
      context 'where true' do
        let!(:written_question) { WrittenQuestion.new({ 'transferredQuestion_b' => 'true' }) }
        it 'returns true' do
          expect(written_question.transferred?).to eq(true)
        end
      end

      context 'where false' do
        let!(:written_question) { WrittenQuestion.new({ 'transferredQuestion_b' => 'false' }) }
        it 'returns false' do
          expect(written_question.transferred?).to eq(false)
        end
      end
    end
  end
end