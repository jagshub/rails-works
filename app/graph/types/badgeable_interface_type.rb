# frozen_string_literal: true

module Graph::Types
  module Graph::Types::BadgeableInterfaceType
    include Graph::Types::BaseInterface

    graphql_name 'Badgeable'

    field :id, ID, null: false

    field :badges,
          Graph::Types::BadgeType.connection_type,
          null: false,
          resolver: Graph::Resolvers::BadgesResolver,
          max_page_size: 200,
          connection: true

    field :badges_count, Int, null: false

    ALLOWED_BADGES = %w(Badges::TopPostBadge Badges::GoldenKittyAwardBadge).freeze

    def badges_count
      object.badges.where(type: ALLOWED_BADGES).count
    end
  end
end
