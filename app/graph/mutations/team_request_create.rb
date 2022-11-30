# frozen_string_literal: true

module Graph::Mutations
  class TeamRequestCreate < BaseMutation
    argument_record :product, Product
    argument :team_email, String, required: true
    argument :additional_info, String, required: false

    returns Graph::Types::Team::RequestType
    require_current_user

    def perform(product:, team_email:, additional_info: nil)
      Teams.request_create(
        product: product,
        user: current_user,
        team_email: team_email,
        additional_info: additional_info,
      )
    end
  end
end
