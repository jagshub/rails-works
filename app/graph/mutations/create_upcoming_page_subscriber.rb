# frozen_string_literal: true

module Graph::Mutations
  class CreateUpcomingPageSubscriber < BaseMutation
    argument :email, String, required: false
    argument_record :upcoming_page, UpcomingPage, required: true
    argument :source_kind, String, required: false
    argument :source_reference_id, String, required: false

    returns Graph::Types::UpcomingPageSubscriberType

    def perform(email: nil, upcoming_page:, source_kind: nil, source_reference_id: nil)
      Ships::Contacts::CreateSubscriber.from_subscription(
        subscription_target: upcoming_page,
        user: current_user,
        email: email,
        source_kind: source_kind,
        source_reference_id: source_reference_id,
        os: request_info[:os],
        device_type: request_info[:device_type],
        ip_address: request_info[:request_ip],
        user_agent: request_info[:user_agent],
      )
    end
  end
end
