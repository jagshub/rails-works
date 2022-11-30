# frozen_string_literal: true

module API::V2Internal::Types
  class Poll::PollType < BaseObject
    field :id, ID, null: false
    association :options, [API::V2Internal::Types::Poll::PollOptionType], null: false, preload: :ordered_options
    field :options_count, Integer, null: false
    field :answers_count, Integer, null: false
    field :has_answered, Boolean, null: false, resolver: API::V2Internal::Resolvers::Polls::HasAnsweredPollResolver
  end
end
