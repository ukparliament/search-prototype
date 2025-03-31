class AssociatedObjectsForObjectView < AssociatedObjects

  def initialize(objects)
    @objects = objects
  end

  def solr_fields
    %w[
      uri
      type_ses
      subtype_ses
      title_t
      identifier_t
      reference_t
      member_ses
      contributionText_t
      correctionText_t
      dateOfOrderToPrint_dt
      askingMember_ses
      askingMemberParty_ses
      correctingItem_uri
      correctingItem_t
      correctedWmsMc_b
      correctingMember_ses
      correctingMemberParty_ses
      department_ses
      askedToReplyAuthor_ses
      date_dt
      questionText_t
      answerText_t
      legislature_ses
    ]
  end
end