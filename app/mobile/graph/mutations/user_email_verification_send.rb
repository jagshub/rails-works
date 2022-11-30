# frozen_string_literal: true

module Mobile::Graph::Mutations
  class UserEmailVerificationSend < BaseMutation
    require_current_user

    def perform
      return if current_user.subscriber.blank?

      Subscribers.send_verification_email(
        subscriber: current_user.subscriber,
        skip_email_link_tracking: true,
      )

      nil
    end
  end
end
