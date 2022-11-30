# frozen_string_literal: true

class UpcomingPages::Defaults::BaseProvider
  def name
    ''
  end

  def tagline
    ''
  end

  def template_name
    nil
  end

  def topic_ids
    []
  end

  def logo_uuid
    nil
  end

  def what_text
    tagline
  end
end
