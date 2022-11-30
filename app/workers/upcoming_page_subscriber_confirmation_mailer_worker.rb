# frozen_string_literal: true

class UpcomingPageSubscriberConfirmationMailerWorker < ApplicationJob
  include ActiveJobHandleDeserializationError
  include ActiveJobHandleNetworkErrors
  include ActiveJobHandleMailjetErrors

  queue_as :mailers

  def perform(subscriber)
    UpcomingPageSubscriberConfirmationMailer.confirm_email(subscriber).deliver_now
  end
end
