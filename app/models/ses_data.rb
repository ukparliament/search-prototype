class SesData

  attr_reader :hierarchy_ses_data, :ses_ids, :cache_store

  def initialize(hierarchy_ses_data, ses_ids)
    @cache_store = Rails.cache
    @hierarchy_ses_data = hierarchy_ses_data
    @ses_ids = ses_ids
  end

  def combined_ses_data

    ids_in_cache = []
    ids_to_fetch = []

    # create two sets of IDs: those in cache & those we need to lookup
    ses_ids.uniq.sort.each do |ses_id|
      if cache_store.exist?(cache_key(ses_id))
        ids_in_cache << ses_id
      else
        ids_to_fetch << ses_id
      end
    end

    cached_data = {}
    fetched_data = {}

    # go to SES API for IDs we don't have cached
    puts "#{ids_to_fetch.count} SES terms need to be fetched from SES"
    unless ids_to_fetch.empty?
      fetched_data = SesLookup.new([{ value: ids_to_fetch }]).data
    end

    # if we fetched new data, write it to the cache
    fetched_data.each { |k, v| cache_store.write(cache_key(k), v) } unless fetched_data.empty?

    # get cached data for ids left in initial_ids
    puts "#{ids_in_cache.count} SES terms found in cache"
    unless ids_in_cache.blank?
      ids_in_cache.each { |ses_id| cached_data[ses_id] = cache_store.read(cache_key(ses_id)) }
    end

    # combine cached and fetched data
    combined_data = cached_data.merge(fetched_data)

    return hierarchy_ses_data if combined_data.blank?
    hierarchy_ses_data.merge(combined_data)
  end

  def cache_key(id)
    "ses_data_#{id}"
  end
end