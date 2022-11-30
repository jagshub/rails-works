# frozen_string_literal: true

module Discussions
  extend self

  def description_text(description)
    ::Discussions::Helper.description_text description
  end
end
