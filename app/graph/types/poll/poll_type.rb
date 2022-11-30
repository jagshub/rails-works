# frozen_string_literal: true

module Graph::Types
  class Poll::PollType < BaseObject
    field :id, ID, null: false

    association :options, [Poll::PollOptionType], null: false, preload: :ordered_options

    field :options_count, Integer, null: false
    field :answers_count, Integer, null: false
    field :has_answered, Boolean, null: false, resolver: Graph::Resolvers::Polls::HasAnsweredPollResolver
  end
end
