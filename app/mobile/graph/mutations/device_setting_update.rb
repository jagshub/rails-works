# frozen_string_literal: true

module Mobile::Graph::Mutations
  class DeviceSettingUpdate < BaseMutation
    Mobile::Device::SETTINGS.each do |setting|
      argument setting, Boolean, required: false
    end

    returns Mobile::Graph::Types::DeviceType

    require_current_user

    def perform(inputs)
      mobile_device = Mobile::Device.device_for(user: current_user, request: context[:request])

      return if mobile_device.nil?

      mobile_device.update!(inputs)
      mobile_device
    end
  end
end
