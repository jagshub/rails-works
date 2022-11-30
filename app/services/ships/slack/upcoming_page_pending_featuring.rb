# frozen_string_literal: true

class Ships::Slack::UpcomingPagePendingFeaturing < Ships::Slack::Notification
  attr_reader :upcoming_page

  class << self
    def call(upcoming_page:)
      new(upcoming_page).deliver
    end
  end

  def initialize(upcoming_page)
    @upcoming_page = upcoming_page
  end

  private

  def channel
    'ship_community_activity'
  end

  def author
    upcoming_page.user
  end

  def title
    "#{ upcoming_page.name } requested featuring"
  end

  def title_link
    "https://www.producthunt.com/upcoming/#{ upcoming_page.slug }"
  end

  def fields
    [
      { title: 'Tagline', value: upcoming_page.tagline, short: true },
      { title: 'Subscribers', value: upcoming_page.subscriber_count, short: true },
    ]
  end

  def icon_emoji
    ':star:'
  end

  def color
    '#e6e6e6'
  end
end
