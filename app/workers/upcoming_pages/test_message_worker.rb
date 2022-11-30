# frozen_string_literal: true

module UpcomingPages
  class TestMessageWorker < ApplicationJob
    include ActiveJobHandleDeserializationError
    include ActiveJobHandleNetworkErrors
    include ActiveJobHandleMailjetErrors

    queue_as :upcoming_page_messages

    def perform(upcoming_page_message)
      user = upcoming_page_message.user

      return if user.blank?

      UpcomingPageMessageMailer.status_update(
        upcoming_page_message: upcoming_page_message,
        to: user.email,
        token: 'test',
        test: true,
        body: UpcomingPages::MessageBodyToHtml.call(upcoming_page_message, subscriber: OpenStruct.new(user: user)),
      ).deliver_now
    end
  end
end
