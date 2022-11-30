# frozen_string_literal: true

module Anthologies
  extend self

  def story_category(slug)
    Anthologies::Category.call slug
  end

  def index_page_featured_stories
    Anthologies::FeaturedStories.call
  end

  def story_body_preview(story)
    Anthologies::StoryHelper.body_preview story.body_html
  end

  def update_story_events(story)
    Anthologies::UpdateStoryEvents.call story
  end
end
