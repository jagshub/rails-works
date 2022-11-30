# frozen_string_literal: true

module Graph::Types
  class OnboardingTaskType < BaseObject
    class ProgressType < BaseObject
      field :current, Int, null: false
      field :goal, Int, null: false
    end

    field :id, ID, null: false
    field :emoji, String, null: false
    field :title, String, null: false
    field :description, String, null: false
    field :completed, Boolean, null: false
    field :progress, ProgressType, null: true
    field :url, String, null: false
  end
end
