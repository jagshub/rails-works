# frozen_string_literal: true

module Ships::Tracking
  extend self

  LANDING = 'landing'
  SIGNUP = 'signup'
  LOGIN = 'login'
  GOAL = 'goal'
  DESIGN = 'design'
  TRIAL = 'trial'
  CANCEL = 'cancel'
  SUBSCRIPTION = 'subscription'

  ENTER = 'enter'
  ERROR = 'error'
  COMPLETE = 'complete'
  UPGRADE = 'upgrade'
  DOWNGRADE = 'downgrade'

  PROMO_CODE = 'promo_code'

  def record(user: nil, visitor_id: nil, funnel_step:, event_name: ENTER, meta: {})
    meta.compact!

    identity = find_or_create_identity(user: user, visitor_id: visitor_id)

    enrich(identity, meta)

    ShipTrackingEvent.create!(
      identity: identity,
      funnel_step: funnel_step,
      event_name: event_name,
      meta: meta,
    )
  end

  private

  def find_or_create_identity(user:, visitor_id:)
    HandleRaceCondition.call do
      identity = find_identy_for_visitor_id(visitor_id, user: user) if visitor_id
      identity = find_identy_for_user(user, visitor_id: visitor_id) if user && identity.nil?
      identity || ShipTrackingIdentity.create!(visitor_id: visitor_id, user: user)
    end
  end

  def find_identy_for_visitor_id(visitor_id, user:)
    identity = ShipTrackingIdentity.find_by(visitor_id: visitor_id)
    identity.update! user: user if identity && user && identity.user != user
    identity
  end

  def find_identy_for_user(user, visitor_id:)
    identity = visitor_id ? ShipTrackingIdentity.find_by(user_id: user.id, visitor_id: nil) : ShipTrackingIdentity.find_by(user_id: user.id)
    identity&.update! visitor_id: visitor_id
    identity
  end

  def enrich(identity, meta)
    updates = {}
    updates.merge!(extract_campain(meta).compact) unless identity.source? || identity.campaign?
    updates.merge!(extract_landing_page(meta).compact) unless identity.landing_page?
    identity.update!(updates) unless updates.empty?
  end

  def extract_campain(meta)
    if meta[:promo_code]
      {
        source: PROMO_CODE,
        campaign: meta[:promo_code],
      }
    else
      {
        source: meta[:utm_source],
        campaign: meta[:utm_campaign],
        medium: meta[:utm_medium],
      }
    end
  end

  def extract_landing_page(meta)
    {
      landing_page: meta[:landing_page],
    }
  end
end
