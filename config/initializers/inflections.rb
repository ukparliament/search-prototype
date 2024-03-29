# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:
ActiveSupport::Inflector.inflections(:en) do |inflect|
  #   inflect.plural /^(ox)$/i, "\\1en"
  #   inflect.singular /^(ox)en/i, "\\1"
  inflect.irregular "debate on bills", "debates on bills"
  inflect.irregular "oral answer to question", "oral answers to questions"
  inflect.irregular "memorandum", "memoranda"
  inflect.irregular "observations on a petition", "observations on petitions"
  inflect.uncountable ["European material produced by EU institutions"]
  inflect.uncountable ["Observations on petitions"]
  inflect.uncountable ["ObservationsOnPetitions"]
end

# These inflection rules are supported but not enabled by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.acronym "RESTful"
# end
