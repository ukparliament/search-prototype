require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Search
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Require and enable request profiling custom middleware
    require Rails.root.join("lib/middleware/request_profiler")
    config.middleware.use Middleware::RequestProfiler

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    #
    config.assets.enabled = true

    # Don't generate system test files.
    config.generators.system_tests = nil

    ## Assign error codes to custom errors
    # Error with a user's query
    config.action_dispatch.rescue_responses["MissingParameterError"] = :bad_request # Tried to load an object page but no ID was provided

    # Error during the process of instantiating a ContentTypeObject
    config.action_dispatch.rescue_responses["ObjectNotFoundError"] = :not_found # Tried to load an object page but Solr found nothing
    config.action_dispatch.rescue_responses["ObjectNotSupportedError"] = :not_found # Tried to load an object page but the object type is NotSupported
    config.action_dispatch.rescue_responses["ExternalServiceUnauthorizedError"] = :forbidden # Authorization error with Solr or SES

  end
end
