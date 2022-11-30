# frozen_string_literal: true

module Graph::Types
  class ShipLeadType < BaseObject
    graphql_name 'ShipLead'

    field :id, ID, null: false
    field :name, String, null: true
    field :project_name, String, null: true
    field :project_tagline, String, null: true
    field :project_phase, String, null: true
    field :launch_period, String, null: true
    field :signup_goal, String, null: true
    field :signup_design, String, null: true
    field :incorporated, Boolean, null: true
    field :request_stripe_atlas, Boolean, null: true
    field :team_size, String, null: true
    field :user, Graph::Types::UserType, null: true
    field :ship_instant_access_page, Graph::Types::ShipInstantAccessPageType, null: true
  end
end
