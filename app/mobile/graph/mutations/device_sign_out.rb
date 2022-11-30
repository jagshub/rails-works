# frozen_string_literal: true

module Mobile::Graph::Mutations
  class DeviceSignOut < BaseMutation
    returns Mobile::Graph::Types::DeviceType

    require_current_user
    def perform
      mobile_device = Mobile::Device.device_for(user: current_user, request: context[:request])

      return if mobile_device.nil?

      mobile_device.update!(
        push_notification_token: nil,
        sign_out_at: Time.current,
      )
      mobile_device
    end
  end
end
