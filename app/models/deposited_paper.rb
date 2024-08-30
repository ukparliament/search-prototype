class DepositedPaper < Paper

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/deposited_paper'
  end

  def search_result_partial
    'search/results/deposited_paper'
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
    combine_fields(personal_author, corporate_author)
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