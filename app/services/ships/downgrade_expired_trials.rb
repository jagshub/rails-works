# frozen_string_literal: true

module Ships::DowngradeExpiredTrials
  extend self

  def call
    ShipSubscription.trial.where('trial_ends_at < ?', 5.weeks.ago).find_each do |subscription|
      Ships::EndSubscriptionWorker.perform_later(subscription.user)
    end
  end
end
