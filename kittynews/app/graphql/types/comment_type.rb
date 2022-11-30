module Types
  class CommentType < Types::BaseObject
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :text, String, null: false
    field :user, UserType, null: false
    field :post, PostType, null: false
  end
end
