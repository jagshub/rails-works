# frozen_string_literal: true

class Graph::Resolvers::FounderClub::IsClaimedResolver < Graph::Resolvers::Base
  type Boolean, null: false

  def resolve
    return false if current_user.blank?

    IsClaimedLoader.for(current_user).load(object)
  end

  class IsClaimedLoader < GraphQL::Batch::Loader
    def initialize(user)
      @user = user
    end

    def perform(deals)
      claimed_deals_ids = @user.founder_club_claims.where(deal_id: deals.map(&:id)).pluck(:deal_id)

      deals.each do |deal|
        fulfill deal, claimed_deals_ids.include?(deal.id)
      end
    end
  end
end
