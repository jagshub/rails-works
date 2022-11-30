# frozen_string_literal: true

module Notifications
  extend self

  def notify_about(kind:, object:, wait_until: nil, long_running: false)
    worker = Notifications::FanOutWorker

    worker = worker.set(wait_until: wait_until) if wait_until.present?

    worker = worker.set(queue: :long_running) if long_running

    worker.perform_later(kind: kind.to_s, object: object)
  end
end
