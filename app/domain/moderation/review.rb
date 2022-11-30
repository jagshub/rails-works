# frozen_string_literal: true

module Moderation::Review
  extend self

  def call(by:, reference:, message: ModerationLog::REVIEWED_MESSAGE)
    attachment = Moderation::Notifier::Attachment.new(
      author: by,
      reference: reference,
      message: message,
    )
    attachment.log
    attachment
  end
end
