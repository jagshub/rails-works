# frozen_string_literal: true

class Graph::Resolvers::Products::FindToReviewResolver < Graph::Resolvers::Base
  def resolve
    return if current_user.blank?

    Reviews::SuggestedProducts.new(user_id: current_user.id)
  end
end
