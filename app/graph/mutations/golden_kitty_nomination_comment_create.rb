# frozen_string_literal: true

module Graph::Mutations
  class GoldenKittyNominationCommentCreate < BaseMutation
    argument_record :nomination, ::GoldenKitty::Nominee, required: true, authorize: :create_comment
    argument :comment, String, required: false

    returns Graph::Types::GoldenKittyNomineeType
    field :golden_kitty_nomination_category, Graph::Types::GoldenKittyCategoryType, null: true

    require_current_user

    def perform(nomination:, comment: nil)
      return error :id, 'nomination has ended' if ::GoldenKitty::Utils.nomination_ended?

      category = nomination.golden_kitty_category

      nomination.update! comment: comment.present? ? Nokogiri::HTML(comment.strip).text : ''

      { node: nomination, golden_kitty_nomination_category: category }
    end
  end
end
