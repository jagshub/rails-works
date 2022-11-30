# frozen_string_literal: true

module API::V2Internal::Mutations
  class NotificationTokenCreate < BaseMutation
    argument :token, String, required: false

    returns API::V2Internal::Types::ViewerType

    def perform
      node = Subscribers.register(user: current_user, mobile_push_token: inputs[:token])
      node.user
    rescue Subscribers::Register::DuplicatedSubscriberError
      current_user
    end
  end
end
