# frozen_string_literal: true

class GoldenKittyMailer < ApplicationMailer
  def subscribed(subscription)
    subscriber = subscription.subscriber
    edition = subscription.subject
    email_campaign_name "golden_kitty_#{ edition.year }_subscribed"
    email = subscriber.email

    return if email.blank?

    @unsubscribe_url = unsubscribe_url(subscription, email)
    @mobile_preview_tag = "You're subscribed to latest updates from Golden Kitty Awards!"

    mail(
      to: email,
      subject: "You're signed up!",
    )
  end

  def nomination_open(subscription)
    subscriber = subscription.subscriber
    edition = subscription.subject
    email_campaign_name "golden_kitty_#{ edition.year }_nomination_open", deduplicate: true
    email = subscriber.email

    return if email.blank?

    @unsubscribe_url = unsubscribe_url(subscription, email)
    @edition = subscription.subject

    nomination_start = @edition.nomination_starts_at
    nomination_end = @edition.nomination_ends_at
    event_day = @edition.result_at

    @start_date = nomination_start.strftime("%A, %B #{ nomination_start.day.ordinalize }")
    @end_date = nomination_end.strftime("%A, %B #{ nomination_end.day.ordinalize }")
    @virtual_event_date = event_day.strftime("%B #{ event_day.day.ordinalize }")
    @phase_image = 'gk-nomination-open'
    @mobile_preview_tag = 'Nominations are now open for Golden Kitty Awards!'

    mail(
      to: email,
      subject: 'The Golden Kitty Awards have landed',
    )
  end

  def voting_open(subscription, categories)
    subscriber = subscription.subscriber
    category_ids = categories.map(&:id).sort.join('_')
    email_campaign_name "golden_kitty_voting_open_#{ category_ids }", deduplicate: true
    email = subscriber.email

    return if email.blank?

    @unsubscribe_url = unsubscribe_url(subscription, email)
    @edition = subscription.subject
    @categories = categories
    @voting_closes_at = @edition.voting_ends_at.strftime('%A %B %d at %I:%M%p PT')
    @phase_image = image_for(categories)
    @mobile_preview_tag = 'Voting is now open for Golden Kitty Awards!'

    mail(
      to: email,
      subject: "Voting now open: Golden Kitty #{ subscription.subject.year } 🏆",
    )
  end

  private

  def unsubscribe_url(subscription, email)
    Notifications::UnsubscribeWithToken.url(kind: 'golden_kitty_notifications', email: email, subscription_id: subscription.id)
  end

  def image_for(categories)
    category_slugs = categories.map(&:slug)

    drop_1_image_slugs = ['audio-and-voice', 'mobile-app', 'no-code', 'productivity', 'work-from-anywhere', 'wtf']
    drop_2_image_slugs = ['ai-and-machine-learning', 'fintech', 'hardware', 'privacy-focused', 'saas', 'web-3']
    drop_3_image_slugs = ['community-and-social', 'children-and-family', 'creator-economy', 'diversity-and-inclusion', 'social-impact']
    drop_4_image_slugs = ['design-tools', 'developer-tools', 'e-commerce', 'education', 'health-and-fitness']
    drop_5_image_slugs = ['best-product-video', 'side-project', 'product-of-the-year']

    return 'gk_voting_open_drop_1' if (drop_1_image_slugs - category_slugs).empty?
    return 'gk_voting_open_drop_2' if (drop_2_image_slugs - category_slugs).empty?
    return 'gk_voting_open_drop_3' if (drop_3_image_slugs - category_slugs).empty?
    return 'gk_voting_open_drop_4' if (drop_4_image_slugs - category_slugs).empty?
    return 'gk_voting_open_drop_5' if (drop_5_image_slugs - category_slugs).empty?
  end
end
