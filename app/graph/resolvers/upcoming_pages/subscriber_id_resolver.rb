# frozen_string_literal: true

module Graph::Resolvers
  class UpcomingPages::SubscriberIdResolver < Graph::Resolvers::Base
    type ID, null: true

    argument :upcoming_page_subscriber_id, ID, required: false

    def resolve(upcoming_page_subscriber_id: nil)
      upcoming_page = object

      if current_user.present?
        upcoming_page.subscribers.for_user(current_user.id).first&.id
      elsif upcoming_page_subscriber_id.present?
        upcoming_page.subscribers.find_by(id: upcoming_page_subscriber_id)&.id
      end
    end
  end
end
