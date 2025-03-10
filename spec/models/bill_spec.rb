require 'rails_helper'

RSpec.describe Bill, type: :model do
  let!(:bill) { Bill.new({}) }

  describe 'template' do
    it 'returns a string' do
      expect(bill.template).to be_a(String)
    end
  end

  describe 'object_name' do
    it 'returns object type' do
      allow(bill).to receive(:type).and_return({ value: 12345, field_name: 'type_ses' })
      expect(bill.object_name).to eq({ value: 12345, field_name: 'type_ses' })
    end
  end

  describe 'reference' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(bill.reference).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:bill) { Bill.new({ 'identifier_t' => [] }) }
      it 'returns nil' do
        expect(bill.reference).to be_nil
      end
    end

    context 'where data exists' do
      let!(:bill) { Bill.new({ 'identifier_t' => ['first item', 'second item'] }) }

      it 'returns all items' do
        expect(bill.reference).to eq([{ :field_name => "identifier_t", :value => "first item" }, { :field_name => "identifier_t", :value => "second item" }])
      end
    end
  end

  describe 'subjects' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(bill.subjects).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:bill) { Bill.new({ 'subject_ses' => [] }) }
      it 'returns nil' do
        expect(bill.subjects).to be_nil
      end
    end

    context 'where data exists' do
      let!(:bill) { Bill.new({ 'subject_ses' => ['first item', 'second item'] }) }

      it 'returns all items as an array' do
        expect(bill.subjects).to eq([{ :field_name => "subject_ses", :value => "first item" }, { :field_name => "subject_ses", :value => "second item" }])
      end
    end
  end

  describe 'legislation' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(bill.legislation).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:bill) { Bill.new({ 'legislationTitle_ses' => [] }) }
      it 'returns nil' do
        expect(bill.legislation).to be_nil
      end
    end

    context 'where data exists' do
      let!(:bill) { Bill.new({ 'legislationTitle_ses' => [12345, 67890] }) }

      it 'returns all items as an array' do
        expect(bill.legislation).to eq([{ :field_name => "legislationTitle_ses", :value => 12345 }, { :field_name => "legislationTitle_ses", :value => 67890 }])
      end
    end
  end

  describe 'date_of_order' do
    # example test - get first as date
    context 'where there is no data' do
      it 'returns nil' do
        expect(bill.date_of_order).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:bill) { Bill.new({ 'dateOfOrderToPrint_dt' => [] }) }
      it 'returns nil' do
        expect(bill.date_of_order).to be_nil
      end
    end

    context 'where data exists' do
      context 'where data is parsable as a datetime (BST)' do
        let!(:bill) { Bill.new({ 'dateOfOrderToPrint_dt' => ["2015-06-01T18:00:15.73Z", "2014-06-01T18:00:15.73Z"] }) }

        it 'returns the first string parsed as a datetime in the London timezone' do
          expect(bill.date_of_order[:value]).to eq("Mon, 01 Jun 2015, 19:00:15.73".in_time_zone('London').to_datetime)
        end
      end
      context 'where data is parsable as a datetime (GMT)' do
        let!(:bill) { Bill.new({ 'dateOfOrderToPrint_dt' => ["2015-02-01T18:00:15.73Z", "2014-06-01T18:00:15.73Z"] }) }

        it 'returns the first string parsed as a datetime in the London timezone' do
          expect(bill.date_of_order[:value]).to eq("Sun, 01 Feb 2015, 18:00:15.73".in_time_zone('London').to_datetime)
        end
      end
      context 'where data is not parsable as a datetime' do
        let!(:bill) { Bill.new({ 'dateOfOrderToPrint_dt' => ["first item", "second item"] }) }

        it 'returns nil' do
          expect(bill.date_of_order).to be_nil
        end
      end
    end
  end

  describe 'title' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(bill.title).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:bill) { Bill.new({ 'title_t' => [] }) }
      it 'returns nil' do
        expect(bill.title).to be_nil
      end
    end

    context 'where data exists' do
      let!(:bill) { Bill.new({ 'title_t' => 'title string' }) }

      it 'returns the first item' do
        expect(bill.title).to eq({ :field_name => "title_t", :value => "title string" })
      end
    end
  end

  describe 'previous version id' do
    context 'there is no previous version link' do
      let!(:bill) { Bill.new({ 'isVersionOf_t' => nil }) }
      it 'returns nil' do
        expect(bill.previous_version_id).to be_nil
      end
    end

    context 'previous version link is present' do
      let!(:bill) { Bill.new({ 'isVersionOf_t' => ['previous_version_link'] }) }

      it 'returns the url as a string' do
        expect(bill.previous_version_id).to eq('previous_version_link')
      end
    end

    context 'multiple previous version links are present' do
      let!(:bill) { Bill.new({ 'isVersionOf_t' => ['previous_version_link_1', 'previous_version_link_2'] }) }

      it 'returns the first url as a string' do
        expect(bill.previous_version_id).to eq('previous_version_link_1')
      end
    end
  end

  describe 'version title' do
    let!(:bill1) { Bill.new({ 'subtype_ses' => [92585], 'title_t' => 'bill title', 'identifier_t' => ['ID part 1', 'ID part 2'] }) }
    let!(:bill2) { Bill.new({ 'subtype_ses' => [91436], 'title_t' => 'bill title', 'identifier_t' => ['ID part 1', 'ID part 2'] }) }
    
    context 'for any subtype' do
      it 'uses all references, joined with a space' do
        expect(bill1.version_title).to eq('bill title')
        expect(bill2.version_title).to eq('bill title')
      end
    end
  end

end