# frozen_string_literal: true

module Graph::Mutations
  class GoldenKittyNominationsCreate < BaseMutation
    class GoldenKittyNominationInputType < Graph::Types::BaseInputObject
      graphql_name 'GoldenKittyNominationInput'

      argument :post_id, ID, required: true
      argument :comment, String, required: false
    end

    argument :nominations, [GoldenKittyNominationInputType], required: true
    argument_record :category, ::GoldenKitty::Category, required: true

    require_current_user

    field :success, Boolean, null: false

    def perform(nominations:, category:)
      return error :category_id, 'nomination has ended' if category.phase != :nomination

      ActiveRecord::Base.transaction do
        Array(nominations).each { |nomination| create_nomination(nomination, category) }
      end

      { success: true }
    end

    private

    def create_nomination(nomination_input, category)
      post = Post.find(nomination_input[:post_id])
      comment = nomination_input[:comment]

      category.nominees.where(user: current_user, post: post).first_or_create!(
        user: current_user,
        post: post,
      ).update!(comment: comment.present? ? Nokogiri::HTML(comment.strip).text : '')
    end
  end
end
