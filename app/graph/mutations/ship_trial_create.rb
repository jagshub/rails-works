# frozen_string_literal: true

module Graph::Mutations
  class ShipTrialCreate < BaseMutation
    argument :ship_instant_access_page_id, ID, required: false
    argument :billing_plan, String, required: true
    argument :billing_period, String, required: true

    returns Graph::Types::ShipSubscriptionType

    require_current_user

    def perform(inputs)
      subscription = ::Ships::CreateTrial.call(
        inputs: inputs,
        user: current_user,
      )

      ::Ships::Tracking.record(
        visitor_id: context[:cookies][:visitor_id],
        user: current_user,
        funnel_step: Ships::Tracking::TRIAL,
        event_name: Ships::Tracking::COMPLETE,
        meta: {
          billing_plan: inputs[:billing_plan],
          billing_period: inputs[:billing_period],
        },
      )

      subscription
    end
  end
end
