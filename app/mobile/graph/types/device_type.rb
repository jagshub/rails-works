# frozen_string_literal: true

module Mobile::Graph::Types
  class DeviceType < BaseObject
    graphql_name 'Device'

    field :id, ID, null: false
    field :user_id, Integer, null: false
    field :os, String, null: true
    field :os_version, String, null: true
    field :app_version, String, null: true
    field :push_notification_token, String, null: true
    field :one_signal_player_id, String, null: true
    field :last_active_at, Mobile::Graph::Types::DateTimeType, null: false
    field :sign_out_at, Mobile::Graph::Types::DateTimeType, null: true
    field :settings, [DeviceSettingType], null: true
    field :device_uuid, String, null: true

    def settings
      Mobile::Device::SETTINGS.map do |property|
        { name: property.to_s, is_enabled: object[property] }
      end
    end
  end
end
