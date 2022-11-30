# frozen_string_literal: true

module Teams::Requests::Reject
  extend self

  def call(request:, status_changed_by:)
    update_request(request, status_changed_by)
    send_email(request)

    request
  end

  private

  def update_request(request, status_changed_by)
    request.update!(
      status: :rejected,
      status_changed_at: Time.current,
      status_changed_by: status_changed_by,
    )
  end

  def send_email(request)
    TeamMailer.request_rejected(request).deliver_later
  end
end
