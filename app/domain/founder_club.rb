# frozen_string_literal: true

module FounderClub
  extend self

  def policy
    Policy
  end

  def mailer_info
    MailerInfo
  end

  def claim_deal(user:, deal:)
    ClaimDeal.call(user: user, deal: deal)
  rescue ClaimDeal::CantRedeemDealError => e
    ErrorReporting.report_warning(e, extra: { user_id: user.id, deal_id: deal.id })
    nil
  end

  def active_subscription?(user:)
    ::FounderClub::Subscription.active?(user)
  end

  def plan(discount_code: nil)
    Plan.for_discount_code(discount_code)
  end

  def add_referral(email:, invited_by:)
    AccessRequests.add_referral(email: email, invited_by: invited_by)
  end

  def remove_referral(email:, invited_by:)
    AccessRequests.remove_referral(email: email, invited_by: invited_by)
  end

  def referral?(email:)
    AccessRequests.referral?(email: email)
  end

  def accept_referral_code(code)
    AccessRequests.accept_referral_code(code)
  end

  def admin_transfer_subscription(owner, receiver_username)
    ::FounderClub::Admin::TransferSubscription.call(owner, receiver_username)
  end

  def admin_deal_form
    ::FounderClub::Admin::DealForm
  end

  def handle_subscription(subscription)
    FounderClub::HandleSubscriptionWorker.perform_later(subscription)
  end
end
