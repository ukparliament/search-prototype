require 'rails_helper'

RSpec.describe WrittenStatement, type: :model do
  let!(:written_statement) { WrittenStatement.new({}) }

  describe 'template' do
    it 'returns a string' do
      expect(written_statement.template).to be_a(String)
    end
  end

  describe 'object_name' do
    it 'returns a string' do
      expect(written_statement.object_name).to be_a(String)
    end
  end

  describe 'attachment' do
    # disabled - awaiting feedback
    context 'where there is no data' do
      it 'returns nil' do
        expect(written_statement.attachment).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:written_statement) { WrittenStatement.new({ 'attachment_t' => [] }) }
      it 'returns nil' do
        expect(written_statement.attachment).to be_nil
      end
    end

    context 'where data exists' do
      let!(:written_statement) { WrittenStatement.new({ 'attachment_t' => ['first item', 'second item'] }) }

      it 'returns all items as an array' do
        expect(written_statement.attachment).to eq(['first item', 'second item'])
      end
    end
  end

  describe 'notes' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(written_statement.notes).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:written_statement) { WrittenStatement.new({ 'notes_t' => [] }) }
      it 'returns nil' do
        expect(written_statement.notes).to be_nil
      end
    end

    context 'where data exists' do
      let!(:written_statement) { WrittenStatement.new({ 'notes_t' => ['first item', 'second item'] }) }

      it 'returns the first item' do
        expect(written_statement.notes).to eq('first item')
      end
    end
  end

  describe 'member' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(written_statement.member).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:written_statement) { WrittenStatement.new({ 'member_ses' => [] }) }
      it 'returns nil' do
        expect(written_statement.member).to be_nil
      end
    end

    context 'where data exists' do
      let!(:written_statement) { WrittenStatement.new({ 'member_ses' => [12345, 67890] }) }

      it 'returns first item' do
        expect(written_statement.member).to eq(12345)
      end
    end
  end

  describe 'member_party' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(written_statement.member_party).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:written_statement) { WrittenStatement.new({ 'memberParty_ses' => [] }) }
      it 'returns nil' do
        expect(written_statement.member_party).to be_nil
      end
    end

    context 'where data exists' do
      let!(:written_statement) { WrittenStatement.new({ 'memberParty_ses' => [12345, 67890] }) }

      it 'returns first item' do
        expect(written_statement.member_party).to eq(12345)
      end
    end
  end

  describe 'legislature' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(written_statement.legislature).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:written_statement) { WrittenStatement.new({ 'legislature_ses' => [] }) }
      it 'returns nil' do
        expect(written_statement.legislature).to be_nil
      end
    end

    context 'where data exists' do
      let!(:written_statement) { WrittenStatement.new({ 'legislature_ses' => ['first item', 'second item'] }) }

      it 'returns first item' do
        expect(written_statement.legislature).to eq('first item')
      end
    end
  end

  describe 'corrected?' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(written_statement.corrected?).to be_nil
      end
    end

    context 'where there is no value' do
      let!(:written_statement) { WrittenStatement.new({ 'correctedWmsMc_b' => nil }) }
      it 'returns nil' do
        expect(written_statement.corrected?).to be_nil
      end
    end

    context 'where data exists' do
      context 'where true' do
        let!(:written_statement) { WrittenStatement.new({ 'correctedWmsMc_b' => 'true' }) }
        it 'returns true' do
          expect(written_statement.corrected?).to eq(true)
        end
      end

      context 'where false' do
        let!(:written_statement) { WrittenStatement.new({ 'correctedWmsMc_b' => 'false' }) }
        it 'returns false' do
          expect(written_statement.corrected?).to eq(false)
        end
      end
    end
  end

  describe 'department' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(written_statement.department).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:written_statement) { WrittenStatement.new({ 'department_ses' => [] }) }
      it 'returns nil' do
        expect(written_statement.department).to be_nil
      end
    end

    context 'where data exists' do
      let!(:written_statement) { WrittenStatement.new({ 'department_ses' => [12345, 67890] }) }

      it 'returns first item' do
        expect(written_statement.department).to eq(12345)
      end
    end
  end

  describe 'statement_date' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(written_statement.statement_date).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:written_statement) { WrittenStatement.new({ 'date_dt' => [] }) }
      it 'returns nil' do
        expect(written_statement.statement_date).to be_nil
      end
    end

    context 'where data exists' do
      context 'where data is a valid date' do
        let!(:written_statement) { WrittenStatement.new({ 'date_dt' => Date.today.to_s }) }
        it 'returns a date object' do
          expect(written_statement.statement_date).to eq(Date.today)
        end
      end
      context 'where data is not a valid date' do
        let!(:written_statement) { WrittenStatement.new({ 'date_dt' => 'date' }) }
        it 'returns nil' do
          expect(written_statement.statement_date).to be_nil
        end
      end
    end
  end
end