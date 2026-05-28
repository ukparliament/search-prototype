# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'QueryExpander' do
  let(:query_expander) { QueryExpander.new(search_query, ses_test_class) }
  let(:ses_test_class) { class_double(SesQuery, new: ses_test_instance) }
  let(:ses_test_instance) { instance_double(SesQuery, data: []) }

  context 'one word which is a thesaurus term' do
    let(:search_query) { "Horses" }
    let(:horses_ses_response) { instance_double(SesQuery, data: [{ equivalent_terms: ["Equines", "Ponies"], preferred_term: "Horses", preferred_term_id: "10766" }]) }

    it 'processes the tokens correctly' do
      expect(query_expander).to receive(:process_unquoted_phrase_token).with(search_query).and_call_original
      query_expander.expand_query
    end

    it 'makes the expected SES queries' do
      expect(ses_test_class).to receive(:new).with(({ value: "Horses" })).and_return(horses_ses_response)
      query_expander.expand_query
    end

    it 'returns the expected final result' do
      expect(ses_test_class).to receive(:new).with(({ value: "Horses" })).and_return(horses_ses_response)
      expect(query_expander.expand_query).to eq("\"Horses\" OR \"Equines\" OR \"Ponies\" OR all_ses:10766")
    end
  end

  context 'two words which are not thesaurus terms' do
    let(:search_query) { "Femur chronic" }
    let(:femur_chronic_ses_response) { instance_double(SesQuery, data: []) }

    it 'processes the tokens correctly' do
      expect(query_expander).to receive(:process_unquoted_phrase_token).with(search_query).and_call_original
      query_expander.expand_query
    end

    it 'makes the expected SES queries' do
      expect(ses_test_class).to receive(:new).with(({ value: "Femur chronic" })).and_return(femur_chronic_ses_response)
      query_expander.expand_query
    end

    it 'returns the expected result' do
      expect(ses_test_class).to receive(:new).with(({ value: "Femur chronic" })).and_return(femur_chronic_ses_response)
      expect(query_expander.expand_query).to eq("Femur AND chronic")
    end
  end

  context 'two words which are separate thesaurus terms' do
    let(:search_query) { "Crime Fraud" }
    let(:crime_fraud_ses_response) { instance_double(SesQuery, data: [{ equivalent_terms: ["Law breaking", "Offences", "Street crime"], preferred_term: "Crime", preferred_term_id: "90768" }, { equivalent_terms: ["Embezzlement"], preferred_term: "Fraud", preferred_term_id: "91352" }]) }

    it 'processes the tokens correctly' do
      expect(query_expander).to receive(:process_unquoted_phrase_token).with(search_query).and_call_original
      query_expander.expand_query
    end

    it 'makes the expected SES queries' do
      expect(ses_test_class).to receive(:new).with(({ value: "Crime Fraud" })).and_return(crime_fraud_ses_response)
      query_expander.expand_query
    end

    it 'returns the expected result' do
      expect(ses_test_class).to receive(:new).with(({ value: "Crime Fraud" })).and_return(crime_fraud_ses_response)
      expect(query_expander.expand_query).to eq("(\"Crime\" OR \"Law breaking\" OR \"Offences\" OR \"Street crime\" OR all_ses:90768) AND (\"Fraud\" OR \"Embezzlement\" OR all_ses:91352)")
    end
  end

  context 'two words which make one thesaurus term' do
    let(:search_query) { "Election observers" }
    let(:election_observers_ses_response) { instance_double(SesQuery, data: [{ equivalent_terms: [], preferred_term: "Election observers", preferred_term_id: "91070" }]) }

    it 'processes the tokens correctly' do
      expect(query_expander).to receive(:process_unquoted_phrase_token).with(search_query).and_call_original
      query_expander.expand_query
    end

    it 'makes the expected SES queries' do
      expect(ses_test_class).to receive(:new).with(({ value: "Election observers" })).and_return(election_observers_ses_response)
      query_expander.expand_query
    end

    it 'returns the expected result' do
      expect(ses_test_class).to receive(:new).with(({ value: "Election observers" })).and_return(election_observers_ses_response)
      expect(query_expander.expand_query).to eq("\"Election observers\" OR all_ses:91070")
    end
  end

  context 'one non-thesaurus term and one thesaurus term' do
    let(:search_query) { "Security apparatus" }
    let(:security_apparatus_ses_response) { instance_double(SesQuery, data: [{ equivalent_terms: [], preferred_term: "Security", preferred_term_id: "92947" }]) }

    it 'processes the tokens correctly' do
      expect(query_expander).to receive(:process_unquoted_phrase_token).with(search_query).and_call_original
      query_expander.expand_query
    end

    it 'makes the expected SES queries' do
      expect(ses_test_class).to receive(:new).with(({ value: "Security apparatus" })).and_return(security_apparatus_ses_response)
      query_expander.expand_query
    end

    it 'returns the expected result' do
      expect(ses_test_class).to receive(:new).with(({ value: "Security apparatus" })).and_return(security_apparatus_ses_response)
      expect(query_expander.expand_query).to eq("(\"Security\" OR all_ses:92947) AND apparatus")
    end
  end

  context 'two separate thesaurus terms which in combination form another thesaurus term' do
    let(:search_query) { "Health professions" }
    let(:health_professions_ses_response) { instance_double(SesQuery, data: [{ equivalent_terms: ["Health professionals"], preferred_term: "Health professions", preferred_term_id: "91491" }]) }

    it 'processes the tokens correctly' do
      expect(query_expander).to receive(:process_unquoted_phrase_token).with(search_query).and_call_original
      query_expander.expand_query
    end

    it 'makes the expected SES queries' do
      expect(ses_test_class).to receive(:new).with(({ value: "Health professions" })).and_return(health_professions_ses_response)
      query_expander.expand_query
    end

    it 'returns the expected result' do
      expect(ses_test_class).to receive(:new).with(({ value: "Health professions" })).and_return(health_professions_ses_response)
      expect(query_expander.expand_query).to eq("\"Health professions\" OR \"Health professionals\" OR all_ses:91491")
    end
  end

  context 'three words where the first two form a term and the last two also form a term' do
    let(:search_query) { "Buckingham Palace Barracks" }
    let(:buckingham_palace_barracks_ses_response) { instance_double(SesQuery, data: [{ equivalent_terms: [], preferred_term: "Buckingham Palace", preferred_term_id: "16673" }, { equivalent_terms: [], preferred_term: "Palace Barracks", preferred_term_id: "513229" }]) }

    it 'processes the tokens correctly' do
      expect(query_expander).to receive(:process_unquoted_phrase_token).with(search_query).and_call_original
      query_expander.expand_query
    end

    it 'makes the expected SES queries' do
      expect(ses_test_class).to receive(:new).with(({ value: "Buckingham Palace Barracks" })).and_return(buckingham_palace_barracks_ses_response)
      query_expander.expand_query
    end

    pending 'returns the expected result' do
      # TODO: check whether the expectation is accurate here: do we really want to return results just for the first combination?
      expect(ses_test_class).to receive(:new).with(({ value: "Buckingham Palace Barracks" })).and_return(buckingham_palace_barracks_ses_response)
      expect(query_expander.expand_query).to eq("(\"Buckingham Palace\" OR all_ses:16673) AND barracks")
    end
  end

  context 'non-preferred form of a term is a substring of another word in the search' do
    let(:search_query) { "Balancing British Airways" }
    let(:balancing_british_airways_ses_response) { instance_double(SesQuery, data: [{ equivalent_terms: ["BA"], preferred_term: "British Airways", preferred_term_id: "4493" }]) }

    it 'processes the tokens correctly' do
      expect(query_expander).to receive(:process_unquoted_phrase_token).with(search_query).and_call_original
      query_expander.expand_query
    end

    it 'makes the expected SES queries' do
      expect(ses_test_class).to receive(:new).with(({ value: "Balancing British Airways" })).and_return(balancing_british_airways_ses_response)
      query_expander.expand_query
    end

    it 'returns the expected result' do
      # TODO: double brackets caused by Term Expander having to add some in (due to processing the complete three
      # word phrase as a single token), and then brackets being added in combine_terms too.
      expect(ses_test_class).to receive(:new).with(({ value: "Balancing British Airways" })).and_return(balancing_british_airways_ses_response)
      expect(query_expander.expand_query).to eq("(\"British Airways\" OR \"BA\" OR all_ses:4493) AND Balancing")
    end
  end

  context 'a phrase in quotes that is a thesaurus term' do
    let(:search_query) { "\"Digital mapping\"" }
    let(:digital_mapping_ses_response) { instance_double(SesQuery, data: [{ equivalent_terms: [], preferred_term: "Digital mapping", preferred_term_id: "90904" }]) }

    it 'processes the tokens correctly' do
      expect(query_expander).to receive(:process_quoted_phrase_token).with("Digital mapping").and_call_original
      query_expander.expand_query
    end

    it 'makes the expected SES queries' do
      expect(ses_test_class).to receive(:new).with(({ value: "Digital mapping" })).and_return(digital_mapping_ses_response)
      query_expander.expand_query
    end

    it 'returns the expected result' do
      expect(ses_test_class).to receive(:new).with(({ value: "Digital mapping" })).and_return(digital_mapping_ses_response)
      expect(query_expander.expand_query).to eq("\"Digital mapping\" OR all_ses:90904")
    end
  end

  context 'a phrase in quotes that is a thesaurus term, with a substring of that phrase also being a thesaurus term' do
    let(:search_query) { "\"Army training estate\"" }
    let(:army_training_estate_ses_response) { instance_double(SesQuery, data: [{ equivalent_terms: [], preferred_term: "Army Training Estate", preferred_term_id: "1832" }]) }

    it 'processes the tokens correctly' do
      expect(query_expander).to receive(:process_quoted_phrase_token).with("Army training estate").and_call_original
      query_expander.expand_query
    end

    it 'makes the expected SES queries' do
      expect(ses_test_class).to receive(:new).with(({ value: "Army training estate" })).and_return(army_training_estate_ses_response)
      query_expander.expand_query
    end

    it 'returns the expected result' do
      expect(ses_test_class).to receive(:new).with(({ value: "Army training estate" })).and_return(army_training_estate_ses_response)
      expect(query_expander.expand_query).to eq("\"Army Training Estate\" OR all_ses:1832")
    end
  end

  context 'a phrase in quotes' do
    let(:search_query) { "\"News providers\"" }
    let(:news_providers_ses_response) { instance_double(SesQuery, data: []) }

    it 'processes the tokens correctly' do
      expect(query_expander).to receive(:process_quoted_phrase_token).with("News providers").and_call_original
      query_expander.expand_query
    end

    it 'makes the expected SES queries' do
      expect(ses_test_class).to receive(:new).with(({ value: "News providers" })).and_return(news_providers_ses_response)
      query_expander.expand_query
    end

    it 'returns the expected result' do
      expect(ses_test_class).to receive(:new).with(({ value: "News providers" })).and_return(news_providers_ses_response)
      expect(query_expander.expand_query).to eq("\"News providers\"")
    end
  end

  context 'a phrase in quotes and an unquoted word' do
    let(:search_query) { "\"News providers\" restrictions" }
    let(:news_providers_ses_response) { instance_double(SesQuery, data: []) }
    let(:restrictions_ses_response) { instance_double(SesQuery, data: []) }

    it 'processes the tokens correctly' do
      expect(query_expander).to receive(:process_quoted_phrase_token).with("News providers").and_call_original
      expect(query_expander).to receive(:process_unquoted_phrase_token).with("restrictions").and_call_original
      query_expander.expand_query
    end

    it 'makes the expected SES queries' do
      expect(ses_test_class).to receive(:new).with(({ value: "News providers" })).and_return(news_providers_ses_response)
      expect(ses_test_class).to receive(:new).with(({ value: "restrictions" })).and_return(restrictions_ses_response)
      query_expander.expand_query
    end

    it 'returns the expected result' do
      expect(ses_test_class).to receive(:new).with(({ value: "News providers" })).and_return(news_providers_ses_response)
      expect(ses_test_class).to receive(:new).with(({ value: "restrictions" })).and_return(restrictions_ses_response)
      expect(query_expander.expand_query).to eq("\"News providers\" AND restrictions")
    end
  end

  context 'a phrase in quotes that is a thesaurus term and an unquoted word' do
    let(:search_query) { "\"Tax relief\" significant" }
    let(:tax_relief_ses_response) { instance_double(SesQuery, data: [{ equivalent_terms: ["Tax incentives", "Tax relief"], preferred_term: "Tax allowances", preferred_term_id: "93196" }]) }
    let(:significant_ses_response) { instance_double(SesQuery, data: []) }

    it 'processes the tokens correctly' do
      expect(query_expander).to receive(:process_quoted_phrase_token).with("Tax relief").and_call_original
      expect(query_expander).to receive(:process_unquoted_phrase_token).with("significant").and_call_original
      query_expander.expand_query
    end

    it 'makes the expected SES queries' do
      expect(ses_test_class).to receive(:new).with(({ value: "Tax relief" })).and_return(tax_relief_ses_response)
      expect(ses_test_class).to receive(:new).with(({ value: "significant" })).and_return(significant_ses_response)
      query_expander.expand_query
    end

    it 'returns the expected result' do
      expect(ses_test_class).to receive(:new).with(({ value: "Tax relief" })).and_return(tax_relief_ses_response)
      expect(ses_test_class).to receive(:new).with(({ value: "significant" })).and_return(significant_ses_response)
      expect(query_expander.expand_query).to eq("(\"Tax allowances\" OR \"Tax incentives\" OR \"Tax relief\" OR all_ses:93196) AND significant")
    end
  end

  context 'a phrase in quotes that is a thesaurus term and an unquoted word that is also a thesaurus term' do
    let(:search_query) { "\"Tax relief\" charities" }
    let(:tax_relief_ses_response) { instance_double(SesQuery, data: [{ equivalent_terms: ["Tax incentives", "Tax relief"], preferred_term: "Tax allowances", preferred_term_id: "93196" }]) }
    let(:charities_ses_response) { instance_double(SesQuery, data: [{ equivalent_terms: [], preferred_term: "Charities", preferred_term_id: "90487" }]) }

    it 'processes the tokens correctly' do
      expect(query_expander).to receive(:process_quoted_phrase_token).with("Tax relief").and_call_original
      expect(query_expander).to receive(:process_unquoted_phrase_token).with("charities").and_call_original
      query_expander.expand_query
    end

    it 'makes the expected SES queries' do
      expect(ses_test_class).to receive(:new).with(({ value: "Tax relief" })).and_return(tax_relief_ses_response)
      expect(ses_test_class).to receive(:new).with(({ value: "charities" })).and_return(charities_ses_response)
      query_expander.expand_query
    end

    it 'returns the expected result' do
      expect(ses_test_class).to receive(:new).with(({ value: "Tax relief" })).and_return(tax_relief_ses_response)
      expect(ses_test_class).to receive(:new).with(({ value: "charities" })).and_return(charities_ses_response)
      expect(query_expander.expand_query).to eq("(\"Tax allowances\" OR \"Tax incentives\" OR \"Tax relief\" OR all_ses:93196) AND (\"Charities\" OR all_ses:90487)")
    end
  end

  context 'a phrase in quotes that is a thesaurus term and an unquoted phrase that is also a thesaurus term' do
    let(:search_query) { "\"Tax relief\" small businesses" }
    let(:tax_relief_ses_response) { instance_double(SesQuery, data: [{ equivalent_terms: ["Tax incentives", "Tax relief"], preferred_term: "Tax allowances", preferred_term_id: "93196" }]) }
    let(:small_businesses_ses_response) { instance_double(SesQuery, data: [{ equivalent_terms: ["Medium sized businesses", "Medium sized enterprises", "MSEs", "Small and medium sized enterprises", "Small firms", "SMEs"], preferred_term: "Small businesses", preferred_term_id: "93034" }]) }

    it 'processes the tokens correctly' do
      expect(query_expander).to receive(:process_quoted_phrase_token).with("Tax relief").and_call_original
      expect(query_expander).to receive(:process_unquoted_phrase_token).with("small businesses").and_call_original
      query_expander.expand_query
    end

    it 'makes the expected SES queries' do
      expect(ses_test_class).to receive(:new).with(({ value: "Tax relief" })).and_return(tax_relief_ses_response)
      expect(ses_test_class).to receive(:new).with(({ value: "small businesses" })).and_return(small_businesses_ses_response)
      query_expander.expand_query
    end

    it 'returns the expected result' do
      expect(ses_test_class).to receive(:new).with(({ value: "Tax relief" })).and_return(tax_relief_ses_response)
      expect(ses_test_class).to receive(:new).with(({ value: "small businesses" })).and_return(small_businesses_ses_response)
      expect(query_expander.expand_query).to eq("(\"Tax allowances\" OR \"Tax incentives\" OR \"Tax relief\" OR all_ses:93196) AND (\"Small businesses\" OR \"Medium sized businesses\" OR \"Medium sized enterprises\" OR \"MSEs\" OR \"Small and medium sized enterprises\" OR \"Small firms\" OR \"SMEs\" OR all_ses:93034)")
    end
  end

  context 'a phrase in quotes that is a thesaurus term and another phrase in quotes that is also a thesaurus term' do
    let(:search_query) { "\"Tax relief\" \"Small businesses\"" }
    let(:small_businesses_ses_response) { instance_double(SesQuery, data: [{ equivalent_terms: ["Medium sized businesses", "Medium sized enterprises", "MSEs", "Small and medium sized enterprises", "Small firms", "SMEs"], preferred_term: "Small businesses", preferred_term_id: "93034" }]) }
    let(:tax_relief_ses_response) { instance_double(SesQuery, data: [{ equivalent_terms: ["Tax incentives", "Tax relief"], preferred_term: "Tax allowances", preferred_term_id: "93196" }]) }

    it 'processes the tokens correctly' do
      expect(query_expander).to receive(:process_quoted_phrase_token).with("Tax relief").and_call_original
      expect(query_expander).to receive(:process_quoted_phrase_token).with("Small businesses").and_call_original
      query_expander.expand_query
    end

    it 'makes the expected SES queries' do
      expect(ses_test_class).to receive(:new).with(({ value: "Tax relief" })).and_return(tax_relief_ses_response)
      expect(ses_test_class).to receive(:new).with(({ value: "Small businesses" })).and_return(small_businesses_ses_response)
      query_expander.expand_query
    end

    it 'returns the expected result' do
      expect(ses_test_class).to receive(:new).with(({ value: "Tax relief" })).and_return(tax_relief_ses_response)
      expect(ses_test_class).to receive(:new).with(({ value: "Small businesses" })).and_return(small_businesses_ses_response)
      expect(query_expander.expand_query).to eq("(\"Tax allowances\" OR \"Tax incentives\" OR \"Tax relief\" OR all_ses:93196) AND (\"Small businesses\" OR \"Medium sized businesses\" OR \"Medium sized enterprises\" OR \"MSEs\" OR \"Small and medium sized enterprises\" OR \"Small firms\" OR \"SMEs\" OR all_ses:93034)")
    end
  end

  context 'two thesaurus terms separated with an OR operator' do
    let(:search_query) { "Crime OR Fraud" }
    let(:crime_ses_response) { instance_double(SesQuery, data: [{ equivalent_terms: ["Law breaking", "Offences", "Street crime"], preferred_term: "Crime", preferred_term_id: "90768" }]) }
    let(:fraud_ses_response) { instance_double(SesQuery, data: [{ equivalent_terms: ["Embezzlement"], preferred_term: "Fraud", preferred_term_id: "91352" }]) }

    it 'processes the tokens correctly' do
      expect(query_expander).to receive(:process_unquoted_phrase_token).with("Crime").and_call_original
      expect(query_expander).to receive(:process_unquoted_phrase_token).with("Fraud").and_call_original
      query_expander.expand_query
    end

    it 'makes the expected SES queries' do
      expect(ses_test_class).to receive(:new).with(({ value: "Crime" })).and_return(crime_ses_response)
      expect(ses_test_class).to receive(:new).with(({ value: "Fraud" })).and_return(fraud_ses_response)
      query_expander.expand_query
    end

    it 'returns the expected result' do
      expect(ses_test_class).to receive(:new).with(({ value: "Crime" })).and_return(crime_ses_response)
      expect(ses_test_class).to receive(:new).with(({ value: "Fraud" })).and_return(fraud_ses_response)
      expect(query_expander.expand_query).to eq("(\"Crime\" OR \"Law breaking\" OR \"Offences\" OR \"Street crime\" OR all_ses:90768) OR (\"Fraud\" OR \"Embezzlement\" OR all_ses:91352)")
    end
  end

  context 'two thesaurus terms separated with an OR operator separated by an AND operator from a quoted phrase that is a thesaurus term' do
    let(:search_query) { "(Labour OR conservative) AND \"small businesses\"" }
    let(:labour_ses_response) { instance_double(SesQuery, data: [{ equivalent_terms: ["LAB", "Labour Party"], preferred_term: "Labour", preferred_term_id: "42226" }]) }
    let(:conservative_ses_response) { instance_double(SesQuery, data: [{ equivalent_terms: ["CON", "Conservative Party", "Conservatives", "National Union of Conservative and Unionist Associations"], preferred_term: "Conservative", preferred_term_id: "21137" }]) }
    let(:small_businesses_ses_response) { instance_double(SesQuery, data: [{ equivalent_terms: ["Medium sized businesses", "Medium sized enterprises", "MSEs", "Small and medium sized enterprises", "Small firms", "SMEs"], preferred_term: "Small businesses", preferred_term_id: "93034" }]) }

    it 'processes the tokens correctly' do
      expect(query_expander).to receive(:process_unquoted_phrase_token).with("Labour").and_call_original
      expect(query_expander).to receive(:process_unquoted_phrase_token).with("conservative").and_call_original
      expect(query_expander).to receive(:process_quoted_phrase_token).with("small businesses").and_call_original
      query_expander.expand_query
    end

    it 'makes the expected SES queries' do
      expect(ses_test_class).to receive(:new).with(({ value: "Labour" })).and_return(labour_ses_response)
      expect(ses_test_class).to receive(:new).with(({ value: "conservative" })).and_return(conservative_ses_response)
      expect(ses_test_class).to receive(:new).with(({ value: "small businesses" })).and_return(small_businesses_ses_response)
      query_expander.expand_query
    end

    it 'returns the expected result' do
      expect(ses_test_class).to receive(:new).with(({ value: "Labour" })).and_return(labour_ses_response)
      expect(ses_test_class).to receive(:new).with(({ value: "conservative" })).and_return(conservative_ses_response)
      expect(ses_test_class).to receive(:new).with(({ value: "small businesses" })).and_return(small_businesses_ses_response)
      expect(query_expander.expand_query).to eq("((\"Labour\" OR \"LAB\" OR \"Labour Party\" OR all_ses:42226) OR (\"Conservative\" OR \"CON\" OR \"Conservative Party\" OR \"Conservatives\" OR \"National Union of Conservative and Unionist Associations\" OR all_ses:21137)) AND (\"Small businesses\" OR \"Medium sized businesses\" OR \"Medium sized enterprises\" OR \"MSEs\" OR \"Small and medium sized enterprises\" OR \"Small firms\" OR \"SMEs\" OR all_ses:93034)")
    end
  end

  context 'a thesaurus term and a non-thesaurus term separated by an OR operator' do
    let(:search_query) { "Crime OR malfeasance" }
    let(:crime_ses_response) { instance_double(SesQuery, data: [{ equivalent_terms: ["Law breaking", "Offences", "Street crime"], preferred_term: "Crime", preferred_term_id: "90768" }]) }
    let(:malfeasance_ses_response) { instance_double(SesQuery, data: []) }

    it 'processes the tokens correctly' do
      expect(query_expander).to receive(:process_unquoted_phrase_token).with("Crime").and_call_original
      expect(query_expander).to receive(:process_unquoted_phrase_token).with("malfeasance").and_call_original
      query_expander.expand_query
    end

    it 'makes the expected SES queries' do
      expect(ses_test_class).to receive(:new).with(({ value: "Crime" })).and_return(crime_ses_response)
      expect(ses_test_class).to receive(:new).with(({ value: "malfeasance" })).and_return(malfeasance_ses_response)
      query_expander.expand_query
    end

    it 'returns the expected result' do
      expect(ses_test_class).to receive(:new).with(({ value: "Crime" })).and_return(crime_ses_response)
      expect(ses_test_class).to receive(:new).with(({ value: "malfeasance" })).and_return(malfeasance_ses_response)
      expect(query_expander.expand_query).to eq("(\"Crime\" OR \"Law breaking\" OR \"Offences\" OR \"Street crime\" OR all_ses:90768) OR malfeasance")
    end
  end

  context 'two thesaurus terms separated by an AND operator, OR another thesaurus term' do
    let(:search_query) { "(Judges AND juries) OR Courts" }
    let(:courts_ses_response) { instance_double(SesQuery, data: [{ equivalent_terms: [], preferred_term: "Courts", preferred_term_id: "90757" }]) }
    let(:judges_ses_response) { instance_double(SesQuery, data: [{ equivalent_terms: ["Law lords"], preferred_term: "Judges", preferred_term_id: "91760" }]) }
    let(:juries_ses_response) { instance_double(SesQuery, data: [{ equivalent_terms: ["Jury service", "Trial by jury"], preferred_term: "Juries", preferred_term_id: "91765" }]) }

    it 'processes the tokens correctly' do
      expect(query_expander).to receive(:process_unquoted_phrase_token).with("Judges").and_call_original
      expect(query_expander).to receive(:process_unquoted_phrase_token).with("juries").and_call_original
      expect(query_expander).to receive(:process_unquoted_phrase_token).with("Courts").and_call_original
      query_expander.expand_query
    end

    it 'makes the expected SES queries' do
      expect(ses_test_class).to receive(:new).with(({ value: "Courts" })).and_return(courts_ses_response)
      expect(ses_test_class).to receive(:new).with(({ value: "Judges" })).and_return(juries_ses_response)
      expect(ses_test_class).to receive(:new).with(({ value: "juries" })).and_return(juries_ses_response)
      query_expander.expand_query
    end

    it 'returns the expected result' do
      # only getting one set of brackets around first pair of terms
      expect(ses_test_class).to receive(:new).with(({ value: "Courts" })).and_return(courts_ses_response)
      expect(ses_test_class).to receive(:new).with(({ value: "Judges" })).and_return(judges_ses_response)
      expect(ses_test_class).to receive(:new).with(({ value: "juries" })).and_return(juries_ses_response)
      expect(query_expander.expand_query).to eq("((\"Judges\" OR \"Law lords\" OR all_ses:91760) AND (\"Juries\" OR \"Jury service\" OR \"Trial by jury\" OR all_ses:91765)) OR (\"Courts\" OR all_ses:90757)")
    end
  end

  context 'two non-preferred terms separated by AND, followed by a preferred term' do
    # These brackets are superfluous; Solr doesn't care whether the first two terms are wrapped in brackets because
    # the third term is (initially implicitly, eventually explicitly) combined using AND. There's no difference between
    # "One AND Two AND three" vs. "(One AND Two) AND Three".
    # So for the sake of not writing custom parser behaviour for this scenario, we're just going to pass the superfluous
    # brackets along and let Solr deal with them.

    let(:search_query) { "(Ponies AND bird flu) Defra" }
    let(:ponies_ses_response) { instance_double(SesQuery, data: [{ equivalent_terms: ["Equines", "Ponies"], preferred_term: "Horses", preferred_term_id: "10766" }]) }
    let(:bird_flu_ses_response) { instance_double(SesQuery, data: [{ equivalent_terms: ["Avian flu", "Bird flu", "Fowl plague"], preferred_term: "Avian influenza", preferred_term_id: "8483" }]) }
    let(:defra_ses_response) { instance_double(SesQuery, data: [{ equivalent_terms: ["DEFRA", "Dept for Environment Food and Rural Affairs", "Dept for Environment, Food and Rural Affairs", "Dept of Environment Food and Rural Affairs"], preferred_term: "Department for Environment, Food and Rural Affairs", preferred_term_id: "28661" }]) }

    it 'processes the tokens correctly' do
      expect(query_expander).to receive(:process_unquoted_phrase_token).with("Ponies").and_call_original
      expect(query_expander).to receive(:process_unquoted_phrase_token).with("bird flu").and_call_original
      expect(query_expander).to receive(:process_unquoted_phrase_token).with("Defra").and_call_original
      query_expander.expand_query
    end

    it 'makes the expected SES queries' do
      expect(ses_test_class).to receive(:new).with(({ value: "Ponies" })).and_return(ponies_ses_response)
      expect(ses_test_class).to receive(:new).with(({ value: "bird flu" })).and_return(bird_flu_ses_response)
      expect(ses_test_class).to receive(:new).with(({ value: "Defra" })).and_return(defra_ses_response)
      query_expander.expand_query
    end

    it 'returns the expected result' do
      expect(ses_test_class).to receive(:new).with(({ value: "Ponies" })).and_return(ponies_ses_response)
      expect(ses_test_class).to receive(:new).with(({ value: "bird flu" })).and_return(bird_flu_ses_response)
      expect(ses_test_class).to receive(:new).with(({ value: "Defra" })).and_return(defra_ses_response)
      expect(query_expander.expand_query).to eq("((\"Horses\" OR \"Equines\" OR \"Ponies\" OR all_ses:10766) AND (\"Avian influenza\" OR \"Avian flu\" OR \"Bird flu\" OR \"Fowl plague\" OR all_ses:8483)) AND (\"Department for Environment, Food and Rural Affairs\" OR \"DEFRA\" OR \"Dept for Environment Food and Rural Affairs\" OR \"Dept for Environment, Food and Rural Affairs\" OR \"Dept of Environment Food and Rural Affairs\" OR all_ses:28661)")
    end
  end
end