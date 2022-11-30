# frozen_string_literal: true

class Iterable::TriggerBulkEventWorker < ApplicationJob
  include ActiveJobHandleNetworkErrors

  def perform(events)
    External::IterableAPI.bulk_trigger_events(events: events) if events.any?
  end
end
