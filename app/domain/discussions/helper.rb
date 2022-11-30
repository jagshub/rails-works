# frozen_string_literal: true

module Discussions::Helper
  extend self

  def description_text(description)
    return if description.blank?

    ActionController::Base.helpers.strip_tags(description)
  end
end
