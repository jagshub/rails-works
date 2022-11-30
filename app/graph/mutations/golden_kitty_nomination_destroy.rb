# frozen_string_literal: true

module Graph::Mutations
  class GoldenKittyNominationDestroy < BaseMutation
    argument_record :nomination, ::GoldenKitty::Nominee, required: true, authorize: :destroy

    returns Graph::Types::GoldenKittyNomineeType
    field :golden_kitty_nomination_category, Graph::Types::GoldenKittyCategoryType, null: true

    require_current_user

    def perform(nomination:)
      return error :id, 'nomination has ended' if nomination.golden_kitty_category.phase != :nomination

      category = nomination.golden_kitty_category
      nomination.destroy

      { node: nomination, golden_kitty_nomination_category: category }
    end
  end
end
