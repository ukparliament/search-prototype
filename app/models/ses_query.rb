class SesQuery < SesLookup

  def term
    # format term to lookup
    return if input_data.blank?

    input_data[:value]
  end

  def evaluated_response
    api_response(ses_term_lookup_uri, false)
  end

  def data
    # for returning all data in a structured format for further querying
    return if input_data.blank?

    ret = { equivalent_terms: [] }
    responses = evaluated_response
    return responses if responses.has_key?("error")

    # we can get multiple terms back from a single string (different SES IDs for the same string)
    terms = responses.dig('terms')
    unless terms&.compact.blank?
      # first attempt at some logic to extract correct equivalent terms & IDs
      equivalent_terms = []
      terms.each do |term|
        if term.dig('term', 'class') == 'TPG'
          # don't fetch equivalent terms for TPG (topic)
          # fetching topic ID for now even though it's not being used?
          ret[:topic_id] = term['term']['id']
        else
          # retrive all 'equivalent' (synonym) terms
          equivalent_terms << term.dig('term', 'equivalence')&.first&.dig('fields')&.map { |f| f.dig('field', 'name') }
          # retrive the SES ID of the base term
          ret[:preferred_term_id] = term['term']['id']
          ret[:preferred_term] = term['term']['name']
        end
      end
      ret[:equivalent_terms] = equivalent_terms
    end

    ret
  end

  def ses_term_lookup_uri
    base_url = ses_base_url
    build_uri("#{base_url}ses?TBDB=disp_taxonomy&TEMPLATE=service.json&expand_hierarchy=0&SERVICE=search&QUERY=#{term}")
  end
end