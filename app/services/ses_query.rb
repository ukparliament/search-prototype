class SesQuery < SesLookup

  def term
    # format term to lookup
    return if input_data.blank?

    input_data[:value]
  end

  def evaluated_response
    api_response(ses_term_lookup_uri, false)
  end

  ##
  # Returns hash of query expansion data assembled from SES query response.
  #
  # A single term can return no, one or many terms from SES:
  # Where no terms are found, this method returns { equivalent_terms: [] }
  #
  # Where terms are found, the hash will be in the form:
  # {
  #   equivalent_terms: ['equivalent_term_1', 'equivalent_term_2', '...'],
  #   topic_id: '12345',
  #   preferred_term_id: '23456',
  #   preferred_term: 'preferred_term'
  # }
  #
  # Terms with the 'TPG' (topic) class are not included in equivalent terms, but a separate :topic_id is
  # included in the returned hash.
  #
  # For terms which do not have the 'TPG' class, all name values under 'equivalence' are extracted into
  # the equivalent_terms array. The preferred term name and SES ID are assigned :preferred_term_id and
  # :preferred_term respectively.
  def data
    return if input_data.blank?

    ret = { equivalent_terms: [] }
    responses = evaluated_response

    return responses if responses.has_key?("error")

    terms = responses.dig('terms')
    unless terms&.compact.blank?
      equivalent_terms = []
      terms.each do |term|
        if term.dig('term', 'class') == 'TPG'
          ret[:topic_id] = term['term']['id']
        else
          equivalent_terms << term.dig('term', 'equivalence')&.first&.dig('fields')&.map { |f| f.dig('field', 'name') }
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