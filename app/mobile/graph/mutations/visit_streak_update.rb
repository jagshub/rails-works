# frozen_string_literal: true

module Mobile::Graph::Mutations
  class VisitStreakUpdate < BaseMutation
    require_current_user

    returns Mobile::Graph::Types::StreakType

    class PlatformEnumType < Graph::Types::BaseEnum
      value 'ios'
      value 'android'
    end

    argument :platform, PlatformEnumType, required: false

    def perform(platform: nil)
      ::UserVisitStreak.mark_visit(current_user, platform: platform)

      { node: ::UserVisitStreak.streak_info(current_user) }
    end
  end
end
