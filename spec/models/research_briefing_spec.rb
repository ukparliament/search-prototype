require 'rails_helper'

RSpec.describe ResearchBriefing, type: :model do
  let!(:research_briefing) { ResearchBriefing.new({}) }

  describe 'template' do
    it 'returns a string' do
      expect(research_briefing.template).to be_a(String)
    end
  end

  describe 'object_name' do
    it 'returns a string' do
      expect(research_briefing.object_name).to be_a(String)
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
        expect(research_briefing.content).to eq('first item')
      end
    end
  end

  describe 'html_summary' do
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
        expect(research_briefing.html_summary).to eq('first item')
      end
    end
  end

  describe 'published?' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(research_briefing.published?).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:research_briefing) { ResearchBriefing.new({ 'published_b' => [] }) }
      it 'returns nil' do
        expect(research_briefing.published?).to be_nil
      end
    end

    context 'where data exists' do
      context 'where a string representing a boolean' do
        let!(:research_briefing) { ResearchBriefing.new({ 'published_b' => ['true'] }) }

        it 'returns the relevant boolean' do
          expect(research_briefing.published?).to eq(true)
        end
      end
      context 'where not a boolean value' do
        let!(:research_briefing) { ResearchBriefing.new({ 'published_b' => ['first item', 'second item'] }) }

        it 'returns false' do
          expect(research_briefing.published?).to eq(false)
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
        expect(research_briefing.published_by).to eq(12345)
      end
    end
  end

  describe 'creator' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(research_briefing.creator).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:research_briefing) { ResearchBriefing.new({ 'creator_ses' => [] }) }
      it 'returns nil' do
        expect(research_briefing.creator).to be_nil
      end
    end

    context 'where data exists' do
      let!(:research_briefing) { ResearchBriefing.new({ 'creator_ses' => [12345, 54321] }) }

      it 'returns the first item' do
        expect(research_briefing.creator).to eq(12345)
      end
    end
  end

  describe 'publisher_string' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(research_briefing.publisher_string).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:research_briefing) { ResearchBriefing.new({ 'publisherSnapshot_s' => [] }) }
      it 'returns nil' do
        expect(research_briefing.publisher_string).to be_nil
      end
    end

    context 'where data exists' do
      let!(:research_briefing) { ResearchBriefing.new({ 'publisherSnapshot_s' => ['first item', 'second item'] }) }

      it 'returns the first item' do
        expect(research_briefing.publisher_string).to eq('first item')
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
      context 'where data is parsable as a date' do
        let!(:research_briefing) { ResearchBriefing.new({ 'created_dt' => ["2015-06-01T18:00:15.73Z", "2014-06-01T18:00:15.73Z"] }) }

        it 'returns the first string parsed as a date' do
          expect(research_briefing.published_on).to eq("Mon, 01 Jun 2015".to_date)
        end
      end
      context 'where data is not parsable as a date' do
        let!(:research_briefing) { ResearchBriefing.new({ 'created_dt' => ["first item", "second item"] }) }

        it 'returns nil' do
          expect(research_briefing.published_on).to be_nil
        end
      end
    end
  end

  describe 'updated_on' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(research_briefing.updated_on).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:research_briefing) { ResearchBriefing.new({ 'dateLastModified_dt' => [] }) }
      it 'returns nil' do
        expect(research_briefing.updated_on).to be_nil
      end
    end

    context 'where data exists' do
      context 'where data is parsable as a date' do
        let!(:research_briefing) { ResearchBriefing.new({ 'dateLastModified_dt' => ["2015-06-01T18:00:15.73Z", "2014-06-01T18:00:15.73Z"] }) }

        it 'returns the first string parsed as a date' do
          expect(research_briefing.updated_on).to eq("Mon, 01 Jun 2015".to_date)
        end
      end
      context 'where data is not parsable as a date' do
        let!(:research_briefing) { ResearchBriefing.new({ 'dateLastModified_dt' => ["first item", "second item"] }) }

        it 'returns nil' do
          expect(research_briefing.updated_on).to be_nil
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

      it 'returns the first item' do
        expect(research_briefing.reference).to eq('first item')
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
      let!(:research_briefing) { ResearchBriefing.new({ 'subject_sesrollup' => [] }) }
      it 'returns nil' do
        expect(research_briefing.subjects).to be_nil
      end
    end

    context 'where data exists' do
      let!(:research_briefing) { ResearchBriefing.new({ 'subject_sesrollup' => ['first item', 'second item'] }) }

      it 'returns all items as an array' do
        expect(research_briefing.subjects).to eq(['first item', 'second item'])
      end
    end
  end

  # disabled due to lack of test data
  xdescribe 'legislation' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(research_briefing.legislation).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:research_briefing) { ResearchBriefing.new({ '' => [] }) }
      it 'returns nil' do
        expect(research_briefing.legislation).to be_nil
      end
    end

    context 'where data exists' do
      let!(:research_briefing) { ResearchBriefing.new({ '' => ['first item', 'second item'] }) }

      it 'returns all items as an array' do
        expect(research_briefing.legislation).to eq(['first item', 'second item'])
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
        expect(research_briefing.external_location_uri).to eq('first item')
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
        expect(research_briefing.content_location_uri).to eq('first item')
      end
    end
  end

  describe 'publisher_logo_partial' do
    context 'where publisher is missing' do
      let!(:research_briefing) { ResearchBriefing.new({ 'publisherSnapshot_s' => [] }) }

      it 'returns nil' do
        expect(research_briefing.publisher_logo_partial).to be_nil
      end
    end

    context 'where publisher is present' do
      let!(:research_briefing) { ResearchBriefing.new({ 'publisherSnapshot_s' => ['a publisher name'] }) }

      it 'returns a path to a partial' do
        expect(research_briefing.publisher_logo_partial).to eq('/search/logo_svgs/a-publisher-name')
      end
    end
  end

  describe 'display_link' do
    context 'no links are present' do
      let!(:research_briefing) { ResearchBriefing.new({ 'internalLocation_uri' => [], 'externalLocation_uri' => [] }) }

      it 'returns nil' do
        expect(research_briefing.display_link).to be_nil
      end
    end

    context 'internal link is present, external link is not present' do
      let!(:research_briefing) { ResearchBriefing.new({ 'internalLocation_uri' => ['www.example.com'], 'externalLocation_uri' => [] }) }

      it 'returns the internal link' do
        expect(research_briefing.display_link).to eq('www.example.com')
      end
    end

    context 'internal link is present, external link is present' do
      let!(:research_briefing) { ResearchBriefing.new({ 'internalLocation_uri' => ['www.example.com'], 'externalLocation_uri' => ['www.test.com'] }) }

      it 'returns the external link' do
        expect(research_briefing.display_link).to eq('www.test.com')
      end
    end

    context 'internal link is not present, external link is present' do
      let!(:research_briefing) { ResearchBriefing.new({ 'internalLocation_uri' => [], 'externalLocation_uri' => ['www.test.com'] }) }

      it 'returns the external link' do
        expect(research_briefing.display_link).to eq('www.test.com')
      end
    end
  end
end