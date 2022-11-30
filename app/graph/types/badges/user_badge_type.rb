# frozen_string_literal: true

module Graph::Types
  class Badges::UserBadgeType < BaseObject
    graphql_name 'UserBadge'

    class StatusEnum < BaseEnum
      graphql_name 'UserBadgeStatus'

      value 'in_progress'
      value 'awarded_to_user_and_visible'

      # NOTE(DZ): `locked_and_hidden_by_admin` is not part of `visible` scope.
      # It should be hidden from all badge fields
    end

    field :id, ID, null: false
    field :award, Badges::AwardType, null: false
    field :status, StatusEnum, null: false
    field :showcased, Boolean, null: false
    field :updated_at, DateType, null: false
    field :progress_requirement, Int, null: true
    field :badge_progress, Int, null: true
    field :viewer_is_owner, Boolean, null: false
    field :linked_post, Graph::Types::PostType, null: true

    def progress_requirement
      UserBadges.award_for(identifier: object.identifier).progress_requirement
    end

    def viewer_is_owner
      return false if context[:current_user].blank?

      context[:current_user].id == object.subject_id.to_i
    end

    def linked_post
      Graph::Common::BatchLoaders::BadgeLinkedPost.for.load(object)
    end
  end
end
