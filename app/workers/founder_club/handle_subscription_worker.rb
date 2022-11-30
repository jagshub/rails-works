# frozen_string_literal: true

class FounderClub::HandleSubscriptionWorker < Payments::EventHandler
  project :founder_club

  def handle(subscription)
    access_request = FounderClub::AccessRequest.where('user_id = ? OR email = ?', subscription.user_id, subscription.user.email&.downcase).first
    access_request&.update! subscribed_at: subscription.created_at
  end
end
