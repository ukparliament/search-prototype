require 'rails_helper'

RSpec.describe EuropeanScrutinyRecommendation, type: :model do
  let!(:european_scrutiny_recommendation) { EuropeanScrutinyRecommendation.new({}) }

  describe 'template' do
    it 'returns a string' do
      expect(european_scrutiny_recommendation.template).to be_a(String)
    end
  end

  describe 'object_name' do
    it 'returns object type' do
      allow(european_scrutiny_recommendation).to receive(:type).and_return({ value: 12345, field_name: 'type_ses' })
      expect(european_scrutiny_recommendation.object_name).to eq({ value: 12345, field_name: 'type_ses' })
    end
  end

  describe 'decision' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(european_scrutiny_recommendation.decision).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:european_scrutiny_recommendation) { EuropeanScrutinyRecommendation.new({ 'decisionType_t' => [] }) }
      it 'returns nil' do
        expect(european_scrutiny_recommendation.decision).to be_nil
      end
    end

    context 'where data exists' do
      let!(:european_scrutiny_recommendation) { EuropeanScrutinyRecommendation.new({ 'decisionType_t' => ['first item', 'second item'] }) }

      it 'returns the first item' do
        expect(european_scrutiny_recommendation.decision).to eq({ :field_name => "decisionType_t", :value => "first item" })
      end
    end
  end

  describe 'assessment' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(european_scrutiny_recommendation.assessment).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:european_scrutiny_recommendation) { EuropeanScrutinyRecommendation.new({ 'assessment_t' => [] }) }
      it 'returns nil' do
        expect(european_scrutiny_recommendation.assessment).to be_nil
      end
    end

    context 'where data exists' do
      let!(:european_scrutiny_recommendation) { EuropeanScrutinyRecommendation.new({ 'assessment_t' => ['first item', 'second item'] }) }

      it 'returns the first item' do
        expect(european_scrutiny_recommendation.assessment).to eq({ :field_name => "assessment_t", :value => "first item" })
      end
    end
  end

  describe 'status' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(european_scrutiny_recommendation.status).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:european_scrutiny_recommendation) { EuropeanScrutinyRecommendation.new({ 'scrutinyProgress_t' => [] }) }
      it 'returns nil' do
        expect(european_scrutiny_recommendation.status).to be_nil
      end
    end

    context 'where data exists' do
      let!(:european_scrutiny_recommendation) { EuropeanScrutinyRecommendation.new({ 'scrutinyProgress_t' => ['first item', 'second item'] }) }

      it 'returns the first item' do
        expect(european_scrutiny_recommendation.status).to eq({ :field_name => "scrutinyProgress_t", :value => "first item" })
      end
    end
  end

  describe 'report_number' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(european_scrutiny_recommendation.report_number).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:european_scrutiny_recommendation) { EuropeanScrutinyRecommendation.new({ 'reportTitle_t' => [] }) }
      it 'returns nil' do
        expect(european_scrutiny_recommendation.report_number).to be_nil
      end
    end

    context 'where data exists' do
      let!(:european_scrutiny_recommendation) { EuropeanScrutinyRecommendation.new({ 'reportTitle_t' => ['first item', 'second item'] }) }

      it 'returns the first item' do
        expect(european_scrutiny_recommendation.report_number).to eq({ :field_name => "reportTitle_t", :value => "first item" })
      end
    end
  end

  describe 'report_date' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(european_scrutiny_recommendation.report_date).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:european_scrutiny_recommendation) { EuropeanScrutinyRecommendation.new({ 'reportDate_dt' => [] }) }
      it 'returns nil' do
        expect(european_scrutiny_recommendation.report_date).to be_nil
      end
    end

    context 'where data exists' do
      context 'where data is parsable as a datetime (BST)' do
        let!(:european_scrutiny_recommendation) { EuropeanScrutinyRecommendation.new({ 'reportDate_dt' => ["2015-06-01T18:00:15.73Z", "2014-06-01T18:00:15.73Z"] }) }

        it 'returns the first string parsed as a datetime in the London timezone' do
          expect(european_scrutiny_recommendation.report_date[:value]).to eq("Mon, 01 Jun 2015, 19:00:15.73".in_time_zone('London').to_datetime)
        end
      end
      context 'where data is present in date_dt only' do
        let!(:european_scrutiny_recommendation) { EuropeanScrutinyRecommendation.new({ 'date_dt' => ["2015-06-01T18:00:15.73Z", "2014-06-01T18:00:15.73Z"] }) }

        it 'returns the first string parsed as a datetime in the London timezone' do
          expect(european_scrutiny_recommendation.report_date[:value]).to eq("Mon, 01 Jun 2015, 19:00:15.73".in_time_zone('London').to_datetime)
        end
      end
      context 'where data is present in date_dt as well as reportDate_dt' do
        let!(:european_scrutiny_recommendation) { EuropeanScrutinyRecommendation.new({ 'reportDate_dt' => ["2015-06-01T18:00:15.73Z", "2014-06-01T18:00:15.73Z"], 'date_dt' => ["2017-06-01T18:00:15.73Z", "2016-06-01T18:00:15.73Z"] }) }

        it 'returns the first string parsed as a datetime in the London timezone' do
          expect(european_scrutiny_recommendation.report_date[:value]).to eq("Mon, 01 Jun 2015, 19:00:15.73".in_time_zone('London').to_datetime)
        end
      end
      context 'where data is parsable as a datetime (GMT)' do
        let!(:european_scrutiny_recommendation) { EuropeanScrutinyRecommendation.new({ 'reportDate_dt' => ["2015-02-01T18:00:15.73Z", "2014-06-01T18:00:15.73Z"] }) }

        it 'returns the first string parsed as a datetime in the London timezone' do
          expect(european_scrutiny_recommendation.report_date[:value]).to eq("Sun, 01 Feb 2015, 18:00:15.73".in_time_zone('London').to_datetime)
        end
      end
      context 'where data is not parsable as a datetime' do
        let!(:european_scrutiny_recommendation) { EuropeanScrutinyRecommendation.new({ 'reportDate_dt' => ["first item", "second item"] }) }

        it 'returns nil' do
          expect(european_scrutiny_recommendation.report_date).to be_nil
        end
      end
    end
  end

  describe 'debate_date' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(european_scrutiny_recommendation.debate_date).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:european_scrutiny_recommendation) { EuropeanScrutinyRecommendation.new({ 'debateDate_dt' => [] }) }
      it 'returns nil' do
        expect(european_scrutiny_recommendation.debate_date).to be_nil
      end
    end

    context 'where data exists' do
      context 'where data is parsable as a datetime (BST)' do
        let!(:european_scrutiny_recommendation) { EuropeanScrutinyRecommendation.new({ 'debateDate_dt' => ["2015-06-01T18:00:15.73Z", "2014-06-01T18:00:15.73Z"] }) }

        it 'returns the first string parsed as a datetime in the London timezone' do
          expect(european_scrutiny_recommendation.debate_date[:value]).to eq("Mon, 01 Jun 2015, 19:00:15.73".in_time_zone('London').to_datetime)
        end
      end
      context 'where data is parsable as a datetime (GMT)' do
        let!(:european_scrutiny_recommendation) { EuropeanScrutinyRecommendation.new({ 'debateDate_dt' => ["2015-02-01T18:00:15.73Z", "2014-06-01T18:00:15.73Z"] }) }

        it 'returns the first string parsed as a datetime in the London timezone' do
          expect(european_scrutiny_recommendation.debate_date[:value]).to eq("Sun, 01 Feb 2015, 18:00:15.73".in_time_zone('London').to_datetime)
        end
      end
      context 'where data is not parsable as a datetime' do
        let!(:european_scrutiny_recommendation) { EuropeanScrutinyRecommendation.new({ 'debateDate_dt' => ["first item", "second item"] }) }

        it 'returns nil' do
          expect(european_scrutiny_recommendation.debate_date).to be_nil
        end
      end
    end
  end
end