# frozen_string_literal: true

module Mobile::Graph::Mutations
  class UserOnboardingUpdate < BaseMutation
    class OnboardingStatusEnumType < Mobile::Graph::Types::BaseEnum
      Onboarding.statuses.each do |k, _v|
        value k
      end
    end

    argument :status, OnboardingStatusEnumType, required: false
    argument :step, Integer, required: true

    require_current_user
    returns Mobile::Graph::Types::ViewerType

    def perform(step:, status: 'pending')
      onboarding = current_user.onboardings.find_or_initialize_by name: :mobile

      unless onboarding.completed?
        onboarding.update!(
          step: step,
          status: status,
        )
      end

      current_user.reload
    end
  end
end
