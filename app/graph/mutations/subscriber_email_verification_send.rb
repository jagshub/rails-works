# frozen_string_literal: true

module Graph::Mutations
  class SubscriberEmailVerificationSend < BaseMutation
    require_current_user

    def perform
      Subscribers.send_verification_email subscriber: current_user.subscriber

      nil
    end
  end
end
