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

    # Get initial SES query string for comparison against responses
    query_string = responses.dig("parameters", "query").downcase
    puts "Query for for SES response comparison: #{query_string}" if Rails.env.development?
    processed_query_array = QueryStringProcessor.new(query_string.downcase).sequential_combinations

    # For writing SES output from a search to a test fixture - leave this commented out unless you want
    # to add a new test fixture!
    # output_file = File.new("spec/fixtures/#{query_string.parameterize.underscore}.json", 'w')
    # output_file.write(responses.to_json)
    # output_file.close

    # if no match found, we won't get a key for terms at all
    if responses.has_key?("terms")
      # iterate through returned terms
      responses.dig("terms").each do |term|
        # create hash for the term data
        term_hash = { equivalent_terms: [] }

        # Disabled in favour of MATCH: 'exact' for the time being
        # terms sourced "1" are exact matches, "2" include stemming, "3" are other matches
        # filter to type 1 for now, optionally can configure this in
        # the future to controllable by power users at query time?
        # next unless term.dig("term", "src") == "1"

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

        matches_preferred_term = false
        matches_equivalent_term = false

        ## -- SES Term Filtering -- ##
        # Prototype code
        # Compares an array containing all possible variations of the search query to the term from SES & its
        # synonyms. Where there's a match, the relevant boolean is updated to reflect this, and the returned
        # term will be included in the expansion. Where there is no match it will be skipped. In order to prevent
        # multiple terms matching, matches are removed from the search query array as they are found. Processing
        # is in the order of the query array, which is by decreasing complexity via the proxy of total string length.

        # check if the preferred term for this result is in the array
        if processed_query_array.include?("#{term_hash[:preferred_term].downcase}")
          matches_preferred_term = true

          # delete the match from the array
          processed_query_array.delete(term_hash[:preferred_term].downcase)

          # generate and delete all sub terms for the match from the array too
          sub_terms = QueryStringProcessor.new(term_hash[:preferred_term]).sequential_combinations
          sub_terms.each do |sub_term|
            processed_query_array.delete(sub_term.downcase)
          end
        else
          puts "#{term_hash[:preferred_term].downcase} is not a match" if Rails.env.development?
        end

        # iterate through all equivalent terms for the result, and check if any are in the array
        term_hash[:equivalent_terms].each do |equivalent_term|
          if processed_query_array.include?("#{equivalent_term.downcase}")
            matches_equivalent_term = true

            # delete the match from the array
            processed_query_array.delete(equivalent_term.downcase)

            # generate and delete all sub terms for the match from the array too
            sub_terms = QueryStringProcessor.new(equivalent_term).sequential_combinations
            sub_terms.each do |sub_term|
              processed_query_array.delete(sub_term.downcase)
            end
          else
            puts "#{equivalent_term.downcase} is not a match" if Rails.env.development?
          end
        end

        # Don't include this SES result for use expanding the query if there are no matches
        unless matches_preferred_term || matches_equivalent_term
          puts "Excluding #{term_hash} from returned terms" if Rails.env.development?
          next
        end

        puts "Adding #{term_hash} to returned terms" if Rails.env.development?
        # add term hash to array
        returned_terms << term_hash

        puts "Processed query array is now: #{processed_query_array}" if Rails.env.development?
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
    URI::HTTPS.build(
      host: Rails.application.credentials.dig(Rails.env.to_sym, :api_host),
      path: Rails.application.credentials.dig(Rails.env.to_sym, :ses_api, :path),
      query: URI.encode_www_form(TBDB: 'disp_taxonomy',
                                 TEMPLATE: 'service.json',
                                 SERVICE: 'conceptmap',
                                 MATCH: 'exact',
                                 QUERY: term)
    )
  end

  def term
    return if input_data.blank?

    input_data[:value]
  end
end