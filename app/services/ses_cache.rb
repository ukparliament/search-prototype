##
# Class to manage caching of SES data
class SesCache
  attr_reader :cache_store

  def initialize(cache_store)
    @cache_store = cache_store
  end

  def read_cached_value(ses_id)
    cache_store.read(cache_key(ses_id))
  end

  def write_cached_value(ses_id, value)
    cache_store.write(cache_key(ses_id), value, expires_in: 2.hours)
  end

  private

  def cache_key(ses_id)
    "ses_data_#{ses_id}"
  end
end