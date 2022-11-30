# frozen_string_literal: true

module Notifications::Deliver
  extend self

  def call(event)
    case Notifications::Helpers::DefaultChecks.check(event)
    when :send then try_to_deliver(event)
    when :dont_sent then event.mark_as_rejected
    when :postpone then event.mark_as_postponed
    end
    event.save!
  end

  private

  def try_to_deliver(event)
    event.channel.deliver(event)
    event.mark_as_sent
  rescue Notifications::Channels::DeliveryError => e
    event.mark_as_failed reason: e.message
    ErrorReporting.report_error(e)
  end
end
