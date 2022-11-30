# frozen_string_literal: true

class UpcomingPages::MakerTasks::AddSocialLinks < UpcomingPages::MakerTasks::BaseTask
  def title
    'Add social links'
  end

  def description
    'Grow your following on other platforms'
  end

  def completed?
    upcoming_page.links.any?
  end

  def url
    Routes.edit_my_upcoming_page_url(upcoming_page)
  end
end
