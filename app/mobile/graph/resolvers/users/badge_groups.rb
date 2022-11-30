# frozen_string_literal: true

class Mobile::Graph::Resolvers::Users::BadgeGroups < Mobile::Graph::Resolvers::BaseResolver
  type [Mobile::Graph::Types::UserBadgeGroupType], null: false

  def resolve
    groups = object
             .badges
             .complete
             .not_showcased
             .group("data->'identifier'")
             .count

    groups.map do |identifier, group_count|
      BadgeGroup.new(
        award_kind: identifier,
        award: Graph::Common::BatchLoaders::BadgeAward.for.load(identifier),
        badges_count: group_count,
      ).to_struct
    end
  end

  class BadgeGroup
    def initialize(args = {})
      @award_kind = args[:award_kind]
      @award = args[:award]
      @badges_count = args[:badges_count]
    end

    def to_struct
      OpenStruct.new(
        award_kind: @award_kind,
        award: @award,
        badges_count: @badges_count,
      )
    end
  end
end
