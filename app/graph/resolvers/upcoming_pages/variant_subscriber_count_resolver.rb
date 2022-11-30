# frozen_string_literal: true

class Graph::Resolvers::UpcomingPages::VariantSubscriberCountResolver < Graph::Resolvers::Base
  type Int, null: false

  def resolve
    return 0 unless ApplicationPolicy.can?(current_user, ApplicationPolicy::MAINTAIN, object)

    object.subscribers.count
  end
end
