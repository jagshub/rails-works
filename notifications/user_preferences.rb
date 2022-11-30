# frozen_string_literal: true

module Notifications::UserPreferences
  extend self

  FLAGS = User.storext_definitions.select { |_k, v| v[:column] == :notification_preferences }.keys

  def accepted?(user, setting)
    return false if user.trashed?
    return false unless FLAGS.any? { |flag| user.send(flag) }

    if user.respond_to?(setting)
      user.send(setting)
    elsif Mobile::Device.column_names.include?(setting.to_s)
      Mobile::Device.enabled_push_for(user_id: user.id, option: setting.to_s).exists?
    else
      raise "Setting #{ setting } doesn't exist for User#{ user.id }"
    end
  end

  def unsubscribe_from_all(user)
    user.attributes = FLAGS.map { |k| [k, false] }.to_h
  end

  def subscribed_to_any_notification?(user)
    user.notification_preferences.select { |k, _v| FLAGS.include?(k.to_sym) }.value?(true)
  end
end
