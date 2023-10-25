class DepositedPaper < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/deposited_paper'
  end

  def object_name
    'deposited paper'
  end

  def deposited_date
    # uncertain this is the correct field

    return if content_object_data['dateReceived_dt'].blank?

    valid_date_string = validate_date(content_object_data['dateReceived_dt'].first)
    return unless valid_date_string

    valid_date_string.to_date
  end

  def commitment_to_deposit_date
    return if content_object_data['dateOfCommittmentToDeposit_dt'].blank?

    valid_date_string = validate_date(content_object_data['dateOfCommittmentToDeposit_dt'].first)
    return unless valid_date_string

    valid_date_string.to_date
  end

  def date_originated
    return if content_object_data['dateOfOrigin_dt'].blank?

    valid_date_string = validate_date(content_object_data['dateOfOrigin_dt'].first)
    return unless valid_date_string

    valid_date_string.to_date
  end

  def deposited_file
    return if content_object_data['depositedFile_uri'].blank?

    content_object_data['depositedFile_uri']
  end

  def corporate_author
    return if content_object_data['corporateAuthor_ses'].blank?

    content_object_data['corporateAuthor_ses'].first
  end

  def personal_author
    # unsure of course for this field, possibly creator_ses?
    # return if content_object_data['personalAuthor_t'].blank?

    # content_object_data['personalAuthor_t']
    nil
  end
end