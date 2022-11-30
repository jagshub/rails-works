# frozen_string_literal: true

class UpcomingPages::ExportSubscribersToCsvWorker < FileExports::CsvWorker
  def csv_contents(csv, upcoming_page:, **_options)
    csv << %i(email subscribed_at name username headline twitter_username followers)

    upcoming_page.confirmed_subscribers.includes(contact: :user).find_each do |subscriber|
      row = [subscriber.email, subscriber.created_at]

      if subscriber.user.present?
        row << subscriber.user.name
        row << subscriber.user.username
        row << subscriber.user.headline
        row << subscriber.user.twitter_username
        row << subscriber.user.follower_count
      end

      csv << row
    end

    csv
  end

  def mail_subject(upcoming_page:, **_options)
    "Export of #{ upcoming_page.name } subscribers"
  end

  def mail_message(upcoming_page:, **_options)
    "Your export of #{ upcoming_page.name } subscribers is ready."
  end

  def note(upcoming_page:, **_options)
    "Subscribers for upcoming page ##{ upcoming_page.id }"
  end
end
