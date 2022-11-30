# frozen_string_literal: true

class UpcomingPages::Defaults::ShipLeadProvider < UpcomingPages::Defaults::BaseProvider
  attr_reader :lead

  def initialize(lead)
    @lead = lead
  end

  def name
    @lead.project_name
  end

  def tagline
    @lead.project_tagline
  end

  def template_name
    @lead.signup_design
  end
end
