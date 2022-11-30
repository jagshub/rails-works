# frozen_string_literal: true

module Subscribers::Register
  extend self

  class DuplicatedSubscriberError < StandardError
    def initialize(existing, new_user, attributes)
      super("Duplicated attributes #{ attributes.keys.join(', ') } from ##{ existing.id } to ##{ new_user.id }")
    end
  end

  def call(attributes)
    attributes.compact!
    attributes[:email] = attributes[:email].to_s.downcase if attributes[:email].present?
    user = attributes.delete(:user)

    return subscriber_without_users_for(attributes) if user.nil?
    return Subscriber.for_user(user) if attributes.empty?

    Subscriber.without_user.find_by(attributes).try :destroy

    existing = Subscriber.with_user.find_by(attributes)

    raise DuplicatedSubscriberError.new(existing, user, attributes) if existing.present? && existing.user_id != user.id

    subscriber = Subscriber.for_user(user.reload)
    subscriber.email_confirmed = set_email_as_confirmed? subscriber, attributes
    subscriber.update attributes

    subscriber
  end

  private

  def subscriber_without_users_for(attributes)
    HandleRaceCondition.call do
      Subscriber.find_or_create_by!(attributes)
    end
  end

  def set_email_as_confirmed?(subscriber, attributes)
    return subscriber.email_confirmed unless attributes.key?(:email)

    subscriber.email_confirmed &&
      !attributes[:email].nil? &&
      attributes[:email] == subscriber.email
  end
end
