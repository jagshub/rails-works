# frozen_string_literal: true

module Moderation::PostActions
  extend self

  def trash(by:, post:, reason:)
    log by: by, post: post, reason: reason, message: 'Trashed post', color: :red do
      post.trash
    end
  end

  def change_multiplier(by:, post:, multiplier:)
    return if multiplier.blank?
    return if post.score_multiplier == Float(multiplier)

    log by: by, post: post, message: "Changed the rank multiplier from #{ post.score_multiplier } to #{ multiplier }", color: :green do
      post.update! score_multiplier: multiplier
    end
  end

  def change_locked(by:, post:, locked:)
    return if post.locked == locked

    log by: by, post: post, message: "Changed the locked value from #{ post.locked } to #{ locked }", color: :green do
      post.update! locked: locked
    end
  end

  def review_post(by:, post:)
    log by: by, post: post, message: ModerationLog::REVIEWED_MESSAGE
  end

  private

  def log(by:, post:, reason: nil, message:, color: nil, &block)
    block.call if block_given?
    attachment = Moderation::Notifier.for_post(author: by, post: post, message: message, reason: reason, color: color)
    attachment.log
    attachment.notify
  end
end
