xml.instruct! :xml, :version => "1.0", encoding: "utf-8"

xml.rss version: "2.0" do
  xml.channel do
    xml.title "Search Results"
    xml.link search_url
    xml.description "Search Results for..."
    xml.lastBuildDate Time.current.rfc2822

    @objects.each do |object|
      xml.item do
        xml.title format_object_title(object.object_title, @ses_data)
        xml.link object.object_uri.dig(:value)
        xml.date object.standard_date.dig(:value)
        xml.description strip_tags(render(partial: object.prelim_template, locals: { object: object })).squish
      end
    end
  end
end