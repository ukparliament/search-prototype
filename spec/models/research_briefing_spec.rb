require 'rails_helper'

RSpec.describe ResearchBriefing, type: :model do
  let!(:research_briefing) { ResearchBriefing.new({}) }

  describe 'template' do
    it 'returns a string' do
      expect(research_briefing.template).to be_a(String)
    end
  end

  describe 'object_name' do
    it 'returns object subtype' do
      allow(research_briefing).to receive(:subtype).and_return({ value: 12345, field_name: 'subtype_ses' })
      expect(research_briefing.object_name).to eq({ value: 12345, field_name: 'subtype_ses' })
    end
  end

  describe 'content' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(research_briefing.content).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:research_briefing) { ResearchBriefing.new({ 'content_t' => [] }) }
      it 'returns nil' do
        expect(research_briefing.content).to be_nil
      end
    end

    context 'where data exists' do
      let!(:research_briefing) { ResearchBriefing.new({ 'content_t' => ['first item', 'second item'] }) }

      it 'returns the first item' do
        expect(research_briefing.content).to eq({ :field_name => "content_t", :value => "first item" })
      end
    end
  end

  describe 'html_summary' do
    # TODO: test html handling
    context 'where there is no data' do
      it 'returns nil' do
        expect(research_briefing.html_summary).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:research_briefing) { ResearchBriefing.new({ 'htmlsummary_t' => [] }) }
      it 'returns nil' do
        expect(research_briefing.html_summary).to be_nil
      end
    end

    context 'where data exists' do
      let!(:research_briefing) { ResearchBriefing.new({ 'htmlsummary_t' => ['first item', 'second item'] }) }

      it 'returns the first item' do
        expect(research_briefing.html_summary).to eq({ :field_name => "htmlsummary_t", :value => "first item" })
      end
    end
  end

  describe 'published?' do
    # test example - get first as boolean
    context 'where there is no data' do
      it 'returns nil' do
        expect(research_briefing.is_published).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:research_briefing) { ResearchBriefing.new({ 'published_b' => [] }) }
      it 'returns nil' do
        expect(research_briefing.is_published).to be_nil
      end
    end

    context 'where data exists' do
      context 'where a string representing a boolean' do
        let!(:research_briefing) { ResearchBriefing.new({ 'published_b' => ['true'] }) }

        it 'returns the relevant boolean' do
          expect(research_briefing.is_published).to eq({ :field_name => "published_b", :value => true })
        end
      end
      context 'where not a boolean value' do
        let!(:research_briefing) { ResearchBriefing.new({ 'published_b' => ['first item', 'second item'] }) }

        it 'returns nil' do
          expect(research_briefing.is_published).to eq(nil)
        end
      end
    end
  end

  describe 'published_by' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(research_briefing.published_by).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:research_briefing) { ResearchBriefing.new({ 'publisher_ses' => [] }) }
      it 'returns nil' do
        expect(research_briefing.published_by).to be_nil
      end
    end

    context 'where data exists' do
      let!(:research_briefing) { ResearchBriefing.new({ 'publisher_ses' => [12345, 54321] }) }

      it 'returns the first item' do
        expect(research_briefing.published_by).to eq({ :field_name => "publisher_ses", :value => 12345 })
      end
    end
  end

  describe 'creators' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(research_briefing.creators).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:research_briefing) { ResearchBriefing.new({ 'creator_ses' => [], 'creator_t' => [] }) }
      it 'returns nil' do
        expect(research_briefing.creators).to be_nil
      end
    end

    context 'where data exists' do
      let!(:research_briefing) { ResearchBriefing.new({ 'creator_ses' => [12345, 54321], 'creator_t' => [67890, 98765] }) }

      it 'returns all items' do
        expect(research_briefing.creators).to match_array([{ :field_name => "creator_ses", :value => 12345 },
                                                           { :field_name => "creator_ses", :value => 54321 },
                                                           { :field_name => "creator_t", :value => 67890 },
                                                           { :field_name => "creator_t", :value => 98765 }])
      end
    end
  end

  describe 'contributors' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(research_briefing.contributors).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:research_briefing) { ResearchBriefing.new({ 'contributor_ses' => [], 'contibutor_t' => [] }) }
      it 'returns nil' do
        expect(research_briefing.contributors).to be_nil
      end
    end

    context 'where data exists' do
      let!(:research_briefing) { ResearchBriefing.new({ 'contributor_ses' => [12345, 54321], 'contributor_t' => [67890, 98765] }) }

      it 'returns all items' do
        expect(research_briefing.contributors).to match_array([{ :field_name => "contributor_ses", :value => 12345 },
                                                               { :field_name => "contributor_ses", :value => 54321 },
                                                               { :field_name => "contributor_t", :value => 67890 },
                                                               { :field_name => "contributor_t", :value => 98765 }])
      end
    end
  end

  describe 'creators_and_contributors' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(research_briefing.creators_and_contributors).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:research_briefing) { ResearchBriefing.new({ 'contributor_ses' => [], 'contributor_t' => [], 'creator_ses' => [], 'creator_t' => [] }) }
      it 'returns nil' do
        expect(research_briefing.creators_and_contributors).to be_nil
      end
    end

    context 'where data exists' do
      let!(:research_briefing) { ResearchBriefing.new({ 'contributor_ses' => [12345, 54321], 'contributor_t' => [67890, 98765], 'creator_ses' => [87654, 54321], 'creator_t' => [34567, 76543] }) }

      it 'returns all items' do
        expect(research_briefing.creators_and_contributors).to match_array([
                                                                             { :field_name => "contributor_ses", :value => 12345 },
                                                                             { :field_name => "contributor_ses", :value => 54321 },
                                                                             { :field_name => "contributor_t", :value => 67890 },
                                                                             { :field_name => "contributor_t", :value => 98765 },
                                                                             { :field_name => "creator_ses", :value => 87654 },
                                                                             { :field_name => "creator_ses", :value => 54321 },
                                                                             { :field_name => "creator_t", :value => 34567 },
                                                                             { :field_name => "creator_t", :value => 76543 }])
      end
    end
  end

  describe 'published_on' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(research_briefing.published_on).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:research_briefing) { ResearchBriefing.new({ 'created_dt' => [] }) }
      it 'returns nil' do
        expect(research_briefing.published_on).to be_nil
      end
    end

    context 'where data exists' do
      context 'where data is parsable as a datetime' do
        let!(:research_briefing) { ResearchBriefing.new({ 'created_dt' => ["2015-06-01T18:00:15.73Z", "2014-06-01T18:00:15.73Z"] }) }

        it 'returns the first string parsed as a datetime in the London timezone' do
          expect(research_briefing.published_on).to eq({ :field_name => "created_dt", :value => "Mon, 01 Jun 2015, 19:00:15.73".in_time_zone("London").to_datetime })
        end
      end
      context 'where data is not parsable as a datetime' do
        let!(:research_briefing) { ResearchBriefing.new({ 'created_dt' => ["first item", "second item"] }) }

        it 'returns nil' do
          expect(research_briefing.published_on).to be_nil
        end
      end
    end
  end

  describe 'last_updated' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(research_briefing.last_updated).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:research_briefing) { ResearchBriefing.new({ 'modified_dt' => [] }) }
      it 'returns nil' do
        expect(research_briefing.last_updated).to be_nil
      end
    end

    context 'where data exists' do
      context 'where data is parsable as a datetime' do
        let!(:research_briefing) { ResearchBriefing.new({ 'modified_dt' => ["2015-06-01T18:00:15.73Z", "2014-06-01T18:00:15.73Z"] }) }

        it 'returns the first string parsed as a datetime in the London timezone' do
          expect(research_briefing.last_updated).to eq({ :field_name => "modified_dt", :value => "Mon, 01 Jun 2015, 19:00:15.73".in_time_zone("London").to_datetime })
        end
      end
      context 'where data is not parsable as a datetime' do
        let!(:research_briefing) { ResearchBriefing.new({ 'modified_dt' => ["first item", "second item"] }) }

        it 'returns nil' do
          expect(research_briefing.last_updated).to be_nil
        end
      end
    end
  end

  describe 'reference' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(research_briefing.reference).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:research_briefing) { ResearchBriefing.new({ 'identifier_t' => [] }) }
      it 'returns nil' do
        expect(research_briefing.reference).to be_nil
      end
    end

    context 'where data exists' do
      let!(:research_briefing) { ResearchBriefing.new({ 'identifier_t' => ['first item', 'second item'] }) }

      it 'returns all items' do
        expect(research_briefing.reference).to eq([{ :field_name => "identifier_t", :value => "first item" }, { :field_name => "identifier_t", :value => "second item" }])
      end
    end
  end

  describe 'subjects' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(research_briefing.subjects).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:research_briefing) { ResearchBriefing.new({ 'subject_ses' => [] }) }
      it 'returns nil' do
        expect(research_briefing.subjects).to be_nil
      end
    end

    context 'where data exists' do
      let!(:research_briefing) { ResearchBriefing.new({ 'subject_ses' => ['first item', 'second item'] }) }

      it 'returns all items as an array' do
        expect(research_briefing.subjects).to eq([{ :field_name => "subject_ses", :value => "first item" }, { :field_name => "subject_ses", :value => "second item" }])
      end
    end
  end

  describe 'legislation' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(research_briefing.legislation).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:research_briefing) { ResearchBriefing.new({ 'legislationTitle_ses' => [] }) }
      it 'returns nil' do
        expect(research_briefing.legislation).to be_nil
      end
    end

    context 'where data exists' do
      let!(:research_briefing) { ResearchBriefing.new({ 'legislationTitle_ses' => [12345, 67890] }) }

      it 'returns all items as an array' do
        expect(research_briefing.legislation).to eq([{ :field_name => "legislationTitle_ses", :value => 12345 }, { :field_name => "legislationTitle_ses", :value => 67890 }])
      end
    end
  end

  describe 'external_location_uri' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(research_briefing.external_location_uri).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:research_briefing) { ResearchBriefing.new({ 'externalLocation_uri' => [] }) }
      it 'returns nil' do
        expect(research_briefing.external_location_uri).to be_nil
      end
    end

    context 'where data exists' do
      let!(:research_briefing) { ResearchBriefing.new({ 'externalLocation_uri' => ['first item', 'second item'] }) }

      it 'returns the first item' do
        expect(research_briefing.external_location_uri).to eq({ :field_name => "externalLocation_uri", :value => "first item" })
      end
    end
  end

  describe 'content_location_uri' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(research_briefing.content_location_uri).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:research_briefing) { ResearchBriefing.new({ 'contentLocation_uri' => [] }) }
      it 'returns nil' do
        expect(research_briefing.content_location_uri).to be_nil
      end
    end

    context 'where data exists' do
      let!(:research_briefing) { ResearchBriefing.new({ 'contentLocation_uri' => ['first item', 'second item'] }) }

      it 'returns the first item' do
        expect(research_briefing.content_location_uri).to eq({ :field_name => "contentLocation_uri", :value => "first item" })
      end
    end
  end
end