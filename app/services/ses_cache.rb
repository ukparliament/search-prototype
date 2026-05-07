class SesCache

  attr_reader :cache_store

  def initialize(cache_store)
    @cache_store = cache_store
  end

  def exists_in_cache?(ses_id)
    puts "Looking for #{cache_key(ses_id)} in cache..." if Rails.env.development?
    if cache_store.exist?(cache_key(ses_id))
      puts "...found"
      true
    else
      puts "... not found"
      false
    end
  end

  def read_cached_value(ses_id)
    cache_store.read(cache_key(ses_id))
  end

  def write_cached_value(ses_id, value)
    puts "Writing #{cache_key(ses_id)} to cache" if Rails.env.development?
    cache_store.write(cache_key(ses_id), value)
  end

  private

  def cache_key(ses_id)
    "ses_data_#{ses_id}"
  end

end