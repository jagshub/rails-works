# frozen_string_literal: true

module Newsletter::Send
  extend self

  def call(newsletter)
    return false unless newsletter.sendable?

    newsletter.update! status: :sent

    schedule(newsletter)

    notify_featured_makers(newsletter)

    true
  end

  def start_delivery(newsletter)
    raise "Can't start delivery because newsletter status with subject #{ newsletter.subject } is #{ newsletter.status }" unless newsletter.sent?

    schedule(newsletter)
  end

  private

  def schedule(newsletter)
    Notifications.notify_about(object: newsletter, kind: 'newsletter', long_running: true)

    Newsletters::RescheduleDeliveryWorker.set(wait: 30.minutes).perform_later(newsletter)
  end

  def notify_featured_makers(newsletter)
    newsletter.posts.each do |post_hash|
      makers_ids = post_hash['makers']&.split(',')

      next unless makers_ids

      User.find(makers_ids).each do |user|
        next unless user.send_featured_maker_email

        MakerMailer.featured_in_newsletter(user, post_hash, newsletter).deliver_later
      end
    end
  end
end
