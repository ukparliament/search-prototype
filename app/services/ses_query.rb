class SesQuery < SesLookup

  ##
  # Returns query expansion data from SES as an array, which may contain one or more terms in the form of a hash:
  # {
  #   equivalent_terms: ['equivalent term 1', 'equivalent term 2', '...'],
  #   topic_id: '12345',
  #   preferred_term_id: '23456',
  #   preferred_term: 'preferred term'
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

    # create an array to collect terms
    returned_terms = []

    # get parsed response
    responses = evaluated_response

    # if the API returns an error, it will have an "error" key at the top level
    return responses if responses.has_key?("error")

    # if no match found, we won't get a key for terms at all
    if responses.has_key?("terms")
      # iterate through returned terms
      responses.dig("terms").each do |term|
        # create hash for the term data
        term_hash = { equivalent_terms: [] }

        # terms sourced "1" are exact matches, "2" include stemming, "3" are other matches
        # filter to type 1 for now, optionally can configure this in
        # the future to controllable by power users at query time?
        next unless term.dig("term", "src") == "1"

        # where the class is a topic, return the topic ID
        term_hash[:topic_id] = term.dig("term", "id") if term.dig("term", "class") == "TPG"

        # fetch preferred term name and ID
        # SES responds with the preferred term regardless of whether the search matched preferred or non-preferred term
        term_hash[:preferred_term] = term.dig("term", "name")
        term_hash[:preferred_term_id] = term.dig("term", "id")

        # equivalent terms might not be present
        if term.dig("term").has_key?("equivalence")
          term_hash[:equivalent_terms] = term.dig("term", "equivalence").select { |ec| ec["typeId"] == "3" }.dig(0, "fields").map { |f| f.dig("field", "name") }
        end

        # add term hash to array
        returned_terms << term_hash
      end
    else
      puts "No SES terms found for: #{responses.dig("parameters", "query")}" if Rails.env.development?
    end

    # return the collated data of all terms matching the query
    returned_terms
  end

  private

  def evaluated_response
    api_response(ses_search_uri, false)
  end

  def ses_search_uri
    base_url = ses_base_url
    base_url = 'https://api.parliament.uk/ses/' if Rails.env.test?
    build_uri("#{base_url}ses?TBDB=disp_taxonomy&TEMPLATE=service.json&SERVICE=conceptmap&QUERY=#{term}")
  end

  def term
    # format term to lookup
    return if input_data.blank?

    input_data[:value]
  end
end