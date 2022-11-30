# frozen_string_literal: true

class Ships::SaveLeadForm
  include MiniForm::Model

  ATTRIBUTES = %i(
    email
    launch_period
    name
    project_name
    project_phase
    project_tagline
    team_size
    signup_goal
    signup_design
    incorporated
    request_stripe_atlas
  ).freeze

  model :ship_lead, attributes: ATTRIBUTES, save: true

  attributes :age_confirmed, :tos_confirmed, :validate_details

  validates :name, presence: true, if: :validate_details?
  validates :project_name, presence: true, if: :validate_details?
  validates :age_confirmed, presence: true, if: :validate_details?
  validates :tos_confirmed, presence: true, if: :validate_details?

  after_update :deliver_notification

  alias node ship_lead
  alias graphql_result ship_lead
  alias validate_details? validate_details

  def initialize(user:, inputs:)
    @user = user
    @ship_lead = find_or_initialize(inputs)
    @existing_lead = @ship_lead.persisted?
  end

  private

  def find_or_initialize(inputs)
    lead = ShipLead.find_by(id: inputs[:id])
    lead ||= ShipLead.find_by(user: @user) if @user.present?
    lead ||= ShipLead.find_by(email: inputs[:email]) || ShipLead.new(user: @user, email: inputs[:email])

    lead.ship_instant_access_page ||= ShipInstantAccessPage.find_by(id: inputs[:ship_instant_access_page_id])
    lead
  end

  def deliver_notification
    return if @existing_lead

    Ships::Slack::ShipLead.call(@ship_lead)
  end
end
