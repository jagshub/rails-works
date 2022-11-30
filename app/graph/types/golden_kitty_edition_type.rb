# frozen_string_literal: true

module Graph::Types
  class GoldenKittyEditionType < BaseNode
    implements Graph::Types::SubscribableInterfaceType
    implements Graph::Types::SeoInterfaceType

    field :year, Int, null: false
    field :categories, [Graph::Types::GoldenKittyCategoryType], null: false
    field :sponsors, [Graph::Types::GoldenKittySponsorType], null: false
    field :social_text, String, null: true
    field :results_url, String, null: true
    field :live_event_url, String, null: true
    field :results_description, String, null: true
    field :result_at, Graph::Types::DateTimeType, null: false
    field :nomination_ends_at, Graph::Types::DateTimeType, null: false
    field :voting_starts_at, Graph::Types::DateTimeType, null: false
    field :voting_ends_at, Graph::Types::DateTimeType, null: false
    field :live_event_at, Graph::Types::DateTimeType, null: true
    field :total_categories_for_nomination, Int, null: false
    field :first_category_for_nomination, Graph::Types::GoldenKittyCategoryType, null: true
    field :first_category_for_voting, Graph::Types::GoldenKittyCategoryType, null: true

    field :phase, String, null: false do
      argument :preview_for, String, required: false
    end

    def categories
      object.categories.order(:priority, :name)
    end

    def phase(preview_for: nil)
      object.phase(preview_for, context[:current_user])
    end

    def social_text
      GoldenKitty.social_text_for_edition(object)
    end

    def live_event_url
      GoldenKitty.live_event_url
    end

    def total_categories_for_nomination
      GoldenKitty.total_categories_for_nomination(object)
    end

    def first_category_for_nomination
      GoldenKitty.first_category_for_nomination(edition: object, user: context[:current_user])
    end

    def first_category_for_voting
      GoldenKitty.first_category_for_voting(edition: object, user: context[:current_user])
    end
  end
end
