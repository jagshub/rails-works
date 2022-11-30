# frozen_string_literal: true

module GoldenKitty::EmailNotifications
  extend self

  PEOPLE_CATEGORIES_SLUG = ['community-member-of-the-year', 'maker-of-the-year'].freeze

  def send_nomination_open(edition)
    subscriptions_for(edition).find_each do |subscription|
      GoldenKittyMailer.nomination_open(subscription).deliver_later if can_send_for?(subscription)
    end
  end

  def send_voting_open(edition)
    today_open_categories = edition.categories.where_date_eq(:voting_enabled_at, Time.zone.today).where.not(slug: PEOPLE_CATEGORIES_SLUG).to_a
    return if today_open_categories.empty?

    already_voted_users = Vote.where(subject: categories_finalist(today_open_categories)).pluck(:user_id)

    subscriptions_for(edition).merge(Subscriber.where.not(user_id: already_voted_users)).find_each do |subscription|
      GoldenKittyMailer.voting_open(subscription, today_open_categories).deliver_later if can_send_for?(subscription)
    end
  end

  # Note(Raj): Send golden kitty emails only when user has email notifications turned on
  def can_send_for?(subscription)
    user = subscription.subscriber.user

    return true if user.blank?

    user.send_golden_kitty_email
  end

  private

  # Note(Rahul): Send only to active subscribers w/ email confirmed
  def subscriptions_for(edition)
    edition
      .subscriptions
      .active
      .joins(:subscriber)
      .merge(subscriber_scope)
  end

  def subscriber_scope
    Subscriber.with_email_confirmed
  end

  def categories_finalist(categories)
    GoldenKitty::Finalist.where(golden_kitty_category: categories)
  end
end
