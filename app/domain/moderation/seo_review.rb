# frozen_string_literal: true

module Moderation::SeoReview
  extend self

  def call(by:, reference:, message: ModerationLog::SEO_MODERATED_MESSAGE)
    attachment = Moderation::Notifier::Attachment.new(
      author: by,
      reference: reference,
      message: message,
    )
    attachment.log
    attachment
  end
end
