# frozen_string_literal: true

module Graph::Mutations
  class SubscriptionMute < BaseMutation
    argument_record :subject, Subscription::SUBJECTS, required: true

    returns Graph::Types::SubscribableInterfaceType

    require_current_user

    def perform(subject:)
      ::Subscribe.mute(subject, current_user)

      subject.reload
    end
  end
end
