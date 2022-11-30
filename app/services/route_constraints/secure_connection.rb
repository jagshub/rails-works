# frozen_string_literal: true

module RouteConstraints
  class SecureConnection
    class << self
      def matches?(request)
        # allow any connections in test, staging and dev
        return true unless Rails.env.production?

        # allow if ssl connection
        request.ssl?
      end
    end
  end
end
