# frozen_string_literal: true

module Topics::Follow
  extend self

  def set(topic_ids, user)
    followed = user.followed_topic_ids
    topic_ids = topic_ids.map(&:to_i)

    return if followed.to_set == topic_ids.to_set

    new_topics = topic_ids.select { |id| followed.exclude? id }
    to_remove = followed - topic_ids

    Topic.where(id: to_remove).each { |topic| Subscribe.unsubscribe(topic, user) } if to_remove.any?

    Topic.where(id: new_topics).each { |topic| Subscribe.subscribe(topic, user) }
  end
end
