# frozen_string_literal: true

module Sharing::Text::UpcomingPageMessage
  extend self

  MAX_NAME_LENGTH = 90

  def call(upcoming_page_message)
    Twitter::Message
      .new
      .add_mandatory("#{ upcoming_page_message.subject.truncate(MAX_NAME_LENGTH) } 👉")
      .add_mandatory(Routes.upcoming_page_message_url(upcoming_page_message))
      .to_s
  end
end
