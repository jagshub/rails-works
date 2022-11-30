# frozen_string_literal: true

module Graph::Mutations
  class VisitStreakUpdate < BaseMutation
    returns Graph::Types::ViewerType

    require_current_user

    def perform
      ::UserVisitStreak.mark_visit(current_user, platform: 'web')

      current_user
    end
  end
end
