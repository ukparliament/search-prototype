require 'rails_helper'

RSpec.describe SesLookup, type: :model do
  describe 'lookup_ids' do
    context 'with no data' do
      let!(:ses_api_call) { SesLookup.new(nil) }
      it 'returns nil' do
        expect(ses_api_call.lookup_ids).to be_nil
      end
    end
    context 'with data' do
      context 'with a single ID' do
        let!(:ses_api_call) { SesLookup.new([{ value: 92347, field_name: 'type_ses' }]) }
        it 'returns a flat array of ids' do
          expect(ses_api_call.lookup_ids).to eq([92347])
        end
      end
      context 'with multiple IDs, but fewer than the group size setting' do
        let!(:ses_api_call) { SesLookup.new([{ value: 92347, field_name: 'type_ses' }, { value: 92350, field_name: 'type_ses' }]) }
        it 'returns a flat array of ids' do
          expect(ses_api_call.lookup_ids).to eq([92347, 92350])
        end
      end
    end
  end

  describe 'lookup_id_groups' do
    context 'with no data' do
      let!(:ses_api_call) { SesLookup.new(nil) }
      it 'returns nil' do
        expect(ses_api_call.lookup_id_groups).to be_nil
      end
    end
    context 'with data' do
      context 'with a single ID' do
        let!(:ses_api_call) { SesLookup.new([{ value: 92347, field_name: 'type_ses' }]) }
        it 'returns an array containing a single ID as a string' do
          expect(ses_api_call.lookup_id_groups).to eq(["92347"])
        end
      end
      context 'with multiple IDs, but fewer than the group size setting' do
        let!(:ses_api_call) { SesLookup.new([{ value: 92347, field_name: 'type_ses' }, { value: 92350, field_name: 'type_ses' }]) }
        it 'returns an array containing both IDs as a comma separated string' do
          expect(ses_api_call.lookup_id_groups).to eq(["92347,92350"])
        end
      end
      context 'with more IDs than the group size setting' do
        let!(:ses_api_call) { SesLookup.new([{ value: 92347, field_name: 'type_ses' }, { value: 92350, field_name: 'type_ses' }, { value: 92352, field_name: 'type_ses' }]) }
        it 'returns an array containing multiple strings, comma separated where a string contains multiple IDs' do
          # set group size to 2 so that we don't need 251 IDs in the test example
          allow(ses_api_call).to receive(:group_size).and_return(2)
          expect(ses_api_call.lookup_id_groups).to eq(["92347,92350", "92352"])
        end
      end
    end
  end

  describe 'data' do
    context 'with a single SES ID' do
      let!(:ses_api_call) { SesLookup.new([{ value: 92347, field_name: 'type_ses' }]) }
      let!(:mock_response) { [{ "term" => { "name" => "Parliamentary papers", "id" => "92347", "zid" => "OMII2245II1064353150RYcb2zqBNrbQXC4PTCNd", "class" => "CTP", "freq" => "0", "facets" => [{ "id" => "346696", "name" => "Content type" }], "attributes" => { "CBT term" => "1", "Guide to procedure term" => "1", "SIT" => "1" }, "metadata" => {}, "src" => "1", "rank" => "0", "percentage" => "20", "weight" => "9.48056", "index" => "disp_taxonomy", "displayName" => "Parliamentary papers", "foundByNPT" => "0", "lastUpdatedDate" => "20221216192052", "createdDate" => "20100514065405", "creator" => "admin", "updator" => "morrelln", "status" => "Approved", "documents" => "0", "hierarchy" => [{ "typeId" => "1", "qty" => "1", "name" => "Broader Term", "abbr" => "BT", "fields" => [{ "field" => { "name" => "Content type", "id" => "346696", "zid" => "649359721", "class" => "CTP", "freq" => "0", "facets" => [{ "id" => "346696", "name" => "Content type" }] } }] }, { "typeId" => "1", "qty" => "16", "name" => "Narrower Term", "abbr" => "NT", "fields" => [{ "field" => { "name" => "Annual reports", "id" => "90218", "zid" => "OMII116IIN6780345861G1lnNu5h0iZzBHFkEB8", "class" => "CTP", "freq" => "0", "facets" => [{ "id" => "346696", "name" => "Content type" }] } }, { "field" => { "name" => "Command papers", "id" => "90587", "zid" => "OMII485IIN739625494ZNj0bShw6AzbC1yVUxOC", "class" => "CTP", "freq" => "0", "facets" => [{ "id" => "346696", "name" => "Content type" }] } }, { "field" => { "name" => "Consultation papers", "id" => "90696", "zid" => "OMII594II6922802751UVQgMgbjuDNdx3i8elh", "class" => "CTP", "freq" => "0", "facets" => [{ "id" => "346696", "name" => "Content type" }] } }, { "field" => { "name" => "Consultation papers (Government responses)", "id" => "363905", "zid" => "544084876", "class" => "CTP", "freq" => "0", "facets" => [{ "id" => "346696", "name" => "Content type" }] } }, { "field" => { "name" => "Deposited papers", "id" => "347163", "zid" => "1208135670", "class" => "CTP", "freq" => "0", "facets" => [{ "id" => "346696", "name" => "Content type" }] } }, { "field" => { "name" => "Government responses to e-petitions", "id" => "420550", "zid" => "131584149925018701938146", "class" => "CTP", "freq" => "0", "facets" => [{ "id" => "346696", "name" => "Content type" }] } }, { "field" => { "name" => "House of Commons papers", "id" => "91561", "zid" => "OMII1459IIN1809925603vB1WWTIZvSZXZDVRbOu9", "class" => "CTP", "freq" => "0", "facets" => [{ "id" => "346696", "name" => "Content type" }] } }, { "field" => { "name" => "House of Lords journals", "id" => "509616", "zid" => "92645631878638436825351", "class" => "CTP", "freq" => "0", "facets" => [{ "id" => "346696", "name" => "Content type" }] } }, { "field" => { "name" => "House of Lords papers", "id" => "91563", "zid" => "OMII1461IIN7273579233AEJ0qUg2L4uod3GGeqJ", "class" => "CTP", "freq" => "0", "facets" => [{ "id" => "346696", "name" => "Content type" }] } }, { "field" => { "name" => "Impact assessments", "id" => "91613", "zid" => "OMII1511II1866252005z8zBciDoSAEiHz3CNWiZ", "class" => "CTP", "freq" => "0", "facets" => [{ "id" => "346696", "name" => "Content type" }] } }, { "field" => { "name" => "Proposed negative statutory instruments", "id" => "445763", "zid" => "197045718506832053031784", "class" => "CTP", "freq" => "0", "facets" => [{ "id" => "346696", "name" => "Content type" }] } }, { "field" => { "name" => "Transport and Works Act order applications", "id" => "360977", "zid" => "1226834893", "class" => "CTP", "freq" => "0", "facets" => [{ "id" => "346696", "name" => "Content type" }] } }, { "field" => { "name" => "Treaties", "id" => "93339", "zid" => "OMII3237II708086385mJsbxJ8t8ipca6aHABpz", "class" => "CTP", "freq" => "0", "facets" => [{ "id" => "346696", "name" => "Content type" }] } }, { "field" => { "name" => "Unprinted command papers", "id" => "352261", "zid" => "1423002001", "class" => "CTP", "freq" => "0", "facets" => [{ "id" => "346696", "name" => "Content type" }] } }, { "field" => { "name" => "Unprinted papers", "id" => "51288", "zid" => "OMII6236II1024302078x69coSTeufWFre3Mn9ZF", "class" => "CTP", "freq" => "0", "facets" => [{ "id" => "346696", "name" => "Content type" }] } }, { "field" => { "name" => "White papers", "id" => "93495", "zid" => "OMII3393IIN1590902964rt63Q4JNeuHJyNTBP3sG", "class" => "CTP", "freq" => "0", "facets" => [{ "id" => "346696", "name" => "Content type" }] } }] }], "equivalence" => [{ "typeId" => "3", "qty" => "3", "name" => "Use For", "abbr" => "UF", "fields" => [{ "field" => { "name" => "Laid papers", "id" => "50283", "zid" => "OMII5231IIN1115864112z74bTA9cBdsW3mYRUB7H", "freq" => "0" } }, { "field" => { "name" => "Parliamentary paper", "id" => "399190", "zid" => "1467552608", "freq" => "0" } }, { "field" => { "name" => "Parlt papers", "id" => "50634", "zid" => "OMII5582II1016795834gYX9sPcmKtympo2499ZQ", "freq" => "0" } }] }], "paths" => [{ "path" => [{ "field" => { "name" => "Content type", "id" => "346696", "zid" => "649359721", "class" => "CTP", "freq" => "0", "facets" => [{ "id" => "346696", "name" => "Content type" }] } }, { "field" => { "name" => "Parliamentary papers", "id" => "92347", "zid" => "OMII2245II1064353150RYcb2zqBNrbQXC4PTCNd", "class" => "CTP", "freq" => "0", "facets" => [{ "id" => "346696", "name" => "Content type" }] } }] }] } }] }

      it 'returns a hash with the name keyed to the SES ID' do
        allow(ses_api_call).to receive(:evaluated_responses).and_return(mock_response)
        expect(ses_api_call.input_data).to eq([{ :field_name => "type_ses", :value => 92347 }])
        expect(ses_api_call.data).to eq({ 92347 => 'Parliamentary papers' })
      end
    end

    context 'with multiple SES IDs' do
      let!(:ses_api_call) { SesLookup.new([{ value: 83446, field_name: 'type_ses' }, { value: 62077, field_name: 'type_ses' }]) }
      let!(:mock_response) { [{ "term" => { "name" => "Joint Committee on Statutory Instruments", "id" => "83446", "zid" => "OMII1266588972II469347704JGnd2GcweYcLocl2vAHw", "class" => "ORG", "freq" => "0", "facets" => [{ "id" => "1", "name" => "Organisations" }], "attributes" => { "CBT term" => "1", "ORG" => "1" }, "metadata" => {}, "src" => "1", "rank" => "0", "percentage" => "10", "weight" => "9.67831", "index" => "disp_taxonomy", "displayName" => "Joint Committee on Statutory Instruments", "foundByNPT" => "0", "lastUpdatedDate" => "20210724141656", "createdDate" => "20100514065325", "creator" => "admin", "updator" => "morrelln", "status" => "Approved", "documents" => "0", "hierarchy" => [{ "typeId" => "1", "qty" => "1", "name" => "Broader Term", "abbr" => "BT", "fields" => [{ "field" => { "name" => "Names of joint select committees", "id" => "486017", "zid" => "205010350710320678010247", "class" => "ORG", "freq" => "0", "facets" => [{ "id" => "1", "name" => "Organisations" }] } }] }], "equivalence" => [{ "typeId" => "3", "qty" => "4", "name" => "Use For", "abbr" => "UF", "fields" => [{ "field" => { "name" => "JCSI", "id" => "485147", "zid" => "57068287948224769582796", "freq" => "0" } }, { "field" => { "name" => "Joint Select Committee on Statutory Instruments", "id" => "486042", "zid" => "109896748872380234966555", "freq" => "0" } }, { "field" => { "name" => "Statutory Instruments Joint Committee", "id" => "98344", "zid" => "OMII1266588973II1038698807OAZRuQNzI7xB4sAs6gDH", "freq" => "0" } }, { "field" => { "name" => "Statutory Instruments Joint Select Committee", "id" => "402284", "zid" => "1003475113", "freq" => "0" } }] }], "paths" => [{ "path" => [{ "field" => { "name" => "Organisations", "id" => "1", "zid" => "OMII0II1738968428", "class" => "ORG", "freq" => "0", "facets" => [{ "id" => "1", "name" => "Organisations" }] } }, { "field" => { "name" => "Names of select committees", "id" => "354669", "zid" => "1264284723", "class" => "ORG", "freq" => "0", "facets" => [{ "id" => "1", "name" => "Organisations" }] } }, { "field" => { "name" => "Names of joint select committees", "id" => "486017", "zid" => "205010350710320678010247", "class" => "ORG", "freq" => "0", "facets" => [{ "id" => "1", "name" => "Organisations" }] } }, { "field" => { "name" => "Joint Committee on Statutory Instruments", "id" => "83446", "zid" => "OMII1266588972II469347704JGnd2GcweYcLocl2vAHw", "class" => "ORG", "freq" => "0", "facets" => [{ "id" => "1", "name" => "Organisations" }] } }] }] } }, { "term" => { "name" => "Procedure Committee (HL)", "id" => "62077", "zid" => "OMIIN1038580740II13216519246qIqxXtt0FxhlpX8VKzo", "class" => "ORG", "freq" => "0", "facets" => [{ "id" => "1", "name" => "Organisations" }], "attributes" => { "ORG" => "1" }, "metadata" => { "Scope note" => "Renamed as Procedure and Privileges Committee in March 2020." }, "src" => "1", "rank" => "1", "percentage" => "11", "weight" => "10.3754", "index" => "disp_taxonomy", "displayName" => "Procedure Committee (HL)", "foundByNPT" => "0", "lastUpdatedDate" => "20210729155702", "createdDate" => "20100514064305", "creator" => "admin", "updator" => "morrelln", "status" => "Approved", "documents" => "0", "hierarchy" => [{ "typeId" => "1", "qty" => "1", "name" => "Broader Term", "abbr" => "BT", "fields" => [{ "field" => { "name" => "Names of Lords select committees", "id" => "486018", "zid" => "85864922305743573725954", "class" => "ORG", "freq" => "0", "facets" => [{ "id" => "1", "name" => "Organisations" }] } }] }, { "typeId" => "1", "qty" => "1", "name" => "Narrower Term", "abbr" => "NT", "fields" => [{ "field" => { "name" => "Leave of Absence Sub-committee", "id" => "346548", "zid" => "1179972563", "class" => "ORG", "freq" => "0", "facets" => [{ "id" => "1", "name" => "Organisations" }] } }] }], "associated" => [{ "typeId" => "2", "qty" => "1", "name" => "Related To", "abbr" => "RT", "fields" => [{ "field" => { "name" => "Procedure and Privileges Committee", "id" => "468200", "zid" => "170725081408504885506675", "class" => "ORG", "freq" => "0", "facets" => [{ "id" => "1", "name" => "Organisations" }] } }] }], "equivalence" => [{ "typeId" => "3", "qty" => "4", "name" => "Use For", "abbr" => "UF", "fields" => [{ "field" => { "name" => "Procedure Select Committee", "id" => "98862", "zid" => "OMIIN1038580751IIN393675089IRnYsOsXePCVSVaRgBz8", "freq" => "0" } }, { "field" => { "name" => "Procedure Select Committee (HL)", "id" => "98863", "zid" => "OMIIN1038580749IIN1279894271ZC0pz2ysMsQ9v4UW6phl", "freq" => "0" } }, { "field" => { "name" => "Select Committee on Procedure of the House", "id" => "486540", "zid" => "182146760785304326747935", "freq" => "0" } }, { "field" => { "name" => "Select Committee on Procedure of the House (HL)", "id" => "408313", "zid" => "147841643875067292784659", "freq" => "0" } }] }], "paths" => [{ "path" => [{ "field" => { "name" => "Organisations", "id" => "1", "zid" => "OMII0II1738968428", "class" => "ORG", "freq" => "0", "facets" => [{ "id" => "1", "name" => "Organisations" }] } }, { "field" => { "name" => "Names of select committees", "id" => "354669", "zid" => "1264284723", "class" => "ORG", "freq" => "0", "facets" => [{ "id" => "1", "name" => "Organisations" }] } }, { "field" => { "name" => "Names of Lords select committees", "id" => "486018", "zid" => "85864922305743573725954", "class" => "ORG", "freq" => "0", "facets" => [{ "id" => "1", "name" => "Organisations" }] } }, { "field" => { "name" => "Procedure Committee (HL)", "id" => "62077", "zid" => "OMIIN1038580740II13216519246qIqxXtt0FxhlpX8VKzo", "class" => "ORG", "freq" => "0", "facets" => [{ "id" => "1", "name" => "Organisations" }] } }] }] } }] }

      it 'returns a hash with multiple names keyed to their respective SES IDs' do
        allow(ses_api_call).to receive(:evaluated_responses).and_return(mock_response)
        expect(ses_api_call.data).to eq({ 83446 => "Joint Committee on Statutory Instruments", 62077 => "Procedure Committee (HL)" })
      end
    end
  end

  describe 'ruby_uri' do
    let!(:ses_api_call) { SesLookup.new([{ value: 12345, field_name: 'type_ses' }]) }
    let!(:mock_response) { "test" }

    it 'returns a ruby uri with the base prepended' do
      allow(ses_api_call).to receive(:evaluated_responses).and_return(mock_response)
      expect(ses_api_call.ruby_uri('test')).to be_a(URI)
      expect(ses_api_call.ruby_uri('test').to_s).to eq('https://api.parliament.uk/ses/select.exe?TBDB=disp_taxonomy&TEMPLATE=service.json&expand_hierarchy=1&SERVICE=term&ID=test')
    end
  end

  describe 'evaluated_responses' do
    let!(:ses_api_call) { SesLookup.new([{ value: 92347, field_name: 'type_ses' }, { value: 92350, field_name: 'type_ses' }, { value: 92352, field_name: 'type_ses' }]) }
    let!(:deserialised_response) { { "1" => "a", "2" => "b" } }
    let!(:serialised_response) { "{\"terms\":{\"1\":\"a\",\"2\":\"b\"}}" }

    it 'parses the response' do
      # artificially reduce the threshold for grouping
      allow(ses_api_call).to receive(:group_size).and_return(2)

      allow(ses_api_call).to receive(:api_response).and_return(serialised_response)
      expect(ses_api_call.send(:evaluated_responses)).to eq([deserialised_response, deserialised_response])
    end
  end
end
