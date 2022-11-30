# frozen_string_literal: true

class Graph::Resolvers::Anthologies::RelatedStoriesResolver < Graph::Resolvers::BaseSearch
  scope { related_stories_by_publish_date }

  private

  def related_stories_by_publish_date
    object.related_stories
  end
end
