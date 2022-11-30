# frozen_string_literal: true

class UpcomingPages::MakerTasks::UploadLogo < UpcomingPages::MakerTasks::BaseTask
  def title
    'Upload a logo'
  end

  def description
    'Brand your upcoming page'
  end

  def completed?
    upcoming_page.logo_uuid.present?
  end

  def url
    Routes.edit_my_upcoming_page_url(upcoming_page)
  end
end
