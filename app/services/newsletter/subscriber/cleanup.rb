# frozen_string_literal: true

require 'csv'
require 'open-uri'

module Newsletter::Subscriber::Cleanup
  extend self

  def call(csv:, source_details:, action: Newsletter::Subscriptions::UNSUBSCRIBED, send_email: false)
    subscriber_ids = CSV.parse(URI.parse(csv).open, headers: true, skip_blanks: true).map { |row| row['id'] }.uniq.reject(&:blank?)
    unsubscribed_ids = NotificationUnsubscriptionLog.where(kind: 'newsletter', source_details: source_details, source: 'newsletter_list_cleaning').pluck(:subscriber_id)

    unsubscribed = {
      count: 0,
      ids: [],
    }

    Subscriber.where(id: (subscriber_ids - unsubscribed_ids)).find_each do |subscriber|
      subscriber.newsletter_subscription = action

      if subscriber.changes.present?
        subscriber.save!

        NotificationUnsubscriptionLog.create!(
          subscriber: subscriber,
          kind: 'newsletter',
          source: 'newsletter_list_cleaning',
          source_details: source_details,
          channel_name: 'email',
        )

        email = subscriber.email
        NewsletterInactiveMailer.digest(email, 'daily').deliver_later if send_email && email.present? && subscriber.email_confirmed

        unsubscribed[:count] += 1
        unsubscribed[:ids].push subscriber.id
      end
    end

    External::S3Api.put_object(
      bucket: :exports,
      key: External::S3Api.generate_key,
      body: unsubscribed.to_json,
      content_type: 'application/json',
    )
  end
end
