# frozen_string_literal: true

module Ships::Leads
  extend self

  COOKIE_NAME = 'SHIP_LEAD_ID'

  def from_context(context)
    id = context[:cookies]['SHIP_LEAD_ID']

    return if id.blank?

    ShipLead.find_by(id: id)
  end

  def save_to_context(context, lead)
    context[:cookies]['SHIP_LEAD_ID'] = lead.id if lead&.id.present?
  end
end
