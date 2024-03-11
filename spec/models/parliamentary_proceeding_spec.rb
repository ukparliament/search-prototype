require 'rails_helper'

RSpec.describe ParliamentaryProceeding, type: :model do
  let!(:parliamentary_proceeding) { ParliamentaryProceeding.new({}) }

  describe 'template' do
    it 'returns a string' do
      expect(parliamentary_proceeding.template).to be_a(String)
    end
  end

  describe 'contributions' do

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

  describe 'previous version' do
    context 'there is no previous version link' do
      let!(:parliamentary_proceeding) { ParliamentaryProceeding.new({ 'childContribution_uri' => nil }) }
      it 'returns nil' do
        expect(parliamentary_proceeding.contributions).to be_nil
      end
    end

    context 'previous version link is present' do
      let!(:parliamentary_proceeding) { ParliamentaryProceeding.new({ 'childContribution_uri' => ['contributions_link'] }) }
      let!(:contribution) { ProceedingContribution.new({}) }
      let!(:returned_objects) { { items: [contribution] } }

      it 'performs a search for the url and returns data on the related object' do
        allow_any_instance_of(ObjectsFromUriList).to receive(:get_objects).and_return(returned_objects)
        allow(ObjectsFromUriList).to receive(:new).and_return(ObjectsFromUriList.new(['contributions_link']))
        expect(ObjectsFromUriList).to receive(:new).with(['contributions_link'])
        expect(parliamentary_proceeding.contributions).to eq({ :contribution_data => [{ :member => nil, :reference => nil, :text => nil, :uri => nil }], :contribution_ses_data => nil })
      end
    end

    context 'multiple previous version links are present' do
      let!(:parliamentary_proceeding) { ParliamentaryProceeding.new({ 'childContribution_uri' => ['contributions_link_1', 'contributions_link_2'] }) }
      let!(:contribution1) { ProceedingContribution.new({}) }
      let!(:contribution2) { ProceedingContribution.new({}) }
      let!(:returned_objects) { { items: [contribution1, contribution2] } }

      it 'performs a search for the urls and returns data on the objects' do
        allow_any_instance_of(ObjectsFromUriList).to receive(:get_objects).and_return(returned_objects)
        allow(ObjectsFromUriList).to receive(:new).and_return(ObjectsFromUriList.new(['contributions_link_1', 'contributions_link_2']))
        expect(ObjectsFromUriList).to receive(:new).with(['contributions_link_1', 'contributions_link_2'])
        expect(parliamentary_proceeding.contributions).to eq({ :contribution_data => [{ :member => nil, :reference => nil, :text => nil, :uri => nil }, { :member => nil, :reference => nil, :text => nil, :uri => nil }], :contribution_ses_data => nil })
      end
    end
  end
end