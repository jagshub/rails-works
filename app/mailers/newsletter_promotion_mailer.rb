# frozen_string_literal: true

class NewsletterPromotionMailer < ApplicationMailer
  def generic_opt_out_email(email)
    email_campaign_name 'promotion_opt_out_email'

    @unsubscribe_url = Notifications::UnsubscribeWithToken.url(kind: 'newsletter', email: email)

    mail(to: email, from: CommunityContact.default_from, subject: "You're in! 🎉",
         delivery_method_options: CommunityContact.delivery_method_options, reply_to: CommunityContact::REPLY)
  end

  def upscribe_opt_out_email(email)
    email_campaign_name 'upscribe_opt_out_email'

    @unsubscribe_url = Notifications::UnsubscribeWithToken.url(kind: 'newsletter', email: email)

    mail(to: email, from: CommunityContact.default_from, subject: "You've got Product Hunt mail 💌",
         delivery_method_options: CommunityContact.delivery_method_options, reply_to: CommunityContact::REPLY)
  end

  def paris_prague_opt_out_email(email)
    email_campaign_name 'promotion_opt_out_email'

    @unsubscribe_url = Notifications::UnsubscribeWithToken.url(kind: 'newsletter', email: email)

    mail(to: email, from: CommunityContact.default_from, subject: "You're in! 🎉",
         delivery_method_options: CommunityContact.delivery_method_options, reply_to: CommunityContact::REPLY)
  end

  def habit_opt_out_email(email)
    email_campaign_name 'habit_opt_out_email'

    @unsubscribe_url = Notifications::UnsubscribeWithToken.url(kind: 'newsletter', email: email)

    mail(to: email, from: CommunityContact.default_from, subject: "You're in! 🎉",
         delivery_method_options: CommunityContact.delivery_method_options, reply_to: CommunityContact::REPLY)
  end

  def live_like_opt_out_email(email)
    email_campaign_name 'live_like_opt_out_email'

    @unsubscribe_url = Notifications::UnsubscribeWithToken.url(kind: 'newsletter', email: email)

    mail(to: email, from: CommunityContact.default_from, subject: "You're in in the sweepstakes 🎉",
         delivery_method_options: CommunityContact.delivery_method_options, reply_to: CommunityContact::REPLY)
  end

  SAMPLE_NEWSLETTER_IDS = [8081, 8117, 8178, 8046].freeze

  def ph_giveaway(email)
    email_campaign_name 'ph_giveaway_opt_out_email'

    @unsubscribe_url = Notifications::UnsubscribeWithToken.url(kind: 'newsletter', email: email)

    @newsletter1, @newsletter2, @newsletter3, @newsletter4 = Newsletter.where(id: SAMPLE_NEWSLETTER_IDS).sort_by { |n| SAMPLE_NEWSLETTER_IDS.index(n.id) }

    mail(to: email, from: CommunityContact.default_from, subject: 'Welcome to the Product Hunt daily digest 👋',
         delivery_method_options: CommunityContact.delivery_method_options, reply_to: CommunityContact::REPLY)
  end
end
