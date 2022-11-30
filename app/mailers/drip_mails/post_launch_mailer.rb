# frozen_string_literal: true

class DripMails::PostLaunchMailer < DripMails::BaseMailer
  DRIP_KIND = :post_launch

  def scheduled_launch(post, user)
    return unless Notifications::UserPreferences.accepted?(user, :send_maker_report_email)

    email_campaign_name campaign_name(DRIP_KIND, __method__), deduplicate: true

    @post = post
    @user = user
    @subscriber = @user.subscriber
    @tracking_params = Metrics.url_tracking_params(medium: :email, object: 'product_launch_scheduled')
    @unsubscribe_url = Notifications::UnsubscribeWithToken.url kind: :maker_report, user: user

    transactional_mail(
      subject: 'Ready for launch',
      to: @user.email,
    )
  end

  def immediate_launch(post, user)
    return unless Notifications::UserPreferences.accepted?(user, :send_maker_report_email)

    email_campaign_name campaign_name(DRIP_KIND, __method__), deduplicate: true

    @post = post
    @user = user
    @subscriber = @user.subscriber
    @tracking_params = Metrics.url_tracking_params(medium: :email, object: 'product_launch_immediate')
    @unsubscribe_url = Notifications::UnsubscribeWithToken.url kind: :maker_report, user: user

    transactional_mail(
      subject: 'Lift off 🚀',
      to: @user.email,
    )
  end

  def post_launch(post, user)
    return unless Notifications::UserPreferences.accepted?(user, :send_maker_report_email)

    email_campaign_name campaign_name(DRIP_KIND, __method__), deduplicate: true
    @post = post
    @user = user
    @subscriber = @user.subscriber
    @tracking_params = Metrics.url_tracking_params(medium: :email, object: 'product_launch_post_launch')
    @unsubscribe_url = Notifications::UnsubscribeWithToken.url kind: :maker_report, user: user

    transactional_mail(
      subject: 'Report to mission control',
      to: @user.email,
    )
  end

  def two_week_post_launch(post, user)
    return unless Notifications::UserPreferences.accepted?(user, :send_maker_report_email)

    email_campaign_name campaign_name(DRIP_KIND, __method__), deduplicate: true

    @post = post
    @product = post.new_product
    @user = user
    @subscriber = @user.subscriber
    @tracking_params = Metrics.url_tracking_params(medium: :email, object: 'product_launch_two_week_launch')
    @unsubscribe_url = Notifications::UnsubscribeWithToken.url kind: :maker_report, user: user

    transactional_mail(
      subject: 'Launches fade. Reviews are forever.',
      to: @user.email,
    )
  end
end
