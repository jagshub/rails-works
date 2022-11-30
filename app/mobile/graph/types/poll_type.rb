# frozen_string_literal: true

module Mobile::Graph::Types
  class PollType < BaseObject
    field :id, ID, null: false

    association :options, [PollOptionType], null: false, preload: :ordered_options

    field :options_count, Integer, null: false
    field :answers_count, Integer, null: false
    field :has_answered, resolver: Mobile::Graph::Resolvers::HasAnsweredPoll
  end
end
