# frozen_string_literal: true

module Graph::Mutations
  class ShipLeadUpdate < BaseMutation
    argument :id, ID, required: false
    argument :name, String, required: false
    argument :email, String, required: false
    argument :project_name, String, required: false
    argument :project_tagline, String, required: false
    argument :project_phase, String, required: false
    argument :launch_period, String, required: false
    argument :team_size, String, required: false
    argument :age_confirmed, Boolean, required: false
    argument :tos_confirmed, Boolean, required: false
    argument :signup_goal, String, required: false
    argument :signup_design, String, required: false
    argument :incorporated, Boolean, required: false
    argument :request_stripe_atlas, Boolean, required: false
    argument :step, String, required: false

    returns Graph::Types::ShipLeadType

    def perform(inputs)
      form = ::Ships::SaveLeadForm.new(user: current_user, inputs: inputs)
      form.validate_details = inputs[:step] == 'details'
      form.update inputs

      Ships::Leads.save_to_context(context, form.ship_lead)

      form
    end
  end
end
