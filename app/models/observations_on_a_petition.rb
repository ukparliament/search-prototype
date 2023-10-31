class ObservationsOnAPetition < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/observations_on_a_petition'
  end

  def object_name
    'observations on a petition'
  end

  def member
    # unsure which field to use here
    return if content_object_data['member_ses'].blank?

    content_object_data['member_ses'].first
  end
end