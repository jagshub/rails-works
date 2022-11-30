# frozen_string_literal: true

module Graph::Mutations
  class OnboardingUserReasonCreate < BaseMutation
    class OnboardingReasonsEnumType < Graph::Types::BaseEnum
      OnboardingReason.reasons.each do |k, v|
        value k, v
      end
    end

    argument :onboarding_reasons, [OnboardingReasonsEnumType], required: true

    require_current_user

    returns Graph::Types::ViewerType

    def perform(onboarding_reasons:)
      HandleRaceCondition.call(transaction: true) do
        current_user.onboarding_reasons.reload.destroy_all

        onboarding_reasons.each do |reason|
          current_user.onboarding_reasons.create!(reason: reason)
        end

        Iterable::SyncUserWorker.perform_later(user: current_user)
      end

      current_user
    end
  end
end
