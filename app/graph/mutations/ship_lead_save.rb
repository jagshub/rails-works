# frozen_string_literal: true

module Graph::Mutations
  class ShipLeadSave < BaseMutation
    argument :email, String, required: false
    argument :ship_instant_access_page_id, ID, required: false

    returns Graph::Types::ShipLeadType

    def perform(inputs)
      form = ::Ships::SaveLeadForm.new(user: current_user, inputs: inputs)
      form.update inputs

      Ships::Leads.save_to_context(context, form.ship_lead)

      form
    end
  end
end
