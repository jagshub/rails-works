# frozen_string_literal: true

class SlackBot::GreetingWorker < ApplicationJob
  def perform(subscriber)
    SlackBot::Greeting.deliver_for subscriber
  end
end
