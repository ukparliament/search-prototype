module ApplicationHelper
  # ## We set the date display format.
  DATE_DISPLAY_FORMAT = '%A, %e %B %Y'

  def boolean_yes_no(boolean)
    # outputs 'Yes' or 'No' strings from a boolean
    return true if boolean == 1

    false
  end
end