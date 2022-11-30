# frozen_string_literal: true

module API::V2Internal::Mutations
  class UpdateSettings < BaseMutation
    My::UserSettings.attribute_names.each do |name|
      argument name, Notifications::UserPreferences::FLAGS.include?(name) || Graph::Types::SettingsType::NOTIFICATION_OPTIONS.include?(name) ? Boolean : String, required: false, camelize: false
    end

    returns API::V2Internal::Types::SettingsType

    def perform
      return error :current_user, :blank if current_user.nil?

      form = My::UserSettings.new(current_user)
      form.update(inputs)
      form
    end
  end
end
