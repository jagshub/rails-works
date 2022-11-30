# frozen_string_literal: true

module Graph::Mutations
  class SubscriptionDestroy < BaseMutation
    argument_record :subject, Subscription::SUBJECTS, required: true

    returns Graph::Types::SubscribableInterfaceType

    require_current_user

    def perform(subject:)
      ::Subscribe.unsubscribe(subject, current_user)

      subject.reload
    end
  end
end
