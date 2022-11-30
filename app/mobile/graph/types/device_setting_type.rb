# frozen_string_literal: true

module Mobile::Graph::Types
  class DeviceSettingType < BaseObject
    field :name, String, null: false
    field :is_enabled, Boolean, null: false
  end
end
