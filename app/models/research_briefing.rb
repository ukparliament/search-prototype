class ResearchBriefing < ContentTypeObject

  def initialize(content_type_object_data)
    super
  end

  def template
    'content_type_objects/object_pages/research_briefing'
  end

  def search_result_partial
    'search/results/research_briefing'
  end

  def self.search_result_solr_fields
    # fields requested in Solr search for search results page
    super << %w[
    title_t uri
    htmlsummary_t
    description_t
    creator_ses creator_t
    category_ses
    type_ses subtype_ses
    legislationTitle_ses legislationTitle_t
    subject_ses subject_t
    topic_ses
    searcherNote_t
    date_dt identifier_t legislature_ses
    ]
  end

  def html_summary
    get_first_as_html_from('htmlsummary_t')
  end

  def main_content
    fallback(html_summary, description)
  end

  def object_name
    subtype
  end

  def creators
    combine_fields(get_all_from('creator_ses'), get_all_from('creator_t'))
  end

  def contributors
    combine_fields(get_all_from('contributor_ses'), get_all_from('contributor_t'))
  end

  def creators_and_contributors
    combine_fields(creators, contributors)
  end

  def series
    get_first_from('category_ses')
  end

  def category
    get_first_from('category_ses')
  end

  def creator_party
    get_first_from('creatorParty_ses')
  end

  def is_published
    get_first_as_boolean_from('published_b')
  end

  def published_by
    get_first_from('publisher_ses')
  end

  def section
    get_first_from('section_ses')
  end

  def sections
    get_all_from('section_ses')
  end

  def last_updated
    get_first_as_date_from('modified_dt')
  end
end