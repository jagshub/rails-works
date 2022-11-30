# frozen_string_literal: true

class UpcomingPages::MakerTasks::SlackIntegration < UpcomingPages::MakerTasks::BaseTask
  def title
    'Slack integration'
  end

  def description
    'Stay up to day with updates on your upcoming page'
  end

  def completed?
    return true if slack_active? upcoming_page.user
    return true if slack_active? upcoming_page.account.user
    return true if upcoming_page.account.members.joins(:subscriber).any? { |user| slack_active? user }

    false
  end

  def url
    Routes.my_upcoming_page_slack_url(upcoming_page)
  end

  private

  def slack_active?(user)
    user.subscriber&.slack_active
  end
end
