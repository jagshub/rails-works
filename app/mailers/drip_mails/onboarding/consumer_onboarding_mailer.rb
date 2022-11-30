# frozen_string_literal: true

class DripMails::Onboarding::ConsumerOnboardingMailer < DripMails::BaseMailer
  DRIP_KIND = :consumer_onboarding

  def initial_welcome(user)
    email_campaign_name campaign_name(DRIP_KIND, __method__), deduplicate: true

    @user = user
    @subscriber = @user.subscriber
    @tracking_params = Metrics.url_tracking_params(medium: :email, object: 'consumer_onboarding_welcome')
    @unsubscribe_url = Notifications::UnsubscribeWithToken.url(kind: 'send_onboarding_email', user: @user, email: @subscriber.email)

    transactional_mail(
      subject: 'Welcome to Product Hunt 😺',
      to: @user.email,
    )
  end

  def followup_welcome(user)
    email_campaign_name campaign_name(DRIP_KIND, __method__), deduplicate: true

    @user = user
    @subscriber = @user.subscriber
    @tracking_params = Metrics.url_tracking_params(medium: :email, object: 'consumer_onboarding_welcome_2')
    @unsubscribe_url = Notifications::UnsubscribeWithToken.url(kind: 'send_onboarding_email', user: @user, email: @subscriber.email)
    featured_stories = [
      { story: Anthologies::Story.find(3367), user: 3_211_709, description: ' quit her job to become a maker. Her website, Product Lessons, helps other entrepreneurs learn and grow with actionable insights.' },
      { story: Anthologies::Story.find(3004), user: 1_132_395, description: '\'s focus on community has helped him launch products and discover opportunities. His advice: build community first, then products.' },
      { story: Anthologies::Story.find(3037), user: 251_206, description: ' struggled with imposter syndrome despite a successful career as a software engineer. She built HypeDocs for herself, then launched it to the world.' },
    ]

    @featured_stories = featured_stories.map do |featured_story|
      featured_story[:user] = User.select(%i(id name username)).find(featured_story[:user])
      featured_story
    end

    transactional_mail(
      subject: "You're ready.",
      to: @user.email,
    )
  end

  def newsletter_signup_cta(user)
    email_campaign_name campaign_name(DRIP_KIND, __method__), deduplicate: true

    @user = user
    @subscriber = @user.subscriber
    @tracking_params = Metrics.url_tracking_params(medium: :email, object: 'consumer_onboarding_newsletter_signup')
    @unsubscribe_url = Notifications::UnsubscribeWithToken.url(kind: 'send_onboarding_email', user: @user, email: @user.subscriber.email)

    transactional_mail(
      subject: 'The top products in your inbox',
      to: @user.email,
    )
  end
end
