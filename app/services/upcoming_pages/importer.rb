# frozen_string_literal: true

class UpcomingPages::Importer
  attr_reader :import, :failed_count, :success_count, :duplicate_count, :subscriber_emails

  class << self
    def call(import)
      new(import).call
    end
  end

  def initialize(import)
    @import = import
    @failed_count = 0
    @success_count = 0
    @duplicate_count = 0
  end

  def call
    parse_csv

    if subscriber_emails.blank?
      import.failed!
      notify_invalid_file

      :empty
    elsif import.reviewed?
      complete_import
      upcoming_page.reviewed_imports!

      :reviewed
    elsif reached_subscriber_threshold?
      import.in_review!
      upcoming_page.over_threshold!
      notify_ph
      notify_blocked

      :blocked
    else
      complete_import

      :success
    end
  end

  def parse_csv
    out = []

    CSV.parse(csv_content, headers: true, header_converters: ->(h) { h.try(:encode, 'UTF-8').try(:parameterize).try(:underscore) }).each do |row|
      email = Utf8Sanitize.call(row['email_address'] || row['email'])
      out << email if email.present?
    end

    @subscriber_emails = out
    @import.update!(emails_count: @subscriber_emails.count)
  rescue CSV::MalformedCSVError, Encoding::UndefinedConversionError => e
    Rails.logger.info e
    @subscriber_emails = []
  end

  private

  DATA_URL_REGEX = /^data:[^;]*;base64,/.freeze

  def csv_content
    if import.payload_csv.to_s.match?(DATA_URL_REGEX)
      # NOTE(emilov): looks like in rails > 6 decode64() returns a string encoded as ASCII-8BIT, so we make sure it's UTF-8
      Base64.decode64(import.payload_csv.to_s.gsub(DATA_URL_REGEX, '')).encode('UTF-8')
    else
      import.payload_csv
    end
  end

  def reached_subscriber_threshold?
    new_subscriber_count = upcoming_page.subscribers.count + subscriber_emails.count
    over_threshold = new_subscriber_count >= Rails.configuration.settings.ship_max_import_before_flagged.to_i
    !upcoming_page.under_threshold? && !upcoming_page.reviewed_imports? || over_threshold
  end

  def complete_import
    import_subscribers
    import.update!(
      state: :completed,
      failed_count: @failed_count,
      imported_count: @success_count,
      duplicated_count: @duplicate_count,
    )
    notify_success
  end

  def import_subscribers
    subscriber_emails.each do |email|
      import_row(email)
    end
  end

  def notify_invalid_file
    UpcomingPageMailer.import_invalid_file(
      upcoming_page_email_import: import,
    ).deliver_now
  end

  def notify_ph
    UpcomingPageMailer.import_notify_ph(
      upcoming_page_email_import: import,
    ).deliver_now
  end

  def notify_blocked
    UpcomingPageMailer.import_in_review(
      upcoming_page_email_import: import,
    ).deliver_now
  end

  def notify_success
    UpcomingPageMailer.import_finished(
      upcoming_page_email_import: import,
      failed_count: failed_count,
      success_count: success_count,
      duplicate_count: duplicate_count,
    ).deliver_now
  end

  def import_row(email)
    existing_subscriber = find_subscriber_by_email(email)
    if existing_subscriber
      add_subscriber_to_segment(existing_subscriber)
      duplicate!
    elsif import_email(email).persisted?
      success!
    else
      failed!
    end
  end

  def add_subscriber_to_segment(subscriber)
    return unless import.segment

    UpcomingPages::Segments.assign(
      subscriber: subscriber,
      segment: import.segment,
    )
  end

  def find_subscriber_by_email(email)
    upcoming_page.subscribers.joins(:contact).find_by('ship_contacts.email' => email)
  end

  def import_email(email)
    subscriber = Ships::Contacts::CreateSubscriber.from_import(subscription_target: upcoming_page, email: email)

    add_subscriber_to_segment(subscriber) if subscriber.persisted?

    subscriber
  end

  def duplicate!
    @duplicate_count += 1
  end

  def failed!
    @failed_count += 1
  end

  def success!
    @success_count += 1
  end

  def upcoming_page
    @import.upcoming_page
  end
end
