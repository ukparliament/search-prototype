class DepositedPaper < Paper

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/deposited_paper'
  end

  def deposited_date
    # uncertain this is the correct field

    get_first_as_date_from('dateReceived_dt')
  end

  def commitment_to_deposit_date
    get_first_as_date_from('dateOfCommittmentToDeposit_dt')
  end

  def date_originated
    get_first_as_date_from('dateOfOrigin_dt')
  end

  def deposited_file
    get_all_from('depositedFile_uri')
  end

  def personal_author
    # unsure of course for this field, possibly creator_ses?
    # return if content_object_data['personalAuthor_t'].blank?

    # content_object_data['personalAuthor_t']
    nil
  end
end