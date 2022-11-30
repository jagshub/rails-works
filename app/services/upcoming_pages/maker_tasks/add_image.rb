# frozen_string_literal: true

class UpcomingPages::MakerTasks::AddImage < UpcomingPages::MakerTasks::BaseTask
  def title
    'Add an image or video'
  end

  def description
    'Explain what problem you are solving'
  end

  def completed?
    doc_has_images?(upcoming_page.who_text) ||
      doc_has_images?(upcoming_page.what_text) ||
      doc_has_images?(upcoming_page.why_text)
  end

  def url
    Routes.edit_my_upcoming_page_url(upcoming_page)
  end

  private

  def doc_has_images?(field)
    Nokogiri::XML(field).xpath('//img').present?
  end
end
