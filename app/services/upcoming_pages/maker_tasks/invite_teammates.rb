# frozen_string_literal: true

class UpcomingPages::MakerTasks::InviteTeammates < UpcomingPages::MakerTasks::BaseTask
  def title
    'Invite your teammates'
  end

  def description
    'Get your entire team on board'
  end

  def completed?
    upcoming_page.account.members.count.positive?
  end

  def url
    Routes.my_upcoming_page_team_members_url(upcoming_page)
  end
end
