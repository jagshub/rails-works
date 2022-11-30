# frozen_string_literal: true

class Notifications::ScheduleWorker < ApplicationJob
  include ActiveJobHandleDeserializationError

  queue_as :notifications

  def perform(kind:, object:, subscriber_id:)
    Notifications::Schedule.call kind: kind, object: object, subscriber_id: subscriber_id
  end
end
