# frozen_string_literal: true

class Graph::Resolvers::UpcomingPages::Subscriber < Graph::Resolvers::Base
  type Graph::Types::UpcomingPageSubscriberType, null: true

  argument :id, ID, required: false

  def resolve(id:)
    return if current_user.blank?

    subscriber = UpcomingPageSubscriber.find_by(id: id)
    subscriber if subscriber.present? && ApplicationPolicy.can?(current_user, ApplicationPolicy::MAINTAIN, subscriber.upcoming_page)
  end
end
