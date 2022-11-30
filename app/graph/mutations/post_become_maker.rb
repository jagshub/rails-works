# frozen_string_literal: true

module Graph::Mutations
  class PostBecomeMaker < BaseMutation
    argument_record :post, Post, authorize: :become_maker

    returns Graph::Types::PostType

    def perform(post:)
      return error :base, :access_denied if 1.week.ago > post.date

      result = ProductMakers.add(
        by: current_user,
        maker: ProductMakers::Maker.new(user: current_user, post: post),
      )

      if result
        post
      else
        error :base, "Can't become maker"
      end
    end
  end
end
