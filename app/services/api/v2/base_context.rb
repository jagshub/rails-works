# frozen_string_literal: true

module API::V2
  class BaseContext < GraphQL::Query::Context
    def current_user
      self[:current_user]
    end

    def current_application
      self[:current_application]
    end

    def allowed_scopes
      self[:allowed_scopes]
    end

    def request_info
      @request_info ||= RequestInfo.new(self[:request]).to_hash
    end

    def url_tracking_params
      @url_tracking_params ||= Metrics.url_tracking_params(medium: :api, object: current_application)
    end

    def private_scope_allowed?
      @private_scope_allowed ||= allowed_scopes.include? 'private'
    end

    def write_scope_allowed?
      @write_scope_allowed ||= allowed_scopes.include?('write') && current_application.present? && !current_application.legacy? && current_application.write_access_allowed?
    end
  end
end
