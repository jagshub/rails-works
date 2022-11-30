class RemoveSettingsAndPushNotificationEnabledColumnsFromMobileDevice < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      remove_column :mobile_devices, :settings, :jsonb
      remove_column :mobile_devices, :is_push_notifications_enabled, :boolean
    end
  end
end
