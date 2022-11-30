# frozen_string_literal: true

module Graph::Mutations
  class NotificationSubscriptionDestroy < BaseMutation
    argument :email, String, required: false
    argument :friend_id, ID, required: false
    argument :identifier, String, required: false
    argument :kind, String, required: false
    argument :ph_notification_id, ID, required: false
    argument :subscription_id, ID, required: false
    argument :product_request_id, ID, required: false
    argument :token, String, required: false
    argument :user_id, ID, required: false
    argument :valid_until, String, required: false

    field :status, String, null: false
    field :message, String, null: true

    def perform(inputs)
      Notifications::UnsubscribeWithToken.call(params: inputs)
    end
  end
end
