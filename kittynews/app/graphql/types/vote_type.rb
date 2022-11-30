module Types
  class VoteType < Types::BaseObject
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :user, UserType, null: false
    field :post, PostType, null: false
  end
end
