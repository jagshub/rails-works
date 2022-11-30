# frozen_string_literal: true

module Mobile::Graph::Types
  class UserBadgeType < BaseNode
    graphql_name 'UserBadge'

    class StatusEnum < BaseEnum
      graphql_name 'UserBadgeStatus'

      value 'in_progress'
      value 'awarded_to_user_and_visible'
    end

    field :award, UserBadgeAwardType, null: false
    field :badge_progress, Int, null: true
    field :post, PostType, null: true
    field :progress_requirement, Int, null: true
    field :showcased, Boolean, null: false
    field :status, StatusEnum, null: false
    field :updated_at, DateType, null: false
    field :viewer_is_owner, Boolean, null: false

    def post
      return unless %w(gemologist top_product).include? object.identifier

      Post.find_by(id: object.data['for_post_id'])
    end

    def progress_requirement
      UserBadges.award_for(identifier: object.identifier).progress_requirement
    end

    def viewer_is_owner
      return false if current_user.blank?

      current_user.id == object.subject_id.to_i
    end
  end
end
