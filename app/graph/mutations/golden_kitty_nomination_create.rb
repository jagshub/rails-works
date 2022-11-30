# frozen_string_literal: true

module Graph::Mutations
  class GoldenKittyNominationCreate < BaseMutation
    argument_record :post, Post, required: true
    argument_record :category, ::GoldenKitty::Category, required: true

    returns Graph::Types::GoldenKittyNomineeType
    field :golden_kitty_nomination_category, Graph::Types::GoldenKittyCategoryType, null: true

    require_current_user

    def perform(post:, category:)
      return error :category_id, 'nomination has ended' if category.phase != :nomination

      launched_in = post.featured_at&.year || post.created_at.year

      return error :post_id, "nominated product should've been launched in #{ category.edition.year }" if launched_in != category.edition.year

      nomination = category.nominees.create!(
        user: current_user,
        post: post,
      )

      { node: nomination, golden_kitty_nomination_category: category }
    end
  end
end
