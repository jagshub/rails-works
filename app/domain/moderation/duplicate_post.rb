# frozen_string_literal: true

module Moderation::DuplicatePost
  extend self

  def pending_request?(post, user)
    ::Moderation::DuplicatePostRequest
      .exists?(
        post: post,
        user: user,
        approved_at: nil,
      )
  end

  def create_request(post:, user:, url:, reason:)
    ::Moderation::DuplicatePostRequest
      .create!(
        post: post,
        user: user,
        url: url,
        reason: reason,
      )
  end

  def approve_request(request, admin)
    request.post.update!(
      accepted_duplicate: true,
    )
    request.approve!
    ModerationLog.create!(
      reference: request,
      message: ModerationLog::APPROVED_DUP_POST,
      moderator: admin,
    )

    return if request.user.email.blank?

    ModerationMailer
      .accepted_duplicate_post_request(
        user: request.user,
        post: request.post,
        url: request.url,
      )
      .deliver_later
  end

  def reject_request(request, admin)
    request.destroy!
    ModerationLog.create!(
      reference: request.post,
      message: ModerationLog::REJECTED_DUP_POST,
      moderator: admin,
      reason: "Rejected duplicate post request from user ##{ request.user_id }",
    )

    return if request.user.email.blank?

    ModerationMailer
      .rejected_duplicate_post_request(
        user: request.user,
        post: request.post,
      )
      .deliver_later
  end
end
