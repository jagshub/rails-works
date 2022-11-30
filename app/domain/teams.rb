# frozen_string_literal: true

module Teams
  extend self

  def policy
    Teams::Policy
  end

  ## Requests

  def request_create(user:, product:, team_email: nil, additional_info: nil)
    Teams::Requests::Create.call(user: user, product: product, team_email: team_email, additional_info: additional_info)
  end

  def request_approve(request:, approval_type:, status_changed_by: nil, role: nil)
    Teams::Requests::Approve.call(request: request, approval_type: approval_type, status_changed_by: status_changed_by, role: role)
  end

  def request_reject(request:, status_changed_by:)
    Teams::Requests::Reject.call(request: request, status_changed_by: status_changed_by)
  end

  def request_auto_approve?(request:)
    Teams::Requests::Verification.auto_approve?(request: request)
  end

  def request_email_verified?(request:)
    Teams::Requests::Verification.email_verified?(request: request)
  end

  def request_send_email_verification(request:)
    Teams::Requests::Verification.send_email_verification(request: request)
  end

  def request_verify_by_token(token:, user:)
    Teams::Requests::Verification.confirm_email token: token, user: user
  end

  ## Invites

  def invite_create(product:, user:, referrer:)
    Teams::Invites.create(product: product, user: user, referrer: referrer)
  end

  def invite_accept(invite:)
    Teams::Invites.accept(invite: invite)
  end

  def invite_reject(invite:)
    Teams::Invites.reject(invite: invite)
  end
end
