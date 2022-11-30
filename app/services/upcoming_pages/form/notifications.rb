# frozen_string_literal: true

module UpcomingPages::Form::Notifications
  extend self

  def call(upcoming_page)
    prev_status, status = upcoming_page.previous_changes[:status]

    return if prev_status != 'unlisted' && status != 'promoted'
    return if upcoming_page.featured_at.present?

    Ships::Slack::UpcomingPagePendingFeaturing.call(upcoming_page: upcoming_page)
  end
end
