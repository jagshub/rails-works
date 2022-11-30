# frozen_string_literal: true

module Graph::Types
  class UpcomingPageConversationMessageType < BaseObject
    graphql_name 'UpcomingPageConversationMessage'

    extend Graph::Utils::AuthorizeRead

    field :id, ID, null: false
    field :body, String, null: false
    field :user, Graph::Types::UserType, null: true
    field :subscriber, Graph::Types::UpcomingPageSubscriberType, null: true
    field :created_at, Graph::Types::DateTimeType, null: false
    field :delivery, Graph::Types::UpcomingPageMessageDeliveryType, null: true

    def body
      BetterFormatter.call(object.body, mode: :full)
    end

    association(:original_text, String, null: true, preload: :upcoming_page_email_reply, method: ->(record, _obj) { record.payload['Text-part'] if record })
    association(:original_html, String, null: true, preload: :upcoming_page_email_reply, method: ->(record, _obj) { record.payload['Html-part'] if record })
  end
end
