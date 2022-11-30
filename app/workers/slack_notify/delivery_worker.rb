# frozen_string_literal: true

class SlackNotify::DeliveryWorker < ApplicationJob
  def perform(channel:, message:)
    return unless Rails.env.production?

    client = Slack::Notifier.new(SlackNotify::CHANNELS.fetch(channel.to_sym))
    client.ping(message)
  end
end
