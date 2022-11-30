# frozen_string_literal: true

class Notifications::FanOutWorker < ApplicationJob
  include ActiveJobHandleDeserializationError

  queue_as :notifications

  def perform(kind:, object:)
    notifier = Notifications::Notifiers.for(kind)
    notifier.fan_out(object, kind: kind) if notifier.fan_out? object
  end
end
