# frozen_string_literal: true

module Collections::RelatedTopics
  extend self

  def call(collection, limit: 10)
    Topics::Recommendations.based_on(collection).limit(limit)
  end
end
