module Middleware
  class RequestProfiler
    def initialize(app)
      @app = app
      @enabled = ENV["REQUEST_PROFILER"] == "true"
    end

    def call(env)
      return @app.call(env) unless @enabled

      started = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      status, headers, body = @app.call(env)

      request = ActionDispatch::Request.new(env)

      duration =
        ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started) * 1000).round(1)

      Rails.logger.info(
        "[REQUEST_PROFILER] #{{
          ip: request.remote_ip,
          cf_ip: request.headers["CF-Connecting-IP"],
          forwarded_for: request.headers["X-Forwarded-For"],
          referer: request.referer,
          accept: request.headers["Accept"],
          accept_language: request.headers["Accept-Language"],
          method: request.request_method,
          path: request.path,
          full_path: request.fullpath,
          status: status,
          duration_ms: duration,
          user_agent: request.user_agent
        }.to_json}"
      )

      [status, headers, body]
    end
  end
end