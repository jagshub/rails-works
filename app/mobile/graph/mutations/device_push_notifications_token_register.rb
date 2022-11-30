# frozen_string_literal: true

module Mobile::Graph::Mutations
  class DevicePushNotificationsTokenRegister < BaseMutation
    argument :token, String, required: true
    argument :one_signal_player_id, String, required: true

    returns Mobile::Graph::Types::DeviceType

    require_current_user

    def perform(token:, one_signal_player_id:)
      mobile_device = Mobile::Device.device_for(user: current_user, request: context[:request])

      return if mobile_device.nil?

      mobile_device.update!(
        push_notification_token: token,
        one_signal_player_id: one_signal_player_id,
      )
      mobile_device
    end
  end
end
