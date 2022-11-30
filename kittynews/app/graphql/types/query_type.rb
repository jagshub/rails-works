module Types
  class QueryType < Types::BaseObject
    field :posts_all, [PostType], null: false
    field :viewer, ViewerType, null: true
    field :post_detail, PostDetailType, null: false do
      argument :post_id, Integer, required: true
    end
    field :posts_vote, [VoteType], null: false do
      argument :post_id, ID, required: true
    end
    field :posts_vote_count, TotalType, null: true do
      argument :post_id, Integer, required: true
    end

    def posts_all
      Post.reverse_chronological.all
    end

    def viewer
      context.current_user
    end

    def post_detail(post_id:)
      Post.includes(votes: [:user], comments: [:user]).find_by_id(post_id)
    end

    def posts_vote(post_id:)
      Post.find_by_id(post_id).votes
    end

    def posts_vote_count(post_id:)
      {:total => Post.find_by_id(post_id).votes.size}
    end
  end
end
