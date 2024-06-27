require 'rails_helper'

RSpec.describe ParliamentaryProceeding, type: :model do
  let!(:parliamentary_proceeding) { ParliamentaryProceeding.new({}) }

  describe 'template' do
    it 'returns a string' do
      expect(parliamentary_proceeding.template).to be_a(String)
    end
  end

  describe 'answering_members' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(parliamentary_proceeding.answering_members).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:parliamentary_proceeding) { ParliamentaryProceeding.new({ 'answeringMember_ses' => [] }) }
      it 'returns nil' do
        expect(parliamentary_proceeding.answering_members).to be_nil
      end
    end

    context 'where data exists' do
      let!(:parliamentary_proceeding) { ParliamentaryProceeding.new({ 'answeringMember_ses' => [12345, 67890] }) }

      it 'returns all items' do
        expect(parliamentary_proceeding.answering_members).to eq([
                                                                   { field_name: 'answeringMember_ses', value: 12345 },
                                                                   { field_name: 'answeringMember_ses', value: 67890 }
                                                                 ])
      end
    end
  end

  describe 'contribution_ids' do
    context 'there is no previous version link' do
      let!(:parliamentary_proceeding) { ParliamentaryProceeding.new({ 'childContribution_uri' => nil }) }
      it 'returns nil' do
        expect(parliamentary_proceeding.contribution_ids).to be_nil
      end
    end

    context 'previous version link is present' do
      let!(:parliamentary_proceeding) { ParliamentaryProceeding.new({ 'childContribution_uri' => ['contributions_link'] }) }

      it 'returns the ID' do
        expect(parliamentary_proceeding.contribution_ids).to eq(['contributions_link'])
      end
    end

    context 'multiple previous version links are present' do
      let!(:parliamentary_proceeding) { ParliamentaryProceeding.new({ 'childContribution_uri' => ['contributions_link_1', 'contributions_link_2'] }) }

      it 'returns both IDs' do
        expect(parliamentary_proceeding.contribution_ids).to eq(['contributions_link_1', 'contributions_link_2'])
      end
    end
  end
end