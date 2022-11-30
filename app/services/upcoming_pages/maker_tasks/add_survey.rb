# frozen_string_literal: true

class UpcomingPages::MakerTasks::AddSurvey < UpcomingPages::MakerTasks::BaseTask
  def title
    'Create a survey'
  end

  def description
    'Gather more info about your subscriber interests'
  end

  def completed?
    upcoming_page.surveys.count > 0
  end

  def url
    Routes.new_my_upcoming_page_survey_url(upcoming_page)
  end
end
