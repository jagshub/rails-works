# frozen_string_literal: true

module Onboardings::Create
  extend self

  def call(name:, user:)
    HandleRaceCondition.call do
      onboarding = user.onboardings.find_or_initialize_by name: name
      return if onboarding.completed?

      onboarding.status = 'completed'
      onboarding.save!
    end

    nil
  end
end
