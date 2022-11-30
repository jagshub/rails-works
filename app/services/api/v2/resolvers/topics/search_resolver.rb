# frozen_string_literal: true

module API::V2::Resolvers
  class Topics::SearchResolver < BaseSearchResolver
    # NOTE(dhruvparmar372): Type needs to be explicitly set to connection_type
    # here because Member::BuildType.to_type_name fails here https://github.com/rmosolgo/graphql-ruby/blob/545a3acf885f97489c154eb63d7975228fa80a99/lib/graphql/schema/field.rb#L114
    # for some reason
    type ::API::V2::Types::TopicType.connection_type, null: false

    scope { Topic.all }

    option :followed_by_userId, type: GraphQL::Types::ID, description: 'Select Topics that are followed by User with the given ID.', with: :for_followed_by_user_id
    option :query, type: GraphQL::Types::String, description: 'Select Topics whose name or aliases match the given string', with: :for_query
    option :order, type: API::V2::Types::TopicsOrderType, description: 'Define order for the Topics.', default: 'NEWEST'

    private

    def for_followed_by_user_id(scope, value)
      return if value.blank?

      subscriber = Subscriber.find_by(user_id: value)
      return Topic.none if subscriber.blank?

      scope.joins(:subscriptions).where('subscriptions.subscriber_id': subscriber)
    end

    def for_query(scope, value)
      return if value.blank?

      scope.by_query(value)
    end

    def apply_order_with_newest(scope)
      scope.by_date
    end

    def apply_order_with_followers_count(scope)
      scope.by_followers_count
    end
  end
end
