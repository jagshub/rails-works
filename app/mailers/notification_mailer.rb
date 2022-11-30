# frozen_string_literal: true

class NotificationMailer < ApplicationMailer
  helper MailHelper
  helper NewsletterHelper

  def newsletter_notification(notification, sponsor: nil, post_ad: nil, cache: nil, first_time: false)
    NewRelic::Agent.set_transaction_name 'NotificationMailer/newsletter_notification'

    @newsletter = fetch_newsletter notification
    @subscriber = notification.subscriber
    @user = @subscriber.user
    @first_time = first_time
    @content = Newsletter::Content.new @newsletter, for_user_id: @subscriber.user_id, cache: cache
    @sponsor = sponsor
    @post_ad = post_ad
    @switch_to_weekly_url = Notifications::UnsubscribeWithToken.url(kind: 'daily_newsletter', email: @subscriber.email, ph_notification_id: notification.id) if @newsletter.daily?
    @unsubscribe_url = Notifications::UnsubscribeWithToken.url(kind: 'newsletter', email: @subscriber.email, ph_notification_id: notification.id)
    @tracking_params = Metrics.url_tracking_params(medium: :newsletter, object: @newsletter)
    primary_content =
      @content
      .sections
      .find { |section| section.layout == 'primary_featured' }
        &.content || ''
    @mobile_preview = create_mobile_preview primary_content
    @tracking_editorial = @tracking_params.merge utm_term: 'editorial'
    @tracking_featured = @tracking_params.merge utm_term: 'featured'

    # Note (Josh V) the daily / weekly newsletters have the ID stored in the title
    # We using this id to find delivered count for newsletters
    email_campaign_name "#{ @newsletter.daily? ? 'Daily' : 'Weekly' } (#{ notification.notifyable.id }) - #{ notification.notifyable.subject } ", deduplicate: true if notification.notifyable.sent?
    # Note(Rahul): If custom_id value is changed, we should update Metrics::NewsletterEventWorker as well
    if notification.kind == 'newsletter_experiment'
      email_custom_id @newsletter.id, @subscriber.id, notification.notifyable.id
    else
      email_custom_id @newsletter.id, @subscriber.id
    end

    event_payload = { personalized_content: false, registered: @content.user? }
    event_payload[:sponsor_id] = @sponsor.id if @sponsor.is_a?(Ads::NewsletterSponsor)
    event_payload[:post_ad_id] = @post_ad.id if @post_ad.present?
    email_event_payload(event_payload)

    mail(
      to: @subscriber.email,
      from: @newsletter.from_address,
      reply_to: @newsletter.reply_to_address,
      subject: notification.notifyable.subject,
    ) do |format|
      format.html do
        render(
          layout: 'newsletter_digest',
          template: 'notification_mailer/newsletter_digest',
        )
      end
    end
  end

  def new_follower_notification(notification, subject: nil)
    assign_params_from notification
    email_campaign_name('new_follower_notification')

    @follower = notification.notifyable
    @from_user = @follower
    @fun_fact = FunFact.to_html(@follower, tracking_params: @tracking_params)
    @mutual_friends = MutualFriends.to_html(@follower, @user, tracking_params: @tracking_params)
    set_unsubscribe_url_for 'new_follower_notifications', notification
    @unsubscribe_url = Notifications::UnsubscribeWithToken.url(kind: 'new_follower_notifications', user: notification.subscriber.user, ph_notification_id: notification.id)

    mail to: notification.subscriber.email, subject: subject || "#{ @follower.name } followed you"
  end

  def friend_product_maker_notification(notification)
    assign_params_from notification
    email_campaign_name('friend_product_maker_notification')

    @subject = notification.notifier.push_text_heading(notification)
    @post = notification.notifyable.post
    @from_user = notification.notifyable.user
    @comment = @post.comments.top_level.find_by(user: @from_user)
    @unfollow_url = Notifications::UnsubscribeWithToken.url(kind: 'unfollow_user', user: notification.subscriber.user, friend_id: @from_user.id)
    set_unsubscribe_url_for 'friend_post_notifications', notification

    mail to: notification.subscriber.email, subject: @subject
  end

  def mention_notification(notification)
    assign_params_from notification
    email_campaign_name('mention_notification')

    @comment = notification.notifyable
    @from_user = @comment.user
    set_unsubscribe_url_for 'comment_notifications', notification

    subject = %(#{ @from_user.name } mentioned you in "#{ @comment.subject_name }")
    template_name = 'mention_notification'

    mail(
      to: notification.subscriber.email,
      subject: subject,
      template_name: template_name,
    )
  end

  def shoutout_mention_notification(notification)
    assign_params_from notification
    email_campaign_name('shoutout_mention_notification')

    @user = notification.subscriber.user

    @shoutout = notification.notifyable
    set_unsubscribe_url_for 'shoutout_mention_notification', notification

    mail(
      to: notification.subscriber.email,
      subject: 'New mentions in Product Hunt Shout-out',
      template_name: 'shoutout_mention_notification',
    )
  end

  def awarded_badges_notification_daily(notification)
    assign_params_from notification
    email_campaign_name 'awarded_badges_notifications'
    set_unsubscribe_url_for 'maker_report', notification

    @daily_badge = notification.notifyable
    @post = notification.notifyable.subject

    mail(
      to: notification.subscriber.email,
      subject: "You did it! You're Product of the Day!🥳",
    )
  end

  def awarded_badges_notification_weekly(notification)
    assign_params_from notification
    email_campaign_name 'awarded_badges_notifications'
    set_unsubscribe_url_for 'maker_report', notification

    period = notification.notifyable.data['period']

    # Note(RO): Grabbing the rest of the badges this Post might have gotten in the same period (topic badges)
    @post = notification.notifyable.subject
    @badges = @post.badges.where(type: ['Badges::TopPostBadge', 'Badges::TopPostTopicBadge']).with_period(period)
    return if @badges.empty?

    mail(
      to: notification.subscriber.email,
      subject: 'They love you. Show it off.😻',
    )
  end

  def awarded_badges_notification_monthly(notification)
    assign_params_from notification
    email_campaign_name 'awarded_badges_notifications'
    set_unsubscribe_url_for 'maker_report', notification

    period = notification.notifyable.data['period']

    # Note(RO): Grabbing the rest of the badges this Post might have gotten in the same period (topic badges)
    @post = notification.notifyable.subject
    @badges = @post.badges.where(type: ['Badges::TopPostBadge', 'Badges::TopPostTopicBadge']).with_period(period)
    return if @badges.empty?

    mail(
      to: notification.subscriber.email,
      subject: 'You’re on fire! Product of the Month is yours 🏆',
    )
  end

  def upcoming_event_launched_notification(notification)
    assign_params_from notification
    email_campaign_name('upcoming_event_launched_notification')

    upcoming_event = notification.notifyable
    @post = upcoming_event.post
    @subscriber = notification.subscriber
    @user = notification.subscriber.user

    set_unsubscribe_url_for 'product_updates', notification

    mail to: notification.subscriber.email, subject: "🚀#{ @post.name } has launched"
  end

  private

  def set_unsubscribe_url_for(kind, notification)
    @unsubscribe_url = Notifications::UnsubscribeWithToken.url(kind: kind, user: notification.subscriber.user, ph_notification_id: notification.id)
  end

  def assign_params_from(notification)
    @user = notification.subscriber.user
    @tracking_params = Metrics.url_tracking_params(medium: :email, object: notification.kind)
  end

  def fetch_newsletter(notification)
    notification.kind == 'newsletter_experiment' ? notification.notifyable.newsletter : notification.notifyable
  end

  def create_mobile_preview(content)
    sanitized_content = ActionView::Base.full_sanitizer.sanitize(content)
    preview_sentences = sanitized_content.strip.split('.')
    # Note(RO): if the first sentence is about sponsorships, we remove it from preview
    preview_sentences = preview_sentences.drop(1) if preview_sentences[0]&.include? 'sponsored'
    preview = preview_sentences.join('.').truncate_words(20).strip

    preview
  end
end
