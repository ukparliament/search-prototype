class ResearchBriefing < ContentObject

  def initialize(content_object_data)
    super
  end

  def self.required_solr_fields
    %w[title_t subtype_ses type_ses uri abstract_t memberPrinted_t department_ses department_t procedure_t dateLaid_dt date_dt dateWithdrawn_dt dateMade_dt dateApproved_dt comingIntoForceNotes_t comingIntoForce_dt legislationTitle_ses legislationTitle_t subject_ses subject_t searcherNote_t lordsLibraryLocation_t commonsLibraryLocation_t identifier_t legislature_ses]
  end

  def template
    'search/objects/research_briefing'
  end

  def search_result_partial
    'search/results/research_briefing'
  end

  def self.search_result_solr_fields
    # fields requested in Solr search for search results page
    %w[
    title_t uri
    htmlsummary_t
    description_t
    creator_ses creator_t
    category_ses
    type_ses subtype_ses
    legislationTitle_ses legislationTitle_t
    subject_ses subject_t
    topic_ses
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

  def last_updated
    get_first_as_date_from('modified_dt')
  end
end