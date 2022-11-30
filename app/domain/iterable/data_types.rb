# frozen_string_literal: true

module Iterable::DataTypes
  extend self

  def get_user_data_fields(user)
    current_streak = user.visit_streaks.current.first

    {
      name: user.name,
      username: user.username,
      email_verified: user.verified?,
      account_creation_date: user.created_at.strftime('%Y-%m-%d %H:%M:%S %:z'),
      is_maker: user.maker?,
      launches_number: ProductMaker.where(user_id: user.id).count,
      jobs_interest: user.job_search,
      role: user.role,
      twitter_handle: user.twitter_username,
      visit_streak: current_streak&.duration,
      visit_streak_max_duration: user.visit_streaks.maximum(:duration),
      self_description: get_primary_reason(user),
      unsubscribe_token: EmailUnsubscribeToken.get_permanent_token(user: user, email: user.email)[:token],
      visit_streak_last_updated_at: current_streak&.last_visit_at&.strftime('%Y-%m-%d %H:%M:%S %:z'),
      profile_bio_length: user.about&.length || 0,
    }.compact
  end

  def get_message_types(user)
    form = My::UserSettings.new(user)

    subscribed_message_type_ids = []
    unsubscribed_message_type_ids = []

    (form.send_ph_updates_email ? subscribed_message_type_ids : unsubscribed_message_type_ids).push Config.iterable_message_type_id(:ph_updates)
    (form.send_activity_email ? subscribed_message_type_ids : unsubscribed_message_type_ids).push Config.iterable_message_type_id(:ph_activities)
    (form.send_community_updates_email ? subscribed_message_type_ids : unsubscribed_message_type_ids).push Config.iterable_message_type_id(:ph_community)
    (form.send_ship_updates_email ? subscribed_message_type_ids : unsubscribed_message_type_ids).push Config.iterable_message_type_id(:ph_ship)
    (form.send_maker_updates_email ? subscribed_message_type_ids : unsubscribed_message_type_ids).push Config.iterable_message_type_id(:ph_maker_updates)
    (form.jobs_newsletter_subscription == 'subscribed' ? subscribed_message_type_ids : unsubscribed_message_type_ids).push Config.iterable_message_type_id(:ph_jobs_digest)
    (form.send_ph_recommendations_email ? subscribed_message_type_ids : unsubscribed_message_type_ids).push Config.iterable_message_type_id(:ph_recommendations)
    (form.send_promotions_email ? subscribed_message_type_ids : unsubscribed_message_type_ids).push Config.iterable_message_type_id(:promotions)

    {
      subscribed_message_type_ids: subscribed_message_type_ids,
      unsubscribed_message_type_ids: unsubscribed_message_type_ids,
    }
  end

  private

  ## Note(Bharat): 'share_products' is given highest priority. Then, 'discover_products' and after that 'not_sure'.
  def get_primary_reason(user)
    self_description = OnboardingReason.reasons[:not_sure]

    self_description = OnboardingReason.reasons[:discover_products] if user.onboarding_reasons.any? do |onboarding|
      onboarding.reason == OnboardingReason.reasons[:discover_products]
    end

    self_description = OnboardingReason.reasons[:share_products] if user.onboarding_reasons.any? do |onboarding|
      onboarding.reason == OnboardingReason.reasons[:share_products]
    end

    self_description
  end
end
