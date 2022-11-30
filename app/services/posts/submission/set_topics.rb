# frozen_string_literal: true

module Posts::Submission::SetTopics
  extend self

  def call(post:, user:, topic_ids:)
    base_topic_ids = topic_ids || post.topic_ids

    suggested_topics = ::Topics::Recommendations.based_on_product_links(post).map(&:id)

    all_topic_ids = base_topic_ids | suggested_topics

    post.post_topic_associations = all_topic_ids.uniq.map do |topic_id|
      assoc = post.post_topic_associations.find_by topic_id: topic_id
      assoc || post.post_topic_associations.create!(topic_id: topic_id, user: user)
    end
  end
end
