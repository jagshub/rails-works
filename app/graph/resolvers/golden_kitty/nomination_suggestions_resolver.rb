# frozen_string_literal: true

class Graph::Resolvers::GoldenKitty::NominationSuggestionsResolver < Graph::Resolvers::BaseSearch
  scope { GoldenKitty.nomination_suggestions_for_user(category: object, user: current_user) }
end
