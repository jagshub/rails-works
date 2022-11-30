# frozen_string_literal: true

module Graph::Types
  class Badges::UserBadgeGroupType < BaseObject
    field :award_kind, Badges::UserBadgeAwardKindType, null: false
    field :award, Badges::UserBadgeAwardType, null: false
    field :badges_count, Int, null: false
  end
end
