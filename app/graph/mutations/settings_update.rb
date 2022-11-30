# frozen_string_literal: true

module Graph::Mutations
  class SettingsUpdate < BaseMutation
    (My::UserSettings.attribute_names - %i(topic_ids links)).each do |name|
      notification_fields = Notifications::UserPreferences::FLAGS.include?(name)
      notification_options = Graph::Types::SettingsType::NOTIFICATION_OPTIONS.include?(name)
      argument name, notification_fields || notification_options ? Boolean : String, required: false
    end

    argument :topic_ids, [ID], required: false
    argument :links, [Graph::Types::UserLinkInputType], required: false

    returns Graph::Types::SettingsType

    require_current_user

    def perform(inputs)
      form = My::UserSettings.new(current_user)
      form.update(inputs)

      Iterable::SyncUserWorker.perform_later(user: current_user) ## Note(Bharat): sync user details with iterable
      Iterable::SyncUserSubscriptionWorker.perform_later(current_user) ## Note(Bharat): sync user subscriptions with iterable
      form
    end
  end
end
