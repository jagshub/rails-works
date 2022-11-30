# frozen_string_literal: true

class OAuthApps::RecordLastRequest < ApplicationJob
  include ActiveJobHandleDeserializationError
  include ActiveJobHandleNetworkErrors

  def perform(request_at, application_id, user_id = nil)
    application = OAuth::Application.find_by(id: application_id)
    return unless application.present? && request_at.present?

    request_at = Time.zone.parse(request_at)
    user = User.find_by(id: user_id)
    request = application.requests.for_user(user).first || application.requests.without_user.first
    return OAuth::Request.create!(application: application, user: user, last_request_at: request_at) if request.blank?

    seconds_elapsed_since_last_request = (request_at - request.last_request_at).to_i
    # NOTE(dhruvparmar372): Using a 60s window here to have cheap throttling
    # of update operations due to OAuth app requests.
    request.update!(last_request_at: request_at) if seconds_elapsed_since_last_request >= 60
  end
end
