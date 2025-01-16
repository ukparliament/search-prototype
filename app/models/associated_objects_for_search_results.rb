class AssociatedObjectsForSearchResults < AssociatedObjects

  def initialize(objects)
    @objects = objects
  end

  def solr_fields
    %w[uri type_ses questionText_t answerText_t askingMember_ses askingMemberParty_ses]
  end
end