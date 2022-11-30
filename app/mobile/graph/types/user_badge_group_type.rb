# frozen_string_literal: true

module Mobile::Graph::Types
  class UserBadgeGroupType < BaseObject
    graphql_name 'UserBadgeGroup'

    field :award_kind, UserBadgeAwardKindType, null: false
    field :award, UserBadgeAwardType, null: false
    field :badges_count, Int, null: false
  end
end
