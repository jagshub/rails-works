# frozen_string_literal: true

module Graph::Types
  class OnboardingTypeEnum < BaseEnum
    Onboarding.names.each do |k, v|
      value k, v
    end
  end
end
