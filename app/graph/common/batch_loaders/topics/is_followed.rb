# frozen_string_literal: true

module Graph::Common::BatchLoaders
  class Topics::IsFollowed < GraphQL::Batch::Loader
    def initialize(user)
      @user = user
    end

    def perform(topics)
      followed_ids =
        @user
        .subscriptions
        .for_topics
        .where(subject_id: topics.map(&:id))
        .pluck(:subject_id)

      topics.each do |topic|
        fulfill topic, followed_ids.include?(topic.id)
      end
    end
  end
end
