# frozen_string_literal: true

module Graph::Types
  class FounderClubPlanType < BaseObject
    field :plan, Graph::Types::Payment::PlanType, null: true
    field :discount, Graph::Types::Payment::DiscountType, null: true
  end
end
