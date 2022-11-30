# frozen_string_literal: true

class Iterable::TriggerEventWorker < ApplicationJob
  include ActiveJobHandleNetworkErrors

  def perform(event_name:, email:, user_id:, data_fields: {})
    External::IterableAPI.trigger_event(event_name: event_name, email: email, user_id: user_id.to_s, data_fields: data_fields) if email.present?
  end
end
