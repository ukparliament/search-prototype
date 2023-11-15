module ApplicationHelper
  # ## We set the date display format.
  DATE_DISPLAY_FORMAT = '%A, %e %B %Y'

  def boolean_yes_no(boolean)
    # outputs 'Yes' or 'No' strings from a boolean (an instance of Ruby TrueClass or FalseClass)
    # for presenting output of methods such as WrittenQuestion transferred?
    # Note that in most cases the partial will not be rendered except where the answer is 'Yes', but exceptions exist
    return 'Yes' if boolean == true

    'No'
  end
end