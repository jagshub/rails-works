# frozen_string_literal: true

class Ships::Subscription
  attr_reader :user, :subscription

  def self.from_account(account)
    new(account.user)
  end

  def initialize(user)
    @user = user
    @subscription = user&.ship_subscription
  end

  def id
    return unless valid?

    subscription.id
  end

  def valid?
    subscription.present? && !subscription.ended?
  end

  def premium?
    return false unless valid?

    subscription.pro? || subscription.super_pro?
  end

  def can_schedule_posts?
    premium_without_trial?
  end

  def can_segments?
    premium?
  end

  def can_use_email_form?
    premium?
  end

  def can_use_surveys?
    premium?
  end

  def can_promote_upcoming_page?
    premium_without_trial?
  end

  def can_send_continuous_messages?
    premium?
  end

  def can_access_premium_support?
    premium?
  end

  def can_claim_aws_credits?
    premium_without_trial? && annual?
  end

  def can_use_webhooks?
    super_pro?
  end

  def can_use_metrics?
    super_pro?
  end

  def can_use_ab?
    super_pro?
  end

  def can_send_message?
    return false if user&.spammer?
    return true if premium?
    return false unless valid?

    messages_sent_this_week == 0
  end

  def can_create_upcoming_page?
    return true if premium?
    return false if user&.spammer?
    return false unless valid?
    return true if upcoming_pages.visible.count == 0

    Ships::MakerFestival.allowed_extra_page?(user)
  end

  def trial_available?
    return false if subscription.present?

    !user&.ship_user_metadata&.trial_used
  end

  def trial_ended?
    valid? && subscription&.trial_ended?
  end

  def in_trial?
    subscription&.trial?
  end

  private

  def upcoming_pages
    UpcomingPage.where(user: user)
  end

  def messages_sent_this_week
    @messages_sent_this_week ||= UpcomingPageMessage.sent.where(upcoming_page_id: upcoming_pages.pluck(:id)).this_week.count
  end

  def premium_without_trial?
    return false if in_trial?

    premium?
  end

  def super_pro?
    return false unless valid?

    subscription.super_pro?
  end

  def annual?
    subscription.annual?
  end
end
