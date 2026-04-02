Rails.application.config.after_initialize do
  next if Rails.env.test?

  credentials = Rails.application.credentials

  missing = []
  missing << :api_host unless credentials.dig(Rails.env.to_sym, :api_host).present?
  missing << :api_subscription_key unless credentials.dig(Rails.env.to_sym, :api_subscription_key).present?
  missing << :ses_api unless credentials.dig(Rails.env.to_sym, :ses_api, :path).present?
  missing << :solr_api unless credentials.dig(Rails.env.to_sym, :solr_api, :path).present?

  if missing.any?
    raise <<~ERROR
      Missing required credentials: #{missing.join(', ')}

      Make sure you have the correct master.key or environment variables set.
      See config/credentials.yml.enc
    ERROR
  end
end