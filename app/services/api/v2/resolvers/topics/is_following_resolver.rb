# frozen_string_literal: true

module API::V2::Resolvers
  class Topics::IsFollowingResolver < BaseResolver
    type Boolean, null: false

    def resolve
      return false unless can_resolve_private?

      IsFollowingLoader.for(current_user).load(object)
    end

    class IsFollowingLoader < GraphQL::Batch::Loader
      def initialize(user)
        @user = user
      end

      def perform(topics)
        followed_ids = @user.subscriptions.for_topics.where(subject_id: topics.map(&:id)).pluck(:subject_id)

        topics.each do |topic|
          fulfill topic, followed_ids.include?(topic.id)
        end
      end
    end
  end
end
