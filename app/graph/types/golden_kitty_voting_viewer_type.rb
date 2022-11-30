# frozen_string_literal: true

module Graph::Types
  class GoldenKittyVotingViewerType < BaseObject
    graphql_name 'GoldenKittyVotingViewer'

    field :id, ID, null: false
    field :emoji, String, null: false
    field :name, String, null: false
    field :slug, String, null: false
    field :tagline, String, null: false
    field :social_image_uuid, String, null: true
    field :finalists, [Graph::Types::GoldenKittyFinalistType], null: false
    field :sponsor, Graph::Types::GoldenKittySponsorType, null: true
    field :people, [Graph::Types::GoldenKittyPersonType], null: false
    field :previous_category, Graph::Types::GoldenKittyVotingViewerType, null: true
    field :next_category, Graph::Types::GoldenKittyVotingViewerType, null: true
    field :index, Int, null: false
    field :total, Int, null: false
    field :voting_ended, Boolean, null: false
    field :fact, Graph::Types::GoldenKittyFact, null: true

    def index
      GoldenKitty::Category.with_voting_for_year(object.year).pluck(:id).index(object.id)
    end

    def total
      GoldenKitty::Category.with_voting_for_year(object.year).count
    end

    def voting_ended
      ::GoldenKitty::Utils.voting_ended?
    end

    def fact
      object.facts.by_random.first
    end

    def previous_category
      object.previous_voting_category
    end

    def next_category
      object.next_voting_category
    end
  end
end
