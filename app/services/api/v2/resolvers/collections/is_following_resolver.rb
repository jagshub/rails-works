# frozen_string_literal: true

module API::V2::Resolvers
  class Collections::IsFollowingResolver < BaseResolver
    type Boolean, null: false

    def resolve
      return false unless can_resolve_private?

      IsFollowingLoader.for(current_user).load(object)
    end

    class IsFollowingLoader < GraphQL::Batch::Loader
      def initialize(user)
        @user = user
      end

      def perform(collections)
        followed_ids = @user.active_collection_subscriptions.where(collection_id: collections.map(&:id)).pluck(:collection_id)

        collections.each do |topic|
          fulfill topic, followed_ids.include?(topic.id)
        end
      end
    end
  end
end
