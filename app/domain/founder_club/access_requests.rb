# frozen_string_literal: true

module FounderClub::AccessRequests
  extend self

  def add_referral(email:, invited_by:)
    access_request = FounderClub::AccessRequest.with_email(email).first || FounderClub::AccessRequest.new(email: email)

    return :already_added if access_request.referral?

    already_delivered = access_request.received_code_at.present?

    access_request.received_code_at ||= Time.current
    access_request.update!(
      user: User.find_by_email(email),
      invited_by_user: invited_by,
      source: :referral,
    )

    FounderClubMailer.access_request_invite_code(access_request).deliver_later unless already_delivered

    access_request
  end

  def remove_referral(email:, invited_by:)
    access_request = FounderClub::AccessRequest.referral.where(invited_by_user: invited_by).with_email(email).first

    return :not_found if access_request.blank?
    return :already_claimed if access_request.used_code_at.present?

    access_request.destroy!
  end

  def referral?(email:)
    FounderClub::AccessRequest.referral.with_email(email).exists?
  end

  def accept_referral_code(code)
    access_request = FounderClub::AccessRequest.find_by(invite_code: code)

    return :invalid if access_request.nil?
    return 'already used' if access_request.subscribed_at?
    return :expired if access_request.expire_at&.past?

    access_request.update! used_code_at: Time.current

    :success
  end
end
