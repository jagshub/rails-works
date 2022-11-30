# frozen_string_literal: true

module Graph::Types
  class ReviewType < BaseObject
    graphql_name 'Review'

    implements Graph::Types::CommentableInterfaceType
    implements Graph::Types::VotableInterfaceType
    implements Graph::Types::ShareableInterfaceType

    field :id, ID, null: false
    field :comments_count, Int, null: false
    field :created_at, Graph::Types::DateTimeType, null: false
    field :updated_at, Graph::Types::DateTimeType, null: false
    field :product, Graph::Types::ProductType, null: true
    field :sentiment, Graph::Types::Reviews::SentimentType, null: true
    field :rating, Int, null: true
    field :overall_experience, String, null: true
    field :currently_using, Graph::Types::Reviews::CurrentlyUsingType, null: true
    field :body, Graph::Types::HTMLType, null: true
    field :is_hidden, Boolean, method: :hidden?, null: false
    field :can_update, resolver: Graph::Resolvers::Can.build(:update)
    field :can_destroy, resolver: Graph::Resolvers::Can.build(:destroy)
    field :positive_tags, [Graph::Types::Reviews::TagType], null: false
    field :negative_tags, [Graph::Types::Reviews::TagType], null: false
    field :path, String, null: false

    association :user, Graph::Types::UserType, null: false
    association :comment, Graph::Types::CommentType, null: true
    association :post, Graph::Types::PostType, null: true

    def path
      Routes.review_path(object)
    end

    def url
      Routes.review_url(object)
    end
  end
end
