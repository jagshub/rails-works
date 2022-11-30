# frozen_string_literal: true

module Anthologies::StoryHelper
  include ActionView::Helpers::TextHelper
  extend self

  def body_preview(body_html)
    return if body_html.blank?

    text = ActionView::Base.full_sanitizer.sanitize body_html

    # Note(Rahul): 224 is the number we took from the design
    truncate(text, length: 224)
  end
end
