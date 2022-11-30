# frozen_string_literal: true

class Graph::Resolvers::Radio::Sponsor < Graph::Resolvers::Base
  type [Graph::Types::Radio::SponsorType], null: false

  def resolve
    ::Radio::Sponsor.active.order(:id)
  end
end
