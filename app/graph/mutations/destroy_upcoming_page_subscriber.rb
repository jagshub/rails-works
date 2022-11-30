# frozen_string_literal: true

module Graph::Mutations
  class DestroyUpcomingPageSubscriber < BaseMutation
    argument :token, String, required: false
    argument :upcoming_page_id, ID, required: false
    argument :upcoming_page_subscriber_id, ID, required: false

    returns Graph::Types::UpcomingPageSubscriberType

    def perform(inputs)
      subscriber = find_subscriber(inputs)
      return error :subscriber, :blank if subscriber.blank?

      Ships::Contacts::UnsubscribeSubscriber.call(subscriber, source: source(inputs))
      subscriber
    end

    private

    def source(inputs)
      inputs[:upcoming_page_subscriber_id] ? 'maker' : 'manual'
    end

    def find_subscriber(inputs)
      if inputs[:token]
        UpcomingPageSubscriber.find_by(
          upcoming_page_id: inputs[:upcoming_page_id],
          token: inputs[:token],
        )
      elsif inputs[:upcoming_page_id] && current_user
        UpcomingPageSubscriber.for_user(current_user.id).find_by(upcoming_page_id: inputs[:upcoming_page_id])
      elsif inputs[:upcoming_page_subscriber_id] && current_user
        find_subscriber_by_id inputs[:upcoming_page_subscriber_id]
      end
    end

    def find_subscriber_by_id(id)
      subscriber = UpcomingPageSubscriber.find_by id: id
      ApplicationPolicy.authorize!(current_user, :destroy, subscriber) if subscriber
      subscriber
    end
  end
end
