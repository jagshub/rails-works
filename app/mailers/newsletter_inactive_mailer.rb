# frozen_string_literal: true

class NewsletterInactiveMailer < ApplicationMailer
  # Note(Rahul): digest_type can be 'daily' or 'weekly'
  def digest(email, digest_type = 'daily')
    month_year = Time.zone.now.strftime('%h_%Y').downcase
    email_campaign_name "#{ digest_type }_inactive_unsubscribe_#{ month_year }"

    mail(
      to: email,
      from: CommunityContact.from(name: CommunityContact::NEWSLETTER_CONTACT_NAME, email: CommunityContact::NEWSLETTER_CONTACT_EMAIL),
      subject: "We removed you from the #{ digest_type.capitalize } Digest",
      reply_to: CommunityContact::NEWSLETTER_CONTACT_REPLY,
      delivery_method_options: CommunityContact.delivery_method_options,
    )
  end
end
