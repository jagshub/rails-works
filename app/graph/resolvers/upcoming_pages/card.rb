# frozen_string_literal: true

class Graph::Resolvers::UpcomingPages::Card < Graph::Resolvers::Base
  type Graph::Types::UpcomingPagesCardType, null: false

  def resolve
    UpcomingPagesData.new(current_user: current_user)
  end

  class UpcomingPagesData < OpenStruct
    def upcoming_pages
      @upcoming_pages ||= begin
        exclude_ids = UpcomingPages::UserSubscriptions.call(current_user)
        UpcomingPage.for_listing.where.not(id: exclude_ids).by_random.limit(3).to_a
      end
    end
  end
end
