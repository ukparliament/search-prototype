require 'rails_helper'

RSpec.describe Paper, type: :model do
  let!(:paper) { Paper.new({}) }

  describe 'coming_into_force' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(paper.coming_into_force).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:paper) { Paper.new({ 'comingIntoForceNotes_t' => [] }) }
      it 'returns nil' do
        expect(paper.coming_into_force).to be_nil
      end
    end

    context 'where data exists' do
      let!(:paper) { Paper.new({ 'comingIntoForceNotes_t' => ['first item', 'second item'] }) }

      it 'returns the first item' do
        expect(paper.coming_into_force).to eq({ :field_name => "comingIntoForceNotes_t", :value => "first item" })
      end
    end
  end

  describe 'referred_to' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(paper.referred_to).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:paper) { Paper.new({ 'referral_t' => [] }) }
      it 'returns nil' do
        expect(paper.referred_to).to be_nil
      end
    end

    context 'where data exists' do
      let!(:paper) { Paper.new({ 'referral_t' => ['first item', 'second item'] }) }

      it 'returns the first item' do
        expect(paper.referred_to).to eq({ :field_name => "referral_t", :value => "first item" })
      end
    end
  end

  describe 'laying_authority' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(paper.laying_authority).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:paper) { Paper.new({ 'authority_t' => [] }) }
      it 'returns nil' do
        expect(paper.laying_authority).to be_nil
      end
    end

    context 'where data exists' do
      let!(:paper) { Paper.new({ 'authority_t' => ['first item', 'second item'] }) }

      it 'returns the first item' do
        expect(paper.laying_authority).to eq({ :field_name => "authority_t", :value => "first item" })
      end
    end
  end

  describe 'member_name' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(paper.member_name).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:paper) { Paper.new({ 'memberPrinted_t' => [] }) }
      it 'returns nil' do
        expect(paper.member_name).to be_nil
      end
    end

    context 'where data exists' do
      let!(:paper) { Paper.new({ 'memberPrinted_t' => ['first item', 'second item'] }) }

      it 'returns the first item' do
        expect(paper.member_name).to eq({ :field_name => "memberPrinted_t", :value => "first item" })
      end
    end
  end

  describe 'coming_into_force_date' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(paper.coming_into_force_date).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:paper) { Paper.new({ 'comingIntoForce_dt' => [] }) }
      it 'returns nil' do
        expect(paper.coming_into_force_date).to be_nil
      end
    end

    context 'where data exists' do
      context 'where data is parsable as a datetime (BST)' do
        let!(:paper) { Paper.new({ 'comingIntoForce_dt' => ["2015-06-01T18:00:15.73Z", "2014-06-01T18:00:15.73Z"] }) }

        it 'returns the first string parsed as a datetime in the London timezone' do
          expect(paper.coming_into_force_date[:value]).to eq("Mon, 01 Jun 2015, 19:00:15.73".in_time_zone('London').to_datetime)
        end
      end
      context 'where data is parsable as a datetime (GMT)' do
        let!(:paper) { Paper.new({ 'comingIntoForce_dt' => ["2015-02-01T18:00:15.73Z", "2014-06-01T18:00:15.73Z"] }) }

        it 'returns the first string parsed as a datetime in the London timezone' do
          expect(paper.coming_into_force_date[:value]).to eq("Sun, 01 Feb 2015, 18:00:15.73".in_time_zone('London').to_datetime)
        end
      end
      context 'where data is not parsable as a datetime' do
        let!(:paper) { Paper.new({ 'comingIntoForce_dt' => ["first item", "second item"] }) }

        it 'returns nil' do
          expect(paper.coming_into_force_date).to be_nil
        end
      end
    end
  end

  describe 'date_laid' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(paper.date_laid).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:paper) { Paper.new({ 'dateLaid_dt' => [] }) }
      it 'returns nil' do
        expect(paper.date_laid).to be_nil
      end
    end

    context 'where data exists' do
      context 'where data is parsable as a datetime (BST)' do
        let!(:paper) { Paper.new({ 'dateLaid_dt' => ["2015-06-01T18:00:15.73Z", "2014-06-01T18:00:15.73Z"] }) }

        it 'returns the first string parsed as a datetime in the London timezone' do
          expect(paper.date_laid[:value]).to eq("Mon, 01 Jun 2015, 19:00:15.73".in_time_zone('London').to_datetime)
        end
      end
      context 'where data is parsable as a datetime (GMT)' do
        let!(:paper) { Paper.new({ 'dateLaid_dt' => ["2015-02-01T18:00:15.73Z", "2014-06-01T18:00:15.73Z"] }) }

        it 'returns the first string parsed as a datetime in the London timezone' do
          expect(paper.date_laid[:value]).to eq("Sun, 01 Feb 2015, 18:00:15.73".in_time_zone('London').to_datetime)
        end
      end
      context 'where data is not parsable as a datetime' do
        let!(:paper) { Paper.new({ 'dateLaid_dt' => ["first item", "second item"] }) }

        it 'returns nil' do
          expect(paper.date_laid).to be_nil
        end
      end
    end
  end

  describe 'date_approved' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(paper.date_approved).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:paper) { Paper.new({ 'dateApproved_dt' => [] }) }
      it 'returns nil' do
        expect(paper.date_approved).to be_nil
      end
    end

    context 'where data exists' do
      context 'where data is parsable as a datetime (BST)' do
        let!(:paper) { Paper.new({ 'dateApproved_dt' => ["2015-06-01T18:00:15.73Z", "2014-06-01T18:00:15.73Z"] }) }

        it 'returns the first string parsed as a datetime in the London timezone' do
          expect(paper.date_approved[:value]).to eq("Mon, 01 Jun 2015, 19:00:15.73".in_time_zone('London').to_datetime)
        end
      end
      context 'where data is parsable as a datetime (GMT)' do
        let!(:paper) { Paper.new({ 'dateApproved_dt' => ["2015-02-01T18:00:15.73Z", "2014-06-01T18:00:15.73Z"] }) }

        it 'returns the first string parsed as a datetime in the London timezone' do
          expect(paper.date_approved[:value]).to eq("Sun, 01 Feb 2015, 18:00:15.73".in_time_zone('London').to_datetime)
        end
      end
      context 'where data is not parsable as a datetime' do
        let!(:paper) { Paper.new({ 'dateApproved_dt' => ["first item", "second item"] }) }

        it 'returns nil' do
          expect(paper.date_approved).to be_nil
        end
      end
    end
  end

  describe 'date_made' do
    # example test - get first as date
    context 'where there is no data' do
      it 'returns nil' do
        expect(paper.date_made).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:paper) { Paper.new({ 'dateMade_dt' => [] }) }
      it 'returns nil' do
        expect(paper.date_made).to be_nil
      end
    end

    context 'where data exists' do
      context 'where data is parsable as a datetime (BST)' do
        let!(:paper) { Paper.new({ 'dateMade_dt' => ["2015-06-01T18:00:15.73Z", "2014-06-01T18:00:15.73Z"] }) }

        it 'returns the first string parsed as a datetime in the London timezone' do
          expect(paper.date_made[:value]).to eq("Mon, 01 Jun 2015, 19:00:15.73".in_time_zone('London').to_datetime)
        end
      end
      context 'where data is parsable as a datetime (GMT)' do
        let!(:paper) { Paper.new({ 'dateMade_dt' => ["2015-02-01T18:00:15.73Z", "2014-06-01T18:00:15.73Z"] }) }

        it 'returns the first string parsed as a datetime in the London timezone' do
          expect(paper.date_made[:value]).to eq("Sun, 01 Feb 2015, 18:00:15.73".in_time_zone('London').to_datetime)
        end
      end
      context 'where data is not parsable as a datetime' do
        let!(:paper) { Paper.new({ 'dateMade_dt' => ["first item", "second item"] }) }

        it 'returns nil' do
          expect(paper.date_made).to be_nil
        end
      end
    end
  end

  describe 'date_withdrawn' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(paper.date_withdrawn).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:paper) { Paper.new({ 'dateWithdrawn_dt' => [] }) }
      it 'returns nil' do
        expect(paper.date_withdrawn).to be_nil
      end
    end

    context 'where data exists' do
      context 'where data is parsable as a datetime (BST)' do
        let!(:paper) { Paper.new({ 'dateWithdrawn_dt' => ["2015-06-01T18:00:15.73Z", "2014-06-01T18:00:15.73Z"] }) }

        it 'returns the first string parsed as a datetime in the London timezone' do
          expect(paper.date_withdrawn[:value]).to eq("Mon, 01 Jun 2015, 19:00:15.73".in_time_zone('London').to_datetime)
        end
      end
      context 'where data is parsable as a datetime (GMT)' do
        let!(:paper) { Paper.new({ 'dateWithdrawn_dt' => ["2015-02-01T18:00:15.73Z", "2014-06-01T18:00:15.73Z"] }) }

        it 'returns the first string parsed as a datetime in the London timezone' do
          expect(paper.date_withdrawn[:value]).to eq("Sun, 01 Feb 2015, 18:00:15.73".in_time_zone('London').to_datetime)
        end
      end
      context 'where data is not parsable as a datetime' do
        let!(:paper) { Paper.new({ 'dateWithdrawn_dt' => ["first item", "second item"] }) }

        it 'returns nil' do
          expect(paper.date_withdrawn).to be_nil
        end
      end
    end
  end

  describe 'reported_by_joint_committee?' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(paper.is_reported_by_joint_committee).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:paper) { Paper.new({ 'jointCommitteeOnStatutoryInstruments_b' => [] }) }
      it 'returns nil' do
        expect(paper.is_reported_by_joint_committee).to be_nil
      end
    end

    context 'where data exists' do
      context 'where a string representing a boolean' do
        let!(:paper) { Paper.new({ 'jointCommitteeOnStatutoryInstruments_b' => ['true'] }) }

        it 'returns the relevant boolean' do
          expect(paper.is_reported_by_joint_committee).to eq({ :field_name => "jointCommitteeOnStatutoryInstruments_b", :value => true })
        end
      end
      context 'where not a boolean value' do
        let!(:paper) { Paper.new({ 'jointCommitteeOnStatutoryInstruments_b' => ['first item', 'second item'] }) }

        it 'returns nil' do
          expect(paper.is_reported_by_joint_committee).to eq(nil)
        end
      end
    end
  end

  describe 'laid_in_draft?' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(paper.is_laid_in_draft).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:paper) { Paper.new({ 'draft_b' => [] }) }
      it 'returns nil' do
        expect(paper.is_laid_in_draft).to be_nil
      end
    end

    context 'where data exists' do
      context 'where a string representing a boolean' do
        let!(:paper) { Paper.new({ 'draft_b' => ['true'] }) }

        it 'returns the relevant boolean' do
          expect(paper.is_laid_in_draft).to eq({ :field_name => "draft_b", :value => true })
        end
      end
      context 'where not a boolean value' do
        let!(:paper) { Paper.new({ 'draft_b' => ['first item', 'second item'] }) }

        it 'returns nil' do
          expect(paper.is_laid_in_draft).to eq(nil)
        end
      end
    end
  end

  describe 'paper type' do
    context 'where there are subtypes' do
      let!(:paper) { Paper.new({ 'type_ses' => [12345], 'subtype_ses' => [56789, 86420] }) }

      it 'returns all subtypes' do
        expect(paper.paper_type).to eq([{ field_name: 'subtype_ses', value: 56789 },
                                        { field_name: 'subtype_ses', value: 86420 }])
      end
    end
    context 'where there are no subtypes' do
      let!(:paper) { Paper.new({ 'type_ses' => [12345], 'subtype_ses' => [] }) }
      it 'returns nil' do
        expect(paper.paper_type).to be_nil
      end
    end
  end
end