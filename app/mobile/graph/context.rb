# frozen_string_literal: true

class Mobile::Graph::Context < GraphQL::Query::Context
  def current_user
    self[:current_user]
  end

  def current_user_id
    self[:current_user]&.id
  end

  def visitor_id
    self[:visitor_id]
  end

  def track_code
    # TODO(naman): make part of the session token probably
    nil
  end

  def session
    self[:session]
  end

  def request
    self[:request]
  end

  def request_info
    @request_info ||= RequestInfo.new(self[:request])
  end

  def impersonated?
    self[:impersonated]
  end
end
