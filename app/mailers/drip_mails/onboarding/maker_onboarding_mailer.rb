# frozen_string_literal: true

class DripMails::Onboarding::MakerOnboardingMailer < DripMails::BaseMailer
  DRIP_KIND = :maker_onboarding

  def initial_welcome(user)
    email_campaign_name campaign_name(DRIP_KIND, __method__), deduplicate: true

    @user = user
    @subscriber = @user.subscriber
    @tracking_params = Metrics.url_tracking_params(medium: :email, object: 'maker_onboarding_welcome')
    @unsubscribe_url = Notifications::UnsubscribeWithToken.url(kind: 'send_onboarding_email', user: @user, email: @subscriber.email)

    transactional_mail(
      subject: 'Welcome to Product Hunt 😺',
      to: @user.email,
    )
  end

  def launch_case_study(user)
    email_campaign_name campaign_name(DRIP_KIND, __method__), deduplicate: true

    @user = user
    @subscriber = @user.subscriber
    @tracking_params = Metrics.url_tracking_params(medium: :email, object: 'maker_onboarding_launch_case_study')
    @unsubscribe_url = Notifications::UnsubscribeWithToken.url(kind: 'send_onboarding_email', user: @user, email: @subscriber.email)

    featured_stories = [
      { story: Anthologies::Story.find(3136), description: 'Loom co-founder, Shahed Khan, talked to us about growing the company from 3,000 to over 10 million users.', users: [10_168] },
      { story: Anthologies::Story.find(1090), description: 'YAC co-founders share their story about the Thanksgiving hackathon project that turned into a venture-backed company.', users: [126_585, 15_272, 592_018] },
      { story: Anthologies::Story.find(3598), description: 'Techintern.io had a goal and game plan for its Product Hunt launch and captured one of its largest customers to date, Mozilla.', users: [333_452] },
    ]

    @featured_stories = featured_stories.map do |featured_story|
      featured_story[:users] = User.where(id: featured_story[:users]).select(%i(id name username))
      featured_story
    end

    transactional_mail(
      subject: 'A story for every launch',
      to: @user.email,
    )
  end

  def additional_maker_resources(user)
    email_campaign_name campaign_name(DRIP_KIND, __method__), deduplicate: true

    @user = user
    @subscriber = @user.subscriber
    @tracking_params = Metrics.url_tracking_params(medium: :email, object: 'maker_onboarding_additional_resources')
    @unsubscribe_url = Notifications::UnsubscribeWithToken.url(kind: 'send_onboarding_email', user: @user, email: @subscriber.email)

    transactional_mail(
      subject: 'Keep going...',
      to: @user.email,
    )
  end
end
