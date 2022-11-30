# frozen_string_literal: true

module Graph::Types
  class MakersFestival::CategoryType < BaseNode
    graphql_name 'MakersFestivalCategory'

    field :emoji, String, null: false
    field :name, String, null: false
    field :tagline, String, null: false
    field :finalists, [Graph::Types::MakersFestival::ParticipantType], null: false

    def finalists
      FinalistsLoader.for.load(object)
    end

    class FinalistsLoader < GraphQL::Batch::Loader
      def perform(categories)
        participants = ::MakersFestival::Participant.where(finalist: true, makers_festival_category_id: categories).group_by(&:makers_festival_category_id)

        categories.each do |category|
          fulfill category, participants[category.id] || []
        end
      end
    end
  end
end
