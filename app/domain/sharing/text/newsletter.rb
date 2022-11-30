# frozen_string_literal: true

module Sharing::Text::Newsletter
  extend self

  def call(newsletter)
    Twitter::Message
      .new
      .add_mandatory("In today's @ProductHunt Digest: #{ newsletter.subject }")
      .add_mandatory(Routes.newsletter_url(newsletter))
      .to_s
  end
end
