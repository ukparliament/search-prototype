require 'rails_helper'

RSpec.describe EuropeanMaterial, type: :model do
  let!(:european_material) { EuropeanMaterial.new({}) }

  describe 'template' do
    it 'returns a string' do
      expect(european_material.template).to be_a(String)
    end
  end

  describe 'object_name' do
    it 'returns object type' do
      allow(european_material).to receive(:type).and_return({ value: 12345, field_name: 'type_ses' })
      expect(european_material.object_name).to eq({ value: 12345, field_name: 'type_ses' })
    end
  end

  describe 'category' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(european_material.category).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:european_material) { EuropeanMaterial.new({ 'category_ses' => [] }) }
      it 'returns nil' do
        expect(european_material.category).to be_nil
      end
    end

    context 'where data exists' do
      let!(:european_material) { EuropeanMaterial.new({ 'category_ses' => [12345, 67890] }) }

      it 'returns the first item' do
        expect(european_material.category).to eq({ :field_name => "category_ses", :value => 12345 })
      end
    end
  end

  describe 'reference' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(european_material.reference).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:european_material) { EuropeanMaterial.new({ 'referenceNumber_t' => [] }) }
      it 'returns nil' do
        expect(european_material.reference).to be_nil
      end
    end

    context 'where data exists' do
      let!(:european_material) { EuropeanMaterial.new({ 'referenceNumber_t' => ['first item', 'second item'] }) }

      it 'returns the first item' do
        expect(european_material.reference).to eq({ :field_name => "referenceNumber_t", :value => "first item" })
      end
    end
  end

  describe 'rapporteur' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(european_material.rapporteur).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:european_material) { EuropeanMaterial.new({ 'mep_ses' => [] }) }
      it 'returns nil' do
        expect(european_material.rapporteur).to be_nil
      end
    end

    context 'where data exists' do
      let!(:european_material) { EuropeanMaterial.new({ 'mep_ses' => [12345, 67890] }) }

      it 'returns the first item' do
        expect(european_material.rapporteur).to eq({ :field_name => "mep_ses", :value => 12345 })
      end
    end
  end

  describe 'eu_parliament_committee' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(european_material.eu_parliament_committee).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:european_material) { EuropeanMaterial.new({ 'ep_committee_t' => [] }) }
      it 'returns nil' do
        expect(european_material.eu_parliament_committee).to be_nil
      end
    end

    context 'where data exists' do
      let!(:european_material) { EuropeanMaterial.new({ 'ep_committee_t' => ['first item', 'second item'] }) }

      it 'returns the first item' do
        expect(european_material.eu_parliament_committee).to eq({ :field_name => "ep_committee_t", :value => "first item" })
      end
    end
  end

  describe 'publisher' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(european_material.publisher).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:european_material) { EuropeanMaterial.new({ 'publisher_t' => [] }) }
      it 'returns nil' do
        expect(european_material.publisher).to be_nil
      end
    end

    context 'where data exists' do
      let!(:european_material) { EuropeanMaterial.new({ 'publisher_t' => ['first item', 'second item'] }) }

      it 'returns the first item' do
        expect(european_material.publisher).to eq({ :field_name => "publisher_t", :value => "first item" })
      end
    end
  end

  describe 'published_date' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(european_material.published_date).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:european_material) { EuropeanMaterial.new({ 'dateEntered_dt' => [] }) }
      it 'returns nil' do
        expect(european_material.published_date).to be_nil
      end
    end

    context 'where data exists' do
      context 'where data is parsable as a datetime (BST)' do
        let!(:european_material) { EuropeanMaterial.new({ 'dateEntered_dt' => ["2015-06-01T18:00:15.73Z", "2014-06-01T18:00:15.73Z"] }) }

        it 'returns the first string parsed as a datetime in the London timezone' do
          expect(european_material.published_date[:value]).to eq("Mon, 01 Jun 2015, 19:00:15.73".in_time_zone('London').to_datetime)
        end
      end
      context 'where data is parsable as a datetime (GMT)' do
        let!(:european_material) { EuropeanMaterial.new({ 'dateEntered_dt' => ["2015-02-01T18:00:15.73Z", "2014-06-01T18:00:15.73Z"] }) }

        it 'returns the first string parsed as a datetime in the London timezone' do
          expect(european_material.published_date[:value]).to eq("Sun, 01 Feb 2015, 18:00:15.73".in_time_zone('London').to_datetime)
        end
      end
      context 'where data is not parsable as a datetime' do
        let!(:european_material) { EuropeanMaterial.new({ 'dateEntered_dt' => ["first item", "second item"] }) }

        it 'returns nil' do
          expect(european_material.published_date).to be_nil
        end
      end
    end
  end
end