class SesLookup < ApiCall
  attr_reader :lookup_ids

  BASE_API_URI = "https://api.parliament.uk/ses/"

  def initialize(ses_ids)
    @lookup_ids = ses_ids
  end

  def lookup_string
    lookup_ids.uniq.compact.flatten.join(',')
  end

  def data
    # for returning all data in a structured format for further querying
    return unless lookup_ids.any?

    ret = {}
    evaluated_response['terms'].each do |term|
      ret[term['term']['id'].to_i] = term['term']['name']
    end
    ret
  end

  def ruby_uri
    build_uri("#{BASE_API_URI}select.exe?TBDB=disp_taxonomy&TEMPLATE=service.json&SERVICE=term&ID=#{lookup_string}")
  end
end