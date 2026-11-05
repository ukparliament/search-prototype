# frozen_string_literal: true

class SolrQuery::Lookup < SolrQuery

  attr_reader :uris, :solr_fields

  def initialize(uris: [], solr_fields: [], api_client: ApiClient::Post, api_error_handler: ApiErrorHandler)
    super(api_client: api_client, api_error_handler: api_error_handler)
    @uris = uris
    @solr_fields = solr_fields
  end

  def data
    return if uris.blank?

    threads = uris.each_slice(500).map do |slice|
      Thread.new do
        puts "Begin thread" if Rails.env.development?

        request = api_client.new(uri: build_uri,
                                 params: build_search_params(uri_group: slice, field_list: solr_fields),
                                 headers: request_headers)

        api_error_handler.new(response: request.response).handle_errors
      end
    end

    response = threads.flat_map(&:value)

    process_response(response)
  end

  private

  def process_response(response)
    response.flat_map { |part| part.dig('response', 'docs') }.map do |object_data|
      ContentTypeObject.generate(object_data)
    end
  end

  def uri_query_string(uri_group)
    # query = uri_group.join(" || uri:")
    # "uri:#{query}"
    #
    # should switch to filter query for this?
    "{!terms f=uri}#{uri_group.join(",")}"
  end

  def build_search_params(uri_group: uri_group, field_list: field_list)
    ret = search_params

    ret[:fq] = uri_query_string(uri_group)
    ret[:fl] = field_list

    ret
  end

  def search_params
    {
      'q.op': 'OR',
      rows: 500
    }
  end
end
