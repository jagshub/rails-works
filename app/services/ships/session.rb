# frozen_string_literal: true

module Ships
  module Session
    extend self

    def call(user:, ship_lead:, visitor_id: nil)
      user.update!(confirmed_age: true)

      return if ship_lead.nil?

      Ships::Tracking.record(
        user: user,
        visitor_id: visitor_id,
        funnel_step: Ships::Tracking::LOGIN,
        event_name: Ships::Tracking::COMPLETE,
      )

      ship_lead.update(user: user, status: :user) if ship_lead.user.nil?
    end
  end
end
