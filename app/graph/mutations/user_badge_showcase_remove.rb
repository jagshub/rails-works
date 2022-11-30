# frozen_string_literal: true

module Graph::Mutations
  class UserBadgeShowcaseRemove < BaseMutation
    argument_record :badge, Badges::UserAwardBadge, authorize: :showcase

    require_current_user
    returns Graph::Types::Badges::UserBadgeType

    def perform(badge:)
      badge.update!(data: badge.data.merge(
        showcased: false,
      ))
      badge
    end
  end
end
