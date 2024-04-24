require 'rails_helper'

RSpec.describe ContentObject, type: :model do
  let!(:content_object) { ContentObject.new({}) }

  describe 'self.generate' do
    context 'when passed invalid data' do
      let!(:test_data) { { "some_data" => [12345] } }
      it 'returns an instance of the ContentObject class' do
        expect(ContentObject.generate(test_data)).to be_an_instance_of(ContentObject)
      end
    end
    context 'when passed an unknown object type' do
      let!(:test_data) { { "type_ses" => [12345] } }

      it 'returns an instance of the ContentObject class' do
        expect(ContentObject.generate(test_data)).to be_an_instance_of(ContentObject)
      end
    end
    context 'when passed a known object type' do
      let!(:edm) { { "type_ses" => [90996] } }
      let!(:research_briefing) { { "type_ses" => [346697] } }
      let!(:written_question) { { "type_ses" => [93522] } }
      let!(:written_statement) { { "type_ses" => [352211] } }
      let!(:church_of_england_measure) { { "type_ses" => [347125] } }
      let!(:private_act) { { "type_ses" => [352234] } }
      let!(:public_act) { { "type_ses" => [347135] } }
      let!(:ministerial_correction) { { "type_ses" => [92034] } }
      let!(:impact_assessment) { { "type_ses" => [91613] } }
      let!(:deposited_paper) { { "type_ses" => [347163] } }
      let!(:transport_and_works_act_order_application) { { "type_ses" => [360977] } }
      let!(:bill) { { "type_ses" => [347122] } }
      let!(:paper_petition) { { "type_ses" => [92435], "subtype_ses" => [479373] } }
      let!(:observations_on_a_petition) { { "type_ses" => [92435], "subtype_ses" => [347214] } }
      let!(:petition_with_unrecognised_subtype_id) { { "type_ses" => [92435], "subtype_ses" => [11111] } }
      let!(:formal_proceeding) { { "type_ses" => [347207] } }
      let!(:parliamentary_paper_reported) { { "type_ses" => [352156] } }
      let!(:parliamentary_paper_laid) { { "type_ses" => [92347], "subtype_ses" => [51288] } }
      let!(:paper_ordered_to_be_printed1) { { "type_ses" => [92347], "subtype_ses" => [528119] } }
      let!(:paper_ordered_to_be_printed2) { { "type_ses" => [92347], "subtype_ses" => [528127] } }
      let!(:paper_submitted) { { "type_ses" => [92347], "subtype_ses" => [528129] } }
      let!(:parliamentary_paper_laid_command_paper) { { "type_ses" => [90587] } }
      let!(:parliamentary_paper_laid_unprinted_command_paper) { { "type_ses" => [352261] } }
      let!(:parliamentary_paper_laid_house_of_commons_paper) { { "type_ses" => [91561] } }
      let!(:parliamentary_paper_laid_house_of_lords_paper) { { "type_ses" => [91563] } }
      let!(:parliamentary_paper_laid_unprinted_paper) { { "type_ses" => [51288] } }
      let!(:oral_question) { { "type_ses" => [92277] } }
      let!(:oral_answer_to_question) { { "type_ses" => [286676] } }
      let!(:oral_question_time_intervention) { { "type_ses" => [356748] } }
      let!(:proceeding_contribution) { { "type_ses" => [356750] } }
      let!(:parliamentary_proceeding_grand_committee) { { "type_ses" => [352161] } }
      let!(:parliamentary_proceeding_committee) { { "type_ses" => [352151] } }
      let!(:parliamentary_proceeding) { { "type_ses" => [352179] } }
      let!(:statutory_instrument) { { "type_ses" => [347226] } }
      let!(:european_deposited_document) { { "type_ses" => [347028] } }
      let!(:european_scrutiny_explanatory_memorandum) { { "type_ses" => [347036] } }
      let!(:european_scrutiny_ministerial_correspondence) { { "type_ses" => [347040] } }
      let!(:european_scrutiny_recommendation) { { "type_ses" => [347032] } }
      let!(:european_material) { { "type_ses" => [347010] } }
      let!(:unrecognised_id) { { "type_ses" => [11111] } }

      it 'returns an instance of the type class' do
        expect(ContentObject.generate(edm)).to be_an_instance_of(Edm)
        expect(ContentObject.generate(research_briefing)).to be_an_instance_of(ResearchBriefing)
        expect(ContentObject.generate(written_question)).to be_an_instance_of(WrittenQuestion)
        expect(ContentObject.generate(written_statement)).to be_an_instance_of(WrittenStatement)
        expect(ContentObject.generate(church_of_england_measure)).to be_an_instance_of(ChurchOfEnglandMeasure)
        expect(ContentObject.generate(private_act)).to be_an_instance_of(PrivateAct)
        expect(ContentObject.generate(public_act)).to be_an_instance_of(PublicAct)
        expect(ContentObject.generate(ministerial_correction)).to be_an_instance_of(MinisterialCorrection)
        expect(ContentObject.generate(impact_assessment)).to be_an_instance_of(ImpactAssessment)
        expect(ContentObject.generate(deposited_paper)).to be_an_instance_of(DepositedPaper)
        expect(ContentObject.generate(transport_and_works_act_order_application)).to be_an_instance_of(TransportAndWorksActOrderApplication)
        expect(ContentObject.generate(bill)).to be_an_instance_of(Bill)
        expect(ContentObject.generate(paper_petition)).to be_an_instance_of(PaperPetition)
        expect(ContentObject.generate(observations_on_a_petition)).to be_an_instance_of(ObservationsOnPetitions)
        expect(ContentObject.generate(petition_with_unrecognised_subtype_id)).to be_an_instance_of(ContentObject)
        expect(ContentObject.generate(formal_proceeding)).to be_an_instance_of(FormalProceeding)
        expect(ContentObject.generate(parliamentary_paper_reported)).to be_an_instance_of(ParliamentaryCommittee)
        expect(ContentObject.generate(parliamentary_paper_laid)).to be_an_instance_of(ParliamentaryPaperLaid)
        expect(ContentObject.generate(paper_ordered_to_be_printed1)).to be_an_instance_of(PaperOrderedToBePrinted)
        expect(ContentObject.generate(paper_ordered_to_be_printed2)).to be_an_instance_of(PaperOrderedToBePrinted)
        expect(ContentObject.generate(paper_submitted)).to be_an_instance_of(PaperSubmitted)
        expect(ContentObject.generate(parliamentary_paper_laid_command_paper)).to be_an_instance_of(ParliamentaryPaperLaid)
        expect(ContentObject.generate(parliamentary_paper_laid_unprinted_command_paper)).to be_an_instance_of(ParliamentaryPaperLaid)
        expect(ContentObject.generate(parliamentary_paper_laid_house_of_commons_paper)).to be_an_instance_of(ParliamentaryPaperLaid)
        expect(ContentObject.generate(parliamentary_paper_laid_house_of_lords_paper)).to be_an_instance_of(ParliamentaryPaperLaid)
        expect(ContentObject.generate(parliamentary_paper_laid_unprinted_paper)).to be_an_instance_of(ParliamentaryPaperLaid)
        expect(ContentObject.generate(oral_question)).to be_an_instance_of(OralQuestion)
        expect(ContentObject.generate(oral_answer_to_question)).to be_an_instance_of(OralAnswerToQuestion)
        expect(ContentObject.generate(oral_question_time_intervention)).to be_an_instance_of(OralQuestionTimeIntervention)
        expect(ContentObject.generate(proceeding_contribution)).to be_an_instance_of(ProceedingContribution)
        expect(ContentObject.generate(parliamentary_proceeding_grand_committee)).to be_an_instance_of(GrandCommitteeProceeding)
        expect(ContentObject.generate(parliamentary_proceeding_committee)).to be_an_instance_of(CommitteeProceeding)
        expect(ContentObject.generate(parliamentary_proceeding)).to be_an_instance_of(ParliamentaryProceeding)
        expect(ContentObject.generate(statutory_instrument)).to be_an_instance_of(StatutoryInstrument)
        expect(ContentObject.generate(european_deposited_document)).to be_an_instance_of(EuropeanDepositedDocument)
        expect(ContentObject.generate(european_scrutiny_explanatory_memorandum)).to be_an_instance_of(EuropeanScrutinyExplanatoryMemorandum)
        expect(ContentObject.generate(european_scrutiny_ministerial_correspondence)).to be_an_instance_of(EuropeanScrutinyMinisterialCorrespondence)
        expect(ContentObject.generate(european_scrutiny_recommendation)).to be_an_instance_of(EuropeanScrutinyRecommendation)
        expect(ContentObject.generate(european_material)).to be_an_instance_of(EuropeanMaterial)
        expect(ContentObject.generate(unrecognised_id)).to be_an_instance_of(ContentObject)
      end
    end
  end

  describe 'page_title' do
    context 'when passed invalid data' do
      let!(:content_object) { ContentObject.new(test_data) }
      let!(:test_data) { { "some_data" => [12345] } }
      it 'returns nil' do
        expect(content_object.page_title).to be_nil
      end
    end
    context 'when title is present in the data' do
      let!(:content_object) { ContentObject.new(test_data) }
      let!(:test_data) { { "title_t" => ['The Title'] } }

      it 'returns the title text as an array item' do
        expect(content_object.page_title).to be_an(Array)
        expect(content_object.page_title.first).to eq('The Title')
      end
    end
  end

  describe 'has_link?' do
    context 'when display link is nil' do
      let!(:content_object) { ContentObject.new(test_data) }
      let!(:test_data) { { "some_data" => [12345] } }

      it 'returns false' do
        expect(content_object.has_link?).to eq(false)
      end
    end
    context 'when display link is populated' do
      let!(:content_object) { ContentObject.new(test_data) }
      let!(:test_data) { { "externalLocation_uri" => ['www.example.com'] } }

      it 'returns true' do
        expect(content_object.has_link?).to eq(true)
      end
    end
  end

  describe 'display_link' do
    let!(:content_object) { ContentObject.new(test_data) }
    context 'when neither external location uri or external location text are present' do
      let!(:test_data) { {} }
      it 'returns nil' do
        expect(content_object.display_link).to be_nil
      end
    end
    context 'when only external location uri is present' do
      let!(:test_data) { { "externalLocation_uri" => ['test_link_1', 'test_link_2'] } }
      it 'returns the first link from external location uri' do
        expect(content_object.display_link).to eq({ field_name: 'externalLocation_uri', value: 'test_link_1' })
      end
    end
    context 'when only external location text is present' do
      let!(:test_data) { { "externalLocation_t" => ['test_link_3', 'test_link_4'] } }
      it 'returns the first link from external location text' do
        expect(content_object.display_link).to eq({ field_name: 'externalLocation_t', value: 'test_link_3' })
      end
    end
    context 'when both external location uri and external location text are present' do
      let!(:test_data) { { "externalLocation_uri" => ['test_link_1', 'test_link_2'], "externalLocation_t" => ['test_link_3', 'test_link__4'] } }
      it 'returns the first link from external location uri' do
        expect(content_object.display_link).to eq({ field_name: 'externalLocation_uri', value: 'test_link_1' })
      end
    end
  end

  describe 'contains_explanatory_memo?' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(content_object.contains_explanatory_memo).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:content_object) { ContentObject.new({ 'containsEM_b' => [] }) }
      it 'returns nil' do
        expect(content_object.contains_explanatory_memo).to be_nil
      end
    end

    context 'where data exists' do
      context 'where a string representing a boolean' do
        let!(:content_object) { ContentObject.new({ 'containsEM_b' => ['true'] }) }

        it 'returns the relevant boolean' do
          expect(content_object.contains_explanatory_memo).to eq({ :field_name => "containsEM_b", :value => true })
        end
      end
      context 'where not a boolean value' do
        let!(:content_object) { ContentObject.new({ 'containsEM_b' => ['first item', 'second item'] }) }

        it 'returns nil' do
          expect(content_object.contains_explanatory_memo).to eq(nil)
        end
      end
    end
  end

  describe 'contains_impact_assessment?' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(content_object.contains_impact_assessment).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:content_object) { ContentObject.new({ 'containsIA_b' => [] }) }
      it 'returns nil' do
        expect(content_object.contains_impact_assessment).to be_nil
      end
    end

    context 'where data exists' do
      context 'where a string representing a boolean' do
        let!(:content_object) { ContentObject.new({ 'containsIA_b' => ['true'] }) }

        it 'returns the relevant boolean' do
          expect(content_object.contains_impact_assessment).to eq({ :field_name => "containsIA_b", :value => true })
        end
      end
      context 'where not a boolean value' do
        let!(:content_object) { ContentObject.new({ 'containsIA_b' => ['first item', 'second item'] }) }

        it 'returns nil' do
          expect(content_object.contains_impact_assessment).to eq(nil)
        end
      end
    end
  end

  describe 'related_items' do
    let!(:content_object) { ContentObject.new(test_data) }
    context 'where there is no data' do
      let!(:test_data) { {} }

      it 'returns nil' do
        expect(content_object.related_items).to be_nil
      end
    end

    context 'where relation_t is populated' do
      context 'where relation_t is an array of strings' do
        let!(:test_data) { { "relation_t" => ["test1", "test2"] } }
        let!(:solr_multi_query_object) { SolrMultiQuery.new(test_data) }
        let!(:related_item_1) { ContentObject.new({}) }

        it 'passes the strings to a new instance of SolrMultiQuery' do
          expect(SolrMultiQuery).to receive(:new).with({ :object_uris => ["test1", "test2"] }).and_return(solr_multi_query_object)
          allow_any_instance_of(SolrMultiQuery).to receive(:object_data).and_return(['test'])
          allow_any_instance_of(SesLookup).to receive(:data).and_return('SES data')

          allow(ContentObject).to receive(:generate).and_return(related_item_1)

          expect(content_object.related_items).to eq({ items: [related_item_1], ses_lookup: 'SES data' })
        end
      end
    end
  end

  describe 'contribution_type' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(content_object.contribution_type).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:content_object) { ContentObject.new({ 'contributionType_t' => [] }) }
      it 'returns nil' do
        expect(content_object.contribution_type).to be_nil
      end
    end

    context 'where data exists' do
      let!(:content_object) { ContentObject.new({ 'contributionType_t' => ['first item', 'second item'] }) }

      it 'returns the first item' do
        expect(content_object.contribution_type).to eq({ :field_name => "contributionType_t", :value => "first item" })
      end
    end
  end

  describe 'subtype_or_type' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(content_object.subtype_or_type).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:content_object) { ContentObject.new({ 'type_ses' => [], 'subtype_ses' => [] }) }
      it 'returns nil' do
        expect(content_object.subtype_or_type).to be_nil
      end
    end

    context 'where subtype id exists' do
      let!(:content_object) { ContentObject.new({ 'type_ses' => [12345, 23456], 'subtype_ses' => [56789, 67890] }) }

      it 'returns the first item from subtype_ses' do
        expect(content_object.subtype_or_type).to eq({ :field_name => "subtype_ses", :value => 56789 })
      end
    end

    context 'where only type id exists' do
      let!(:content_object) { ContentObject.new({ 'type_ses' => [12345, 23456], 'subtype_ses' => [] }) }

      it 'returns the first item from type_ses' do
        expect(content_object.subtype_or_type).to eq({ :field_name => "type_ses", :value => 12345 })
      end
    end
  end

  describe 'subtypes_or_type' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(content_object.subtypes_or_type).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:content_object) { ContentObject.new({ 'type_ses' => [], 'subtype_ses' => [] }) }
      it 'returns nil' do
        expect(content_object.subtypes_or_type).to be_nil
      end
    end

    context 'where subtype id exists' do
      let!(:content_object) { ContentObject.new({ 'type_ses' => [12345, 23456], 'subtype_ses' => [56789, 67890] }) }

      it 'returns all items from subtype_ses' do
        expect(content_object.subtypes_or_type).to eq([{ :field_name => "subtype_ses", :value => 56789 }, { :field_name => "subtype_ses", :value => 67890 }])
      end
    end

    context 'where only type id exists' do
      let!(:content_object) { ContentObject.new({ 'type_ses' => [12345, 23456], 'subtype_ses' => [] }) }

      it 'returns the first item from type_ses in an array' do
        expect(content_object.subtypes_or_type).to eq([{ :field_name => "type_ses", :value => 12345 }])
      end
    end
  end

  describe 'procedure_scrutiny_period' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(content_object.procedure_scrutiny_period).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:content_object) { ContentObject.new({ 'approvalDays_t' => [] }) }
      it 'returns nil' do
        expect(content_object.procedure_scrutiny_period).to be_nil
      end
    end

    context 'where data exists' do
      let!(:content_object) { ContentObject.new({ 'approvalDays_t' => ['first item', 'second item'] }) }

      it 'returns the first item' do
        expect(content_object.procedure_scrutiny_period).to eq({ :field_name => "approvalDays_t", :value => "first item" })
      end
    end
  end

  describe 'contribution_text' do
    # example test - get first as html
    context 'where there is no data' do
      it 'returns nil' do
        expect(content_object.contribution_text).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:content_object) { ContentObject.new({ 'contributionText_t' => [] }) }
      it 'returns nil' do
        expect(content_object.contribution_text).to be_nil
      end
    end

    context 'where data exists' do
      let!(:content_object) { ContentObject.new({ 'contributionText_t' => ['&lt;p&gt; text in paragraph tags &lt;/p&gt;', '&lt;strong&gt; more content using tags &lt;/strong&gt;'] }) }

      it 'returns the first item having unescaped any escaped html tags' do
        expect(content_object.contribution_text).to eq({ :field_name => "contributionText_t", :value => "<p> text in paragraph tags </p>" })
      end
    end
  end

  describe 'contribution_short_text' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(content_object.contribution_short_text).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:content_object) { ContentObject.new({ 'contributionText_s' => [] }) }
      it 'returns nil' do
        expect(content_object.contribution_short_text).to be_nil
      end
    end

    context 'where data exists' do
      let!(:content_object) { ContentObject.new({ 'contributionText_s' => ['&lt;p&gt; text in paragraph tags &lt;/p&gt;', '&lt;strong&gt; more content using tags &lt;/strong&gt;'] }) }

      it 'returns the first item having unescaped any escaped html tags' do
        expect(content_object.contribution_short_text).to eq({ :field_name => "contributionText_s", :value => "<p> text in paragraph tags </p>" })
      end
    end
  end

  describe 'external_location_uri' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(content_object.external_location_uri).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:content_object) { ContentObject.new({ 'externalLocation_uri' => [] }) }
      it 'returns nil' do
        expect(content_object.external_location_uri).to be_nil
      end
    end

    context 'where data exists' do
      let!(:content_object) { ContentObject.new({ 'externalLocation_uri' => ['first item', 'second item'] }) }

      it 'returns the first item' do
        expect(content_object.external_location_uri).to eq({ :field_name => "externalLocation_uri", :value => "first item" })
      end
    end
  end

  describe 'external_location_text' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(content_object.external_location_text).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:content_object) { ContentObject.new({ 'externalLocation_t' => [] }) }
      it 'returns nil' do
        expect(content_object.external_location_text).to be_nil
      end
    end

    context 'where data exists' do
      let!(:content_object) { ContentObject.new({ 'externalLocation_t' => ['first item', 'second item'] }) }

      it 'returns the first item' do
        expect(content_object.external_location_text).to eq({ :field_name => "externalLocation_t", :value => "first item" })
      end
    end
  end

  describe 'commons_library_location' do
    # example test - get first
    context 'where there is no data' do
      it 'returns nil' do
        expect(content_object.commons_library_location).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:content_object) { ContentObject.new({ 'commonsLibraryLocation_t' => [] }) }
      it 'returns nil' do
        expect(content_object.commons_library_location).to be_nil
      end
    end

    context 'where data exists' do
      let!(:content_object) { ContentObject.new({ 'commonsLibraryLocation_t' => ['first item', 'second item'] }) }

      it 'returns the first item' do
        expect(content_object.commons_library_location).to eq({ :field_name => "commonsLibraryLocation_t", :value => "first item" })
      end
    end
  end

  describe 'lords_library_location' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(content_object.lords_library_location).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:content_object) { ContentObject.new({ 'lordsLibraryLocation_t' => [] }) }
      it 'returns nil' do
        expect(content_object.lords_library_location).to be_nil
      end
    end

    context 'where data exists' do
      let!(:content_object) { ContentObject.new({ 'lordsLibraryLocation_t' => ['first item', 'second item'] }) }

      it 'returns the first item' do
        expect(content_object.lords_library_location).to eq({ :field_name => "lordsLibraryLocation_t", :value => "first item" })
      end
    end
  end

  describe 'isbn' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(content_object.isbn).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:content_object) { ContentObject.new({ 'ISBN_t' => [] }) }
      it 'returns nil' do
        expect(content_object.isbn).to be_nil
      end
    end

    context 'where data exists' do
      let!(:content_object) { ContentObject.new({ 'ISBN_t' => ['first item', 'second item'] }) }

      it 'returns the first item' do
        expect(content_object.isbn).to eq({ :field_name => "ISBN_t", :value => "first item" })
      end
    end
  end

  describe 'object_uri' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(content_object.object_uri).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:content_object) { ContentObject.new({ 'uri' => [] }) }
      it 'returns nil' do
        expect(content_object.object_uri).to be_nil
      end
    end

    context 'where data exists' do
      let!(:content_object) { ContentObject.new({ 'uri' => 'a test string' }) }

      it 'returns the first item' do
        expect(content_object.object_uri).to eq({ :field_name => "uri", :value => "a test string" })
      end
    end
  end

  describe 'primary_sponsor' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(content_object.primary_sponsor).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:content_object) { ContentObject.new({ 'primarySponsor_ses' => [] }) }
      it 'returns nil' do
        expect(content_object.primary_sponsor).to be_nil
      end
    end

    context 'where data exists' do
      let!(:content_object) { ContentObject.new({ 'primarySponsor_ses' => [12345, 67890] }) }

      it 'returns the first item' do
        expect(content_object.primary_sponsor[:value]).to eq(12345)
      end
    end
  end

  describe 'asking_member' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(content_object.asking_member).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:content_object) { ContentObject.new({ 'askingMember_ses' => [] }) }
      it 'returns nil' do
        expect(content_object.asking_member).to be_nil
      end
    end

    context 'where data exists' do
      let!(:content_object) { ContentObject.new({ 'askingMember_ses' => [12345, 67890] }) }

      it 'returns the first item' do
        expect(content_object.asking_member[:value]).to eq(12345)
      end
    end
  end

  describe 'asking_member_party' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(content_object.asking_member_party).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:content_object) { ContentObject.new({ 'askingMemberParty_ses' => [] }) }
      it 'returns nil' do
        expect(content_object.asking_member_party).to be_nil
      end
    end

    context 'where data exists' do
      let!(:content_object) { ContentObject.new({ 'askingMemberParty_ses' => [12345, 67890] }) }

      it 'returns the first item' do
        expect(content_object.asking_member_party[:value]).to eq(12345)
      end
    end
  end

  describe 'lead_member' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(content_object.lead_member).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:content_object) { ContentObject.new({ 'leadMember_ses' => [] }) }
      it 'returns nil' do
        expect(content_object.lead_member).to be_nil
      end
    end

    context 'where data exists' do
      let!(:content_object) { ContentObject.new({ 'leadMember_ses' => [12345, 67890] }) }

      it 'returns the first item' do
        expect(content_object.lead_member).to eq({ field_name: 'leadMember_ses', value: 12345 })
      end
    end
  end

  describe 'lead_member_party' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(content_object.lead_member_party).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:content_object) { ContentObject.new({ 'leadMemberParty_ses' => [] }) }
      it 'returns nil' do
        expect(content_object.lead_member_party).to be_nil
      end
    end

    context 'where data exists' do
      let!(:content_object) { ContentObject.new({ 'leadMemberParty_ses' => [12345, 67890] }) }

      it 'returns the first item' do
        expect(content_object.lead_member_party).to eq({ field_name: 'leadMemberParty_ses', value: 12345 })
      end
    end
  end

  describe 'lead_members' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(content_object.lead_members).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:content_object) { ContentObject.new({ 'leadMember_ses' => [] }) }
      it 'returns nil' do
        expect(content_object.lead_members).to be_nil
      end
    end

    context 'where data exists' do
      let!(:content_object) { ContentObject.new({ 'leadMember_ses' => [12345, 67890] }) }

      it 'returns all items' do
        expect(content_object.lead_members).to eq([{ field_name: 'leadMember_ses', value: 12345 }, { field_name: 'leadMember_ses', value: 67890 }])
      end
    end
  end

  describe 'corporate_author' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(content_object.corporate_author).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:content_object) { ContentObject.new({ 'corporateAuthor_ses' => [] }) }
      it 'returns nil' do
        expect(content_object.corporate_author).to be_nil
      end
    end

    context 'where data exists' do
      let!(:content_object) { ContentObject.new({ 'corporateAuthor_ses' => [12345, 67890], 'corporateAuthor_t' => ['Author 1', 'Author 2'] }) }

      it 'returns all items from both SES and text fields' do
        expect(content_object.corporate_author).to match_array([
                                                                 { field_name: 'corporateAuthor_ses', value: 12345 },
                                                                 { field_name: 'corporateAuthor_ses', value: 67890 },
                                                                 { field_name: 'corporateAuthor_t', value: 'Author 1' },
                                                                 { field_name: 'corporateAuthor_t', value: 'Author 2' }
                                                               ])
      end
    end
  end

  describe 'witnesses' do
    # example test - get all from
    context 'where there is no data' do
      it 'returns nil' do
        expect(content_object.witnesses).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:content_object) { ContentObject.new({ 'witness_ses' => [] }) }
      it 'returns nil' do
        expect(content_object.witnesses).to be_nil
      end
    end

    context 'where data exists' do
      let!(:content_object) { ContentObject.new({ 'witness_ses' => [12345, 67890] }) }

      it 'returns all items' do
        expect(content_object.witnesses).to eq([
                                                 { field_name: 'witness_ses', value: 12345 },
                                                 { field_name: 'witness_ses', value: 67890 }
                                               ])
      end
    end
  end

  describe 'place' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(content_object.place).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:content_object) { ContentObject.new({ 'place_ses' => [] }) }
      it 'returns nil' do
        expect(content_object.place).to be_nil
      end
    end

    context 'where data exists' do
      let!(:content_object) { ContentObject.new({ 'place_ses' => [12345, 67890] }) }

      it 'returns the first item' do
        expect(content_object.place[:value]).to eq(12345)
      end
    end
  end

  describe 'certified_categories' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(content_object.certified_categories).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:content_object) { ContentObject.new({ 'certifiedCategory_ses' => [] }) }
      it 'returns nil' do
        expect(content_object.certified_categories).to be_nil
      end
    end

    context 'where data exists' do
      let!(:content_object) { ContentObject.new({ 'certifiedCategory_ses' => [12345, 67890] }) }

      it 'returns all items' do
        expect(content_object.certified_categories).to eq([
                                                            { field_name: 'certifiedCategory_ses', value: 12345 },
                                                            { field_name: 'certifiedCategory_ses', value: 67890 }
                                                          ])
      end
    end
  end

  describe 'departments' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(content_object.departments).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:content_object) { ContentObject.new({ 'department_ses' => [] }) }
      it 'returns nil' do
        expect(content_object.departments).to be_nil
      end
    end

    context 'where data exists' do
      let!(:content_object) { ContentObject.new({ 'department_ses' => [12345, 67890] }) }

      it 'returns all items' do
        expect(content_object.departments).to eq([
                                                   { field_name: 'department_ses', value: 12345 },
                                                   { field_name: 'department_ses', value: 67890 }
                                                 ])
      end
    end
  end

  describe 'legislation' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(content_object.legislation).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:content_object) { ContentObject.new({ 'legislationTitle_ses' => [], 'legislationTitle_t' => [] }) }
      it 'returns nil' do
        expect(content_object.legislation).to be_nil
      end
    end

    context 'where data exists in both fields' do
      let!(:content_object) { ContentObject.new({ 'legislationTitle_ses' => [12345, 67890], 'legislationTitle_t' => ['title 1', 'title 2'] }) }

      it 'returns all items' do
        expect(content_object.legislation).to match_array([
                                                            { field_name: 'legislationTitle_ses', value: 12345 },
                                                            { field_name: 'legislationTitle_ses', value: 67890 },
                                                            { field_name: 'legislationTitle_t', value: 'title 1' },
                                                            { field_name: 'legislationTitle_t', value: 'title 2' }
                                                          ])
      end
    end

    context 'where data exists as text' do
      let!(:content_object) { ContentObject.new({ 'legislationTitle_ses' => [], 'legislationTitle_t' => ['title 1', 'title 2'] }) }

      it 'returns all items' do
        expect(content_object.legislation).to match_array([
                                                            { field_name: 'legislationTitle_t', value: 'title 1' },
                                                            { field_name: 'legislationTitle_t', value: 'title 2' }
                                                          ])
      end
    end

    context 'where data exists as SES ids' do
      let!(:content_object) { ContentObject.new({ 'legislationTitle_ses' => [12345, 67890], 'legislationTitle_t' => [] }) }

      it 'returns all items' do
        expect(content_object.legislation).to match_array([
                                                            { field_name: 'legislationTitle_ses', value: 12345 },
                                                            { field_name: 'legislationTitle_ses', value: 67890 }
                                                          ])
      end
    end
  end

  describe 'certified_date' do
    context 'where there is no data' do
      it 'returns nil' do
        expect(content_object.certified_date).to be_nil
      end
    end

    context 'where there is an empty array' do
      let!(:content_object) { ContentObject.new({ 'dateCertified_dt' => [] }) }
      it 'returns nil' do
        expect(content_object.certified_date).to be_nil
      end
    end

    context 'where data exists' do
      context 'where data is parsable as a datetime (BST)' do
        let!(:content_object) { ContentObject.new({ 'dateCertified_dt' => ["2015-06-01T18:00:15.73Z", "2014-06-01T18:00:15.73Z"] }) }

        it 'returns the first string parsed as a datetime in the London timezone' do
          expect(content_object.certified_date[:value]).to eq("Mon, 01 Jun 2015, 19:00:15.73".in_time_zone('London').to_datetime)
        end
      end
      context 'where data is parsable as a datetime (GMT)' do
        let!(:content_object) { ContentObject.new({ 'dateCertified_dt' => ["2015-02-01T18:00:15.73Z", "2014-06-01T18:00:15.73Z"] }) }

        it 'returns the first string parsed as a datetime in the London timezone' do
          expect(content_object.certified_date[:value]).to eq("Sun, 01 Feb 2015, 18:00:15.73".in_time_zone('London').to_datetime)
        end
      end
      context 'where data is not parsable as a datetime' do
        let!(:content_object) { ContentObject.new({ 'dateCertified_dt' => ["first item", "second item"] }) }

        it 'returns nil' do
          expect(content_object.certified_date).to be_nil
        end
      end
    end
  end

  describe 'dual type' do
    it 'returns false' do
      expect(content_object.dual_type?).to eq(false)
    end
  end

  describe 'ministerial correction' do
    it 'returns false' do
      expect(content_object.ministerial_correction?).to eq(false)
    end
  end

end