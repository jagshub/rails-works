# frozen_string_literal: true

module Users::GDPR::Delete
  extend self

  def call(user: nil, email: nil)
    email = email.presence || user.email
    subscriber = user&.subscriber || Subscriber.find_by_email(email)
    user ||= subscriber&.user

    reassociate_user_essential_data(user)

    redact_user_data(user)
    delete_user_nonessential_data(user)

    delete_subscriber(subscriber)

    delete_email_from_records(email)

    delete_from_segment(user)
    delete_from_mailjet(email)
    delete_from_iterable(email)

    notify_slack(user)
  end

  private

  def reassociate_user_essential_data(user)
    return if user.blank?
    return if user.posts_count.zero?

    ph_user = ProductHunt.user!

    user.posts.each do |post|
      post.update(user: ph_user)
    end
  end

  def delete_user_nonessential_data(user)
    return if user.blank?

    user.access_tokens.delete_all
    user.collection_subscriptions.destroy_all
    user.collections.destroy_all

    user.file_exports.destroy_all
    user.flags.delete_all
    user.goals.destroy_all
    user.link_trackers.delete_all
    user.all_maker_group_memberships.destroy_all
    user.maker_suggestions.destroy_all
    user.oauth_applications.destroy_all
    user.post_topic_associations.update_all(user_id: nil)
    user.product_makers.destroy_all
    user.product_requests.destroy_all
    user.promoted_analytics.delete_all
    user.recommendations.destroy_all
    user.reviews.destroy_all
    user.ship_lead.try(:destroy)
    user.ship_tracking_identities.destroy_all
    user.ship_contacts.destroy_all
    user.delete_survey.try(:destroy)
    user.user_follow_product_request_associations.destroy_all
    user.user_friend_associations.delete_all
    user.user_follower_associations.delete_all
    user.votes.destroy_all
    user.team_memberships.destroy_all
  end

  def delete_from_iterable(email)
    Iterable::RemoveUserWorker.perform_later(email: email)
    Iterable::EventWebhookDatum.where(email: email).destroy_all
  end

  def redact_user_data(user)
    return if user.blank?

    user.comments.update_all(body: 'Comment Deleted')

    Ships::CancelSubscription.call(user: user, at_period_end: false) if user.ship_subscription.present?

    Notifications::UserPreferences.unsubscribe_from_all(user)

    SignIn::SOCIAL_ATTRIBUTES.each do |attribute_name|
      user[attribute_name] = nil
    end

    user.update!(
      name: 'Ghost Kitty',
      username: "ghost-kitty-#{ user.id }",
      avatar: nil,
      follower_count: 0,
      friend_count: 0,
      header_uuid: nil,
      headline: nil,
      helpful_recommendations_count: 0,
      image: nil,
      last_twitter_sync_error: nil,
      private_profile: true,
      product_requests_count: 0,
      receive_direct_messages: false,
      recommendations_count: 0,
      trashed_at: DateTime.now.utc,
      twitter_access_secret: nil,
      twitter_access_token: nil,
      twitter_username: nil,
      website_url: nil,
    )
  end

  def delete_subscriber(subscriber)
    subscriber&.destroy!
  end

  def delete_email_from_records(email)
    return if email.blank?

    ShipContact.with_email(email).destroy_all
    Email.with_email(email).destroy_all
    CollectionSubscription.where(email: email).destroy_all
    Clearbit::PersonProfile.where(email: email).destroy_all
    # NOTE(DZ): Record is readonly, no cascade required
    PromotedEmail::Signup.where(email: email).delete_all
    Job.where(email: email).destroy_all
    ShipLead.where(email: email).destroy_all
  end

  def delete_from_segment(user)
    return if user.blank?
    return unless Rails.env.production?

    External::SegmentApi.gdpr_delete(user_id: user.id)
  end

  def delete_from_mailjet(email)
    return if email.blank?
    return unless Rails.env.production?

    External::MailjetApi.gdpr_delete(user_email: email)
  end

  def notify_slack(user)
    return unless Rails.env.production?

    SlackNotify.call(
      channel: 'gdpr',
      text: "GDPR delete has been completed for user #{ user&.id }",
      username: 'GDPR',
      icon_emoji: ':closed_lock_with_key:',
    )
  end
end
