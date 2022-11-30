# frozen_string_literal: true

module Graph::Mutations
  class ShipTrackEventCreate < BaseMutation
    argument :funnel_step, String, required: true
    argument :event_name, String, required: true
    argument :utm_source, String, required: false
    argument :utm_campaign, String, required: false
    argument :utm_medium, String, required: false
    argument :promo_code, String, required: false
    argument :landing_page, String, required: false
    argument :path, String, required: false
    argument :fields, [String], required: false

    def perform(inputs)
      Ships::Tracking.record(
        visitor_id: context[:cookies][:visitor_id],
        user: current_user,
        funnel_step: inputs[:funnel_step],
        event_name: inputs[:event_name],
        meta: {
          utm_source: inputs[:utm_source],
          utm_campaign: inputs[:utm_campaign],
          utm_medium: inputs[:utm_medium],
          promo_code: inputs[:promo_code],
          path: inputs[:path],
          fields: inputs[:fields],
          landing_page: inputs[:landing_page],
        },
      )

      success
    end
  end
end
