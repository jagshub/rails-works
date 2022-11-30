# frozen_string_literal: true

class Graph::Resolvers::IsMakerResolver < Graph::Resolvers::Base
  type Boolean, null: false

  def resolve
    return false if current_user.blank?

    Loader.for(current_user).load(object)
  end

  class Loader < GraphQL::Batch::Loader
    def initialize(user)
      @user = user
    end

    def perform(posts)
      made_product_ids =
        ProductMaker
        .where(post: posts, user: @user)
        .pluck(:post_id)

      posts.each do |post|
        fulfill post, made_product_ids.include?(post.id)
      end
    end
  end
end
