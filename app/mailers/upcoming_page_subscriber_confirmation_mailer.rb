# frozen_string_literal: true

class UpcomingPageSubscriberConfirmationMailer < ApplicationMailer
  include Ships::MailWithShipApiKeys

  def confirm_email(subscriber)
    email_campaign_name 'upcoming_page_subscriber_confirm_email'

    @subscriber = subscriber
    @upcoming_page = subscriber.upcoming_page
    @upcoming_page_name = @upcoming_page.name

    @confirm_path = Routes.confirm_my_upcoming_page_subscription_url(
      slug: subscriber.upcoming_page.slug,
      token: subscriber.token,
    )

    mail(
      to: subscriber.email,
      from: %("#{ @upcoming_page.name }" <#{ @upcoming_page.inbox_email }>),
      subject: "#{ @upcoming_page_name } - Please confirm your email",
    )
  end
end
