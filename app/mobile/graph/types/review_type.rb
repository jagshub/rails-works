# frozen_string_literal: true

module Mobile::Graph::Types
  class ReviewType < BaseObject
    graphql_name 'ReviewType'

    implements VotableInterfaceType

    field :id, ID, null: false

    field :created_at, DateTimeType, null: false
    field :updated_at, DateTimeType, null: false
    field :rating, Int, null: true
    field :overall_experience, String, null: true
    field :currently_using, ReviewCurrentlyUsingType, null: true

    field :positive_tags, [ReviewTagType], null: false
    field :negative_tags, [ReviewTagType], null: false

    field :formatted_body, FormattedTextType, null: true, method: :body

    association :user, UserType, null: false
    association :comment, CommentType, null: true
    association :product, ProductType, null: true
  end
end
