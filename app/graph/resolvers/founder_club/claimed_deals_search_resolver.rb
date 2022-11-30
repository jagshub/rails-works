# frozen_string_literal: true

class Graph::Resolvers::FounderClub::ClaimedDealsSearchResolver < Graph::Resolvers::BaseSearch
  scope { (current_user.present? && current_user.founder_club_deals.order(created_at: :desc)) || [] }
end
