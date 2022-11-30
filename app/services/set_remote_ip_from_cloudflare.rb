# frozen_string_literal: true

class SetRemoteIpFromCloudflare
  ENV_CF_CLIENT_IP = 'HTTP_CF_CONNECTING_IP'
  ENV_REMOTE_ADDR = 'REMOTE_ADDR'
  ENV_CLIENT_IP = 'HTTP_CLIENT_IP'
  ENV_X_FORWARDED_FOR = 'HTTP_X_FORWARDED_FOR'

  def initialize(app)
    @app = app
  end

  def call(env)
    context(env)
  end

  def context(env, app = @app)
    if env[ENV_CF_CLIENT_IP].present?
      # Note (Lukas Fittl): Since we have the actual client IP from Cloudflare
      #   we act as if that one requested directly, and clear all other proxy
      #   headers that presumably include the client IP.
      #
      #   The second step is necessary to avoid IP spoofing exceptions.
      env[ENV_REMOTE_ADDR] = env[ENV_CF_CLIENT_IP]
      env.delete(ENV_X_FORWARDED_FOR)
      env.delete(ENV_CLIENT_IP)
    end

    app.call(env)
  end
end
