# frozen_string_literal: true

class Ships::Slack::ShipLead < Ships::Slack::Notification
  attr_reader :ship_lead

  class << self
    def call(ship_lead)
      new(ship_lead).deliver
    end
  end

  def initialize(ship_lead)
    @ship_lead = ship_lead
  end

  private

  def channel
    'ship_activity'
  end

  def author
    @author = @author || ship_lead.user || ProductHunt.user
  end

  def title
    'A new lead has entered the onboarding funnel'
  end

  def title_link
    "https://www.producthunt.com/admin/ship_leads/#{ ship_lead.id }"
  end

  def fields
    [
      { title: 'Email', value: ship_lead.email, short: true },
      { title: 'User ID', value: ship_lead.user&.id, short: true },
      { title: 'Username', value: ship_lead.user&.username, short: true },
      { title: 'Source', value: ship_lead.user&.ship_instant_access_page&.slug, short: true },
    ]
  end

  def icon_emoji
    ':eyes:'
  end

  def color
    '#d8c7a6'
  end
end
