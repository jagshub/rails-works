# frozen_string_literal: true

class Newsletter::Email
  class << self
    def build_for_admin_preview(newsletter, preview_as: nil)
      user = preview_as || User.new
      subscriber = Subscriber.new user: user, email: 'email@example.com'
      notification = NotificationLog.new subscriber: subscriber, notifyable: newsletter, kind: :newsletter
      event = NotificationEvent.new notification: notification, channel_name: 'email'
      ads_cache = Ads::NewsletterAdsCache.new(newsletter)
      sponsor = ads_cache.get_newsletter_sponsor
      post_ad = ads_cache.get_newsletter_post_ad

      new event, sponsor: sponsor, post_ad: post_ad
    end

    def deliver_test(object, email)
      return false unless EmailValidator.valid? email

      subscriber = Subscriber.find_by_email(email) || Subscriber.new(email: email)

      newsletter = if object.is_a? NewsletterVariant
                     object.newsletter
                   else
                     object
                   end

      test_newsletter = Newsletter.new newsletter.attributes
      test_newsletter.subject = "TEST: #{ object.subject }"

      notification = NotificationLog.new subscriber: subscriber, notifyable: test_newsletter, kind: :newsletter
      event = NotificationEvent.new notification: notification, channel_name: 'email'
      ads_cache = Ads::NewsletterAdsCache.new(newsletter)
      sponsor = ads_cache.get_newsletter_sponsor
      post_ad = ads_cache.get_newsletter_post_ad

      new(event, sponsor: sponsor, post_ad: post_ad).send('mail').deliver_now

      true
    end
  end

  def initialize(notification_event, sponsor: nil, post_ad: nil, cache: nil)
    @event = notification_event
    first_time = check_if_first_time_recipient(@event.subscriber)
    @mail = Premailer::Rails::Hook.perform(
      NotificationMailer.newsletter_notification(
        notification_event,
        sponsor: sponsor,
        post_ad: post_ad,
        cache: cache,
        first_time: first_time,
      ),
    )
  end

  def html
    mail.html_part.body.to_s
  end

  def text
    mail.text_part.body.to_s
  end

  # NOTE(rstankov): #  Documentation: https://dev.mailjet.com/guides/?ruby#sending-in-bulk
  def to_mailjet_params
    headers = mail.header.map { |f| [f.name, f.value] }.to_h

    {
      'FromEmail' => mail.from.first,
      'FromName' => @event.kind == 'newsletter_experiment' ? @event.notifyable.newsletter.from_name : @event.notifyable.from_name,
      'Recipients' => mail.to.map { |mail| { 'Email' => mail } },
      'subject' => mail.subject,
      'text-part' => text,
      'html-part' => html,
      'headers' => {
        'Reply-To' => headers['Reply-To'],
        'X-Feedback-ID' => headers['X-Feedback-ID'],
      },
      'Mj-campaign' => headers['Mj-campaign'],
      'Mj-EventPayLoad' => headers['X-MJ-EventPayload'],
      'Mj-CustomID' => headers['X-MJ-CustomID'],
      'Mj-deduplicatecampaign' => 1,
    }
  end

  private

  attr_reader :mail

  def check_if_first_time_recipient(subscriber)
    # NOTE(DZ): For preview, subscriber record is temporary
    return false unless subscriber.persisted?

    first_time = !!subscriber.first_time_newsletter_recipient
    subscriber.update! first_time_newsletter_recipient: false if first_time

    first_time
  end
end
