# frozen_string_literal: true

class Graph::Resolvers::Ships::Accounts::ById < Graph::Resolvers::Base
  argument :id, ID, required: false

  type Graph::Types::ShipAccountType, null: true

  def resolve(id: nil)
    account = ShipAccount.find_by id: id

    return unless account
    return unless ApplicationPolicy.can?(current_user, ApplicationPolicy::MAINTAIN, account)

    account
  end
end
