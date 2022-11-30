# frozen_string_literal: true

module Graph::Mutations
  class UpcomingPageConfirmSubscription < BaseMutation
    argument :token, String, required: false
    argument :slug, String, required: false

    returns Graph::Types::UpcomingPageSubscriberType

    def perform(slug:, token:)
      upcoming_page = UpcomingPage.friendly.find(slug)

      Ships::Contacts::ConfirmSubscriber.call subscription_target: upcoming_page, token: token
    end
  end
end
