# frozen_string_literal: true

class UpcomingPages::MakerTasks::UploadSubscriberList < UpcomingPages::MakerTasks::BaseTask
  def title
    'Import your mailing list'
  end

  def description
    'Add social proof to your page'
  end

  def completed?
    upcoming_page.imports.count > 0
  end

  def url
    Routes.import_my_upcoming_page_subscribers_url(upcoming_page)
  end
end
