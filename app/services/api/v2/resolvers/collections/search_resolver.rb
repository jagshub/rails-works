# frozen_string_literal: true

module API::V2::Resolvers
  class Collections::SearchResolver < BaseSearchResolver
    # NOTE(dhruvparmar372): Type needs to be explicitly set to connection_type
    # here because Member::BuildType.to_type_name fails here https://github.com/rmosolgo/graphql-ruby/blob/545a3acf885f97489c154eb63d7975228fa80a99/lib/graphql/schema/field.rb#L114
    # for some reason
    type ::API::V2::Types::CollectionType.connection_type, null: false

    scope { Collection.published }

    option :post_id, type: GraphQL::Types::ID, description: 'Select Collections that have the Post with the given ID.', with: :apply_post_id_filter
    option :user_id, type: GraphQL::Types::ID, description: 'Select Collections that are created by User with the given ID.', with: :apply_user_id_filter
    option :featured, type: GraphQL::Types::Boolean, description: 'Select Collections that have been featured or not featured depending on given value.', with: :apply_featured_filter
    option :order, type: API::V2::Types::CollectionsOrderType, description: 'Define order for the Collections.', default: 'FOLLOWERS_COUNT'

    private

    def apply_post_id_filter(scope, value)
      return if value.blank?

      scope.joins(:collection_post_associations).where('collection_post_associations.post_id': value)
    end

    def apply_user_id_filter(scope, value)
      return if value.blank?

      scope.where(user_id: value)
    end

    def apply_featured_filter(scope, value)
      scope.featured if value
    end

    def apply_order_with_newest(scope)
      scope.by_date
    end

    def apply_order_with_featured_at(scope)
      scope.by_feature_date
    end

    def apply_order_with_followers_count(scope)
      scope.by_subscriber_count
    end
  end
end
