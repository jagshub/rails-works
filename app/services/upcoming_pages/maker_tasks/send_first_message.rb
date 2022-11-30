# frozen_string_literal: true

class UpcomingPages::MakerTasks::SendFirstMessage < UpcomingPages::MakerTasks::BaseTask
  MIN_SUBSCRIBER_COUNT = 20

  class << self
    def create(upcoming_page)
      return if upcoming_page.blank?
      return if upcoming_page.messages.sent.count > 0
      return if upcoming_page.confirmed_subscribers.count < MIN_SUBSCRIBER_COUNT

      super
    end
  end

  def title
    'Send your first message'
  end

  def description
    'Share a status update with your community'
  end

  def completed?
    upcoming_page.messages.sent.count > 0
  end

  def url
    Routes.new_my_upcoming_page_message_url(upcoming_page)
  end
end
