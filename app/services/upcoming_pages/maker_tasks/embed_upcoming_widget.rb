# frozen_string_literal: true

class UpcomingPages::MakerTasks::EmbedUpcomingWidget < UpcomingPages::MakerTasks::BaseTask
  def title
    'Add widget to your website'
  end

  def description
    "Let visitors know you're launching on Product Hunt"
  end

  def completed?
    TrackingPixel.tracked?(upcoming_page, :upcoming_widget)
  end

  def url
    Routes.embed_upcoming_widget_path upcoming_page.slug
  end
end
