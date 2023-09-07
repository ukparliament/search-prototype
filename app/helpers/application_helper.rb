module ApplicationHelper
  # ## We set the date display format.
  DATE_DISPLAY_FORMAT = '%A, %e %B %Y'

  def boolean_yes_no(boolean)
    # outputs 'Yes' or 'No' strings from a boolean (an instance of Ruby TrueClass or FalseClass)
    # for presenting output of methods such as WrittenQuestion transferred?
    return 'Yes' if boolean == true

    'No'
  end
end