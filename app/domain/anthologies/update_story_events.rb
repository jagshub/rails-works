# frozen_string_literal: true

module Anthologies::UpdateStoryEvents
  extend self

  def call(story)
    return unless story.published?

    products = story.product_mentions

    if products.empty?
      story_events = Products::ActivityEvent.where(subject: story)

      story_events.destroy_all
    else
      products.each do |product|
        Products::RefreshActivityEvents.new(product).call
      end
    end
  end
end
