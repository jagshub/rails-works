# frozen_string_literal: true

module API::V2Internal::Types
  class SettingsType < BaseObject
    graphql_name 'Settings'

    field :id, ID, null: false
    field :can_change_username, resolver: ::Graph::Resolvers::Can.build(:change_username, &:user)

    def id
      object.user.id
    end

    ::SignIn::SOCIAL_ATTRIBUTES.each do |attribute_name|
      name = attribute_name.to_s.gsub('_uid', '_connected')

      field name, Boolean, null: false

      define_method(name) do
        object.user[attribute_name].present?
      end
    end

    ::My::UserSettings.attribute_names.each do |name|
      if ::Notifications::UserPreferences::FLAGS.include?(name)
        field name, Boolean, null: false, camelize: false
      elsif %i(hide_hiring_badge private_profile job_search remote).include?(name)
        field name, Boolean, null: false, camelize: false
      elsif [:skills].include?(name)
        field name, [String], null: false, camelize: false
      else
        field name, String, null: true, camelize: false
      end
    end
  end
end
