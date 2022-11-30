# frozen_string_literal: true

module Notifications::Channels::Email
  extend self

  def channel_name
    :email
  end

  def minimum_hours_distance
    8
  end

  def deliver(event)
    Notifications::Channels::Email::Service.call(event)
  end

  def delivering_to?(subscriber)
    subscriber.email_confirmed? && ::EmailValidator.valid?(subscriber.email)
  end
end
