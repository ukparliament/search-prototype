class DepositedPaper < Paper

  def initialize(content_type_object_data)
    super
  end

  def self.search_result_solr_fields
    # fields requested in Solr search for search results page
    super << %w[
      abstract_text
      askedToReplyAuthor_ses
      corporateAuthor_ses
      corporateAuthor_t
      dateOfCommittmentToDeposit_dt
      dateOfOrigin_dt
      dateReceived_dt
      date_dt
      department_ses
      department_t
      identifier_t
      legislationTitle_ses
      legislationTitle_t
      legislature_ses
      physicalLocationCommons_t
      physicalLocationLords_t
      searcherNote_t
      subject_ses
      subject_t
      title_t
      uri
    ]
  end

  def deposited_date
    get_first_as_date_from('dateReceived_dt')
  end

  def commitment_to_deposit_date
    get_first_as_date_from('dateOfCommittmentToDeposit_dt')
  end

  def date_originated
    get_first_as_date_from('dateOfOrigin_dt')
  end

  def deposited_file
    uris = get_all_from('depositedFile_uri')
    return if uris.blank?

    uris.map do |uri|
      full = URI.parse(uri[:value])
      URI::HTTPS.build(host: full.host, path: full.path)
    end
  end

  def authors
    # combines personal and corporate authors
    combine_fields(corporate_author, personal_author)
  end

  def personal_author
    combine_fields(get_all_from('personalAuthor_ses'), get_all_from('personalAuthor_t'))
  end

  def commons_library_location
    get_first_from('physicalLocationCommons_t')
  end

  def lords_library_location
    get_first_from('physicalLocationLords_t')
  end
end