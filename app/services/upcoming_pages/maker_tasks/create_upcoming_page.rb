# frozen_string_literal: true

class UpcomingPages::MakerTasks::CreateUpcomingPage < UpcomingPages::MakerTasks::BaseTask
  def title
    'Create an upcoming page'
  end

  def description
    'Start gathering interest'
  end

  def completed?
    true
  end

  def url
    Routes.my_upcoming_pages_url
  end
end
