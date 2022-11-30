# frozen_string_literal: true

module Newsletter::Experiment::Send
  extend self

  def call(experiment)
    return false if experiment.sent?
    return false unless experiment.sendable?

    Notifications.notify_about object: experiment, kind: 'newsletter_experiment'

    experiment.update! status: :sent

    true
  end
end
