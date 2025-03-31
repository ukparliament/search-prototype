# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'SesQuery' do

  describe 'data' do
    let!(:housing_response) { { "parameters" => { "tbdb" => "disp_taxonomy", "expand_hierarchy" => "0", "query" => "housing", "service" => "search", "template" => "service.json" }, "terms" => [{ "term" => { "name" => "Housing", "id" => "91569", "zid" => "OMII1467II410059274DCl0ghsu8BGIWJIbTipn", "class" => "SIT", "freq" => "0", "facets" => [{ "id" => "90102", "name" => "Concept" }], "attributes" => { "SIT" => "1", "Subject specialist term" => "1", "TPG" => "1" }, "metadata" => { "Wikidata ID" => "Q1247867" }, "src" => "1", "rank" => "1", "percentage" => "49", "weight" => "10.6053", "index" => "disp_taxonomy", "displayName" => "Housing", "foundByNPT" => "0", "lastUpdatedDate" => "20250205103658", "createdDate" => "20100514065405", "creator" => "admin", "updator" => "morrelln", "status" => "Approved", "documents" => "0", "hierarchy" => [{ "typeId" => "1", "qty" => "1", "name" => "Broader Term", "abbr" => "BT" }, { "typeId" => "1", "qty" => "22", "name" => "Narrower Term", "abbr" => "NT" }], "associated" => [{ "typeId" => "2", "qty" => "4", "name" => "Related To", "abbr" => "RT", "fields" => [{ "field" => { "name" => "Buildings", "id" => "90394", "zid" => "OMII292IIN1816955742v9BR1vJQA3kl6ZBycl8p", "class" => "SIT", "freq" => "0", "facets" => [{ "id" => "90102", "name" => "Concept" }] } }, { "field" => { "name" => "Compulsory purchase", "id" => "90659", "zid" => "OMII557IIN777484029rlSg0e040XPsLPWjr3H4", "class" => "SIT", "freq" => "0", "facets" => [{ "id" => "90102", "name" => "Concept" }] } }, { "field" => { "name" => "Households", "id" => "91566", "zid" => "OMII1464IIN1980337008aP5PiMVud4UsTi5e3yy1", "class" => "SIT", "freq" => "0", "facets" => [{ "id" => "90102", "name" => "Concept" }] } }, { "field" => { "name" => "Housing benefit", "id" => "91571", "zid" => "OMII1469IIN1139237736RgX2oAXWk8CnJ65iWgP", "class" => "SIT", "freq" => "0", "facets" => [{ "id" => "90102", "name" => "Concept" }] } }] }], "equivalence" => [{ "typeId" => "3", "qty" => "2", "name" => "Use For", "abbr" => "UF", "fields" => [{ "field" => { "name" => "Accommodation", "id" => "49157", "zid" => "OMII4106II2032139965BephDfOFFOM3tNn8B2WR", "freq" => "0" } }, { "field" => { "name" => "Houses", "id" => "91567", "zid" => "OMII1465II4498967536cMN8fDTjIDqrrrwsyFd", "freq" => "0" } }] }], "paths" => [{ "path" => [{ "field" => { "name" => "Concept", "id" => "90102", "zid" => "OMII0II1963192093", "class" => "SIT", "freq" => "0", "facets" => [{ "id" => "90102", "name" => "Concept" }] } }, { "field" => { "name" => "Housing and planning", "id" => "351449", "zid" => "976770819", "class" => "SIT", "freq" => "0", "facets" => [{ "id" => "90102", "name" => "Concept" }] } }, { "field" => { "name" => "Housing", "id" => "91569", "zid" => "OMII1467II410059274DCl0ghsu8BGIWJIbTipn", "class" => "SIT", "freq" => "0", "facets" => [{ "id" => "90102", "name" => "Concept" }] } }] }] } }, { "term" => { "name" => "Housing", "id" => "95629", "zid" => "OMIIN374695665II410059274qKWucoz5vHS4miNNDFbE", "class" => "TPG", "freq" => "0", "facets" => [{ "id" => "95475", "name" => "Taxonomy" }], "attributes" => { "Do not use for concept mapping" => "1" }, "metadata" => {}, "src" => "1", "rank" => "2", "percentage" => "49", "weight" => "10.6175", "index" => "disp_taxonomy", "displayName" => "Housing", "foundByNPT" => "0", "lastUpdatedDate" => "20250202164215", "createdDate" => "20100514065421", "creator" => "admin", "updator" => "morrelln", "status" => "Approved", "documents" => "0", "hierarchy" => [{ "typeId" => "1", "qty" => "1", "name" => "Broader Term", "abbr" => "BT" }, { "typeId" => "1", "qty" => "10", "name" => "Narrower Term", "abbr" => "NT" }], "equivalence" => [{ "typeId" => "3", "qty" => "1", "name" => "Use For", "abbr" => "UF", "fields" => [{ "field" => { "name" => "Squatting", "id" => "51631", "zid" => "OMII1621104769IIN1531896557KKORKs3GuOrVUsXkFD6h", "freq" => "0" } }] }], "paths" => [{ "path" => [{ "field" => { "name" => "Taxonomy", "id" => "95475", "zid" => "OMII0II1490289559", "class" => "TPG", "freq" => "0", "facets" => [{ "id" => "95475", "name" => "Taxonomy" }] } }, { "field" => { "name" => "Housing and planning", "id" => "95631", "zid" => "OMII627204670IIN97677081976hC980H0X00jODdRwxn", "class" => "TPG", "freq" => "0", "facets" => [{ "id" => "95475", "name" => "Taxonomy" }] } }, { "field" => { "name" => "Housing", "id" => "95629", "zid" => "OMIIN374695665II410059274qKWucoz5vHS4miNNDFbE", "class" => "TPG", "freq" => "0", "facets" => [{ "id" => "95475", "name" => "Taxonomy" }] } }] }] } }] } }

    context 'where input data is nil' do
      let!(:input_data) { nil }
      it 'returns nil' do
        allow_any_instance_of(SesLookup).to receive(:api_response).and_return(housing_response)
        expect(SesQuery.new(input_data).data).to be_nil
      end
    end

    context 'where a term is submitted' do
      let!(:input_data) { { value: 'housing' } }
      it 'returns a hash containing equivalent terms, perferred term, preferred term ID and topic ID' do
        allow_any_instance_of(SesLookup).to receive(:api_response).and_return(housing_response)
        expect(SesQuery.new(input_data).data.keys).to eq([:equivalent_terms, :preferred_term_id, :preferred_term, :topic_id])
        expect(SesQuery.new(input_data).data[:equivalent_terms]).to eq([["Accommodation", "Houses"]])
        expect(SesQuery.new(input_data).data[:preferred_term]).to eq("Housing")
        expect(SesQuery.new(input_data).data[:preferred_term_id]).to eq("91569")
        expect(SesQuery.new(input_data).data[:topic_id]).to eq("95629")
      end
    end
  end
end
