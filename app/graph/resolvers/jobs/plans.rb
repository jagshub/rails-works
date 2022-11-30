# frozen_string_literal: true

class Graph::Resolvers::Jobs::Plans < Graph::Resolvers::Base
  class JobsPlanType < Graph::Types::BaseObject
    graphql_name 'JobsPlan'

    field :id, ID, null: false
    field :monthly_price, Int, null: false
    field :multiplier, Int, null: false
    field :discount_value, Int, null: false
    field :selected, Boolean, null: false
    field :description, String, null: false
    field :term, String, null: false
  end

  type [JobsPlanType], null: false

  argument :token, String, required: false

  def resolve(token: nil)
    discount_page = Job.find_by(token: token)&.discount_page if token

    already_selected = false
    ::Jobs::Plans.plans.map do |plan|
      discount_value = ::Jobs::DiscountPage.discount_value_for(discount_page, plan)
      selected = !discount_value.zero? && !already_selected
      already_selected = true if selected

      Plan.new(
        plan: plan,
        discount_value: discount_value,
        selected: selected,
      )
    end
  end

  class Plan
    attr_reader :discount_value, :selected

    delegate :id, :monthly_price, :multiplier, :description, :term, to: :plan

    def initialize(plan:, discount_value:, selected:)
      @plan = plan
      @discount_value = discount_value
      @selected = selected
    end

    private

    attr_reader :plan
  end
end
