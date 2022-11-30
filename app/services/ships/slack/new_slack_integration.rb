# frozen_string_literal: true

class Ships::Slack::NewSlackIntegration < Ships::Slack::Notification
  class << self
    def call(user)
      new(user).deliver
    end
  end

  def initialize(user)
    @author = user
  end

  private

  attr_reader :author

  def channel
    'ship_activity'
  end

  def title
    'A new slack integration'
  end

  def title_link
    Routes.profile_url(author)
  end

  def icon_emoji
    ':slack:'
  end

  def color
    '#d8c7a6'
  end

  def fields
    UpcomingPage.for_maintainers(author).map do |upcoming_page|
      {
        title: 'Upcoming Page',
        value: "<#{ Routes.upcoming_page_url(upcoming_page) }|#{ upcoming_page.name.gsub('>', '&gt;') }>",
      }
    end
  end
end
