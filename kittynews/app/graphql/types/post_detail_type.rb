module Types
  class PostDetailType < Types::BaseObject
    field :id, ID, null: false
    field :title, String, null: false
    field :tagline, String, null: false
    field :url, String, null: false
    field :user, UserType, null: false
    field :votes, [Types::VoteType], null: false
    field :comments, [Types::CommentType], null: false, resolver: Queries::CommentsSorted
    field :comments_count, Int, null: false
    field :votes_count, Int, null: false
  end
end
