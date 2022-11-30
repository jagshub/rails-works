# frozen_string_literal: true

module Graph::Mutations
  class AddUpcomingPageSubscriber < BaseMutation
    argument :email, String, required: false
    argument_record :upcoming_page, UpcomingPage, authorize: :edit

    returns Graph::Types::UpcomingPageSubscriberType

    def perform(email:, upcoming_page:)
      Ships::Contacts::CreateSubscriber.from_import(
        subscription_target: upcoming_page,
        email: email,
      )
    end
  end
end
