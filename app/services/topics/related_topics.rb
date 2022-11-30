# frozen_string_literal: true

module Topics::RelatedTopics
  extend self

  def call(topic, limit: 5)
    scope = Topics::Recommendations.based_on(topic)
    scope = scope.where.not(id: topic.id)
    scope = scope.limit(limit)

    scope
  end
end
