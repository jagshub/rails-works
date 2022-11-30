# frozen_string_literal: true

class Graph::Resolvers::Ships::Contacts::ById < Graph::Resolvers::Base
  argument :id, ID, required: false

  type Graph::Types::ShipContactType, null: true

  def resolve(id: nil)
    contact = ShipContact.find_by id: id

    return if contact.nil?
    return if contact.trashed?
    return unless ApplicationPolicy.can?(current_user, ApplicationPolicy::MAINTAIN, contact)

    contact
  end
end
