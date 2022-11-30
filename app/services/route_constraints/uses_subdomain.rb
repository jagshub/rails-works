# frozen_string_literal: true

module RouteConstraints
  class UsesSubdomain
    def initialize(subdomain)
      @subdomain = subdomain
    end

    def matches?(request)
      # allow any connections in test, staging and dev
      return true unless Rails.env.production?

      # NOTE(vesln): so we can allow any connection to the local API
      return true if ENV['DISABLE_SUBDOMAIN_CONSTRAINT']

      # allow if connection via correct subdomain
      request.host == "#{ @subdomain }.producthunt.com" || request.host == 'localhost'
    end
  end
end
