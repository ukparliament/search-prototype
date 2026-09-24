##
# Class for retrieving SES data from cache (preferred) or SES API (fallback)
# Accepts SES IDs (array of ints) and optionally existing data (array of hashes)
# Where provided, the existing_ses_data is merged with data retrieved from either source and returned
class SesData

  attr_reader :ses_ids, :existing_ses_data, :ses_cache

  def initialize(ses_ids, existing_ses_data = [])
    @ses_cache = SesCache.new(Rails.cache)
    @existing_ses_data = existing_ses_data
    @ses_ids = ses_ids
  end

  def combined_ses_data
    return {} if ses_ids.blank?

    ids_to_fetch = []
    cached_data = {}
    fetched_data = {}

    if Rails.env.test?
      # skip cache retrieval in test env
      ids_to_fetch = ses_ids.uniq.sort
    else
      # create two sets of IDs: those in cache & those we need to lookup
      ses_ids.uniq.sort.each do |ses_id|
        # attempt to retrieve from cache
        retrieved_value = ses_cache.read_cached_value(ses_id)
        retrieved_scope_note = ses_cache.read_cached_value("#{ses_id}_scope_note")

        if retrieved_value.present?
          # populate cached_data hash if values were retrieved
          cached_data[ses_id] = retrieved_value
          cached_data["#{ses_id}_scope_note"] = retrieved_scope_note
        else
          # otherwise put in fetch from API
          ids_to_fetch << ses_id
        end
      end
    end

    # go to SES API for IDs we don't have cached
    puts "#{ids_to_fetch.count} SES terms need to be fetched from SES" if Rails.env.development?
    unless ids_to_fetch.empty?
      fetched_data = SesLookup.new([{ value: ids_to_fetch }]).data
    end

    # if we fetched new data, write it to the cache
    fetched_data.each { |k, v| ses_cache.write_cached_value(k, v) } unless fetched_data.empty?

    # combine cached and fetched data
    combined_data = cached_data.merge(fetched_data)

    if existing_ses_data.blank?
      # where no existing data was provided, return cached + new data
      combined_data
    else
      # where existing data was provided, merge it with cached + new data
      # otherwise return the existing data as is
      combined_data.blank? ? existing_ses_data : existing_ses_data.merge(combined_data)
    end
  end
end