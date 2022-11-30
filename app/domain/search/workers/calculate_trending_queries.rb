# frozen_string_literal: true

class Search::Workers::CalculateTrendingQueries < ApplicationJob
  def perform
    Search::Trending.calculate_queries
  end
end
