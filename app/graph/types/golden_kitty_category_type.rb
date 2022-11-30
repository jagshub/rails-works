# frozen_string_literal: true

module Graph::Types
  class GoldenKittyCategoryType < BaseNode
    implements Graph::Types::SeoInterfaceType

    class IconKindType < BaseEnum
      graphql_name 'GoldenKittyCategoryIconEnum'

      value 'icon'
      value 'emoji'
    end

    class IconType < BaseObject
      graphql_name 'GoldenKittyCategoryIconType'

      field :kind, IconKindType, null: false
      field :value, String, null: false
    end

    field :icon, IconType, null: false
    field :icon_uuid, String, null: true
    field :emoji, String, null: true
    field :name, String, null: false
    field :slug, String, null: false
    field :tagline, String, null: false
    field :phase, String, null: false

    field :nomination_index, Int, null: false
    field :next_category_for_nomination, Graph::Types::GoldenKittyCategoryType, null: true
    field :prev_category_for_nomination, Graph::Types::GoldenKittyCategoryType, null: true
    field :nominations, [Graph::Types::GoldenKittyNomineeType], null: false
    field :nomination_suggestions,
          Graph::Types::PostType.connection_type,
          connection: true,
          max_page_size: 4,
          resolver: Graph::Resolvers::GoldenKitty::NominationSuggestionsResolver, null: false

    field :voting_enabled_at, Graph::Types::DateTimeType, null: true
    field :finalists, [Graph::Types::GoldenKittyFinalistType], null: false
    field :voting, Graph::Types::GoldenKittyCategoryVotingType, null: true
    field :is_people_category, Boolean, null: false, method: :people_category?

    field :winners, [Graph::Types::GoldenKittyWinnerType], null: false do
      argument :limit, Int, required: false
    end

    def winners(limit: 3)
      object.winners.limit(limit)
    end

    def phase
      object.phase(context[:current_user])
    end

    def nomination_index
      GoldenKitty.nomination_category_index(object)
    end

    def next_category_for_nomination
      GoldenKitty.next_category_for_nomination(object)
    end

    def prev_category_for_nomination
      GoldenKitty.prev_category_for_nomination(object)
    end

    def nominations
      return [] if context[:current_user].blank?

      GoldenKitty.nominations_for_category_by_user(category: object, user: context[:current_user])
    end

    def voting
      GoldenKitty.voting_for_category(category: object, user: context[:current_user])
    end

    def icon
      kind, value = if object.icon_uuid.present?
                      ['icon', object.icon_uuid]
                    else
                      ['emoji', object.emoji]
                    end

      OpenStruct.new(
        kind: kind,
        value: value,
      )
    end
  end
end
