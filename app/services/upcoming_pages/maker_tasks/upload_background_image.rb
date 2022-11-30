# frozen_string_literal: true

class UpcomingPages::MakerTasks::UploadBackgroundImage < UpcomingPages::MakerTasks::BaseTask
  def title
    'Upload a background image'
  end

  def description
    'Personalize your upcoming page'
  end

  def completed?
    !UpcomingPages::Defaults.default_background_image?(upcoming_page.background_image_uuid)
  end

  def url
    Routes.my_upcoming_page_team_design_url(upcoming_page)
  end
end
