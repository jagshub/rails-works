# frozen_string_literal: true

module Mobile::Graph::Resolvers
  class IsSubscriptionMuted < Mobile::Graph::Resolvers::BaseResolver
    type Boolean, null: false

    def resolve
      return false if current_user.blank?

      SubscriptionsLoader.for(current_user).load(object)
    end

    class SubscriptionsLoader < GraphQL::Batch::Loader
      def initialize(user)
        @user = user
      end

      def perform(objects)
        subscription_keys =
          @user
          .all_subscriptions
          .where(condition_for(objects))
          .where(muted: true)
          .pluck(object_key_column)

        objects.each do |object|
          fulfill object, subscription_keys.include?(object_key(object))
        end
      end

      private

      def condition_for(objects)
        ["#{ object_key_column } IN (?)", objects.map { |object| object_key(object) }]
      end

      def object_key(object)
        "#{ object.class.name }#{ object.id }"
      end

      def object_key_column
        Arel.sql('subject_type || subject_id')
      end
    end
  end
end
