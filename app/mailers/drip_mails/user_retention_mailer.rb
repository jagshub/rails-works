# frozen_string_literal: true

class DripMails::UserRetentionMailer < DripMails::BaseMailer
  DRIP_KIND = :user_retention

  def initial_no_engagement(user)
    email_campaign_name campaign_name(DRIP_KIND, __method__), deduplicate: true

    @user = user
    @subscriber = @user.subscriber
    @tracking_params = Metrics.url_tracking_params(medium: :email, object: 'initial_no_engagement')
    @posts = Feed::WhatYouMissed.call(since: DripMails::UserRetention::INACTIVTIY_PERIOD.ago, user: @user, limit: 4, override_min: true)

    transactional_mail(
      subject: "Products you don't want to miss",
      to: @user.email,
    )
  end
end
