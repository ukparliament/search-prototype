xml.instruct! :xml, :version => "1.0", encoding: "utf-8"

xml.rss :version => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/", "xmlns:atom" => "http://www.w3.org/2005/Atom" do
  xml.channel do
    xml.title "Search Results for #{@search_data.query}"
    xml.description "Results from Parliamentary Search for the query: #{@search_data.query}"
    xml.link search_url(query: @search_data.query, filter: @search_data.filter, results_per_page: @search_data.results_per_page)
	xml.tag!('atom:link', :href => search_url(query: @search_data.query, filter: @search_data.filter, results_per_page: @search_data.results_per_page, :format => 'rss'), :rel => 'self', :type => "application/rss+xml")
	xml.copyright "https://www.parliament.uk/site-information/copyright-parliament/open-parliament-licence/"
    xml.language "en-gb"
    xml.pubDate @objects.first.standard_date&.dig(:value)&.rfc2822

    @objects.each do |object|
      xml.item do
        xml.guid object.object_uri&.dig(:value)
        xml.title format_object_title(object.object_title, @ses_data)
        xml.link object.external_location_uri&.dig(:value)
        xml.pubDate object.standard_date&.dig(:value)&.rfc2822
        xml.description strip_tags(render(partial: object.prelim_template, locals: { object: object })).squish
		xml.tag!('dc:identifier', object.standard_reference&.reject{|ref| ref.dig(:value) == "."}&.pluck(:value)&.join('; ') )
      end
    end
  end
end