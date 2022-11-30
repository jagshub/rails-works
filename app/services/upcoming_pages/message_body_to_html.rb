# frozen_string_literal: true

module UpcomingPages::MessageBodyToHtml
  extend self

  def call(message, subscriber:)
    Sanitizers::DbToEmail.call(message.body_html, context: { user: subscriber&.user })
  end
end
