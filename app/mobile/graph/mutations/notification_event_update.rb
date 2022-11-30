# frozen_string_literal: true

module Mobile::Graph::Mutations
  class NotificationEventUpdate < BaseMutation
    argument_record :notification, NotificationEvent

    returns Boolean

    require_current_user

    def perform(inputs)
      event = inputs[:notification]
      return { node: true } if event.interacted_at.present?

      event.update! interacted_at: Time.current
      { node: true }
    end
  end
end
