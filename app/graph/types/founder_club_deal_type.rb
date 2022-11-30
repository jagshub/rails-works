# frozen_string_literal: true

module Graph::Types
  class FounderClubDealType < BaseNode
    field :title, String, null: false
    field :company_name, String, null: true
    field :logo_uuid, String, null: true
    field :logo_with_colors_uuid, String, null: true
    field :value, String, null: false
    field :summary, String, null: false
    field :details, String, null: false
    field :terms, String, null: false
    field :how_to_claim, String, null: false
    field :badges, [String], null: false
    field :is_claimed, resolver: Graph::Resolvers::FounderClub::IsClaimedResolver
  end
end
