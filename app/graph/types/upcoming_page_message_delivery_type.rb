# frozen_string_literal: true

module Graph::Types
  class UpcomingPageMessageDeliveryType < BaseObject
    graphql_name 'UpcomingPageMessageDelivery'

    extend Graph::Utils::AuthorizeRead

    field :id, ID, null: false
    field :sent_at, Graph::Types::DateTimeType, null: true
    field :opened_at, Graph::Types::DateTimeType, null: true
    field :clicked_at, Graph::Types::DateTimeType, null: true
    field :subscriber, Graph::Types::UpcomingPageSubscriberType, null: false

    association(:message, Graph::Types::UpcomingPageMessageType, null: true, preload: :subject, method: ->(subject, _obj) { subject.is_a?(UpcomingPageMessage) ? subject : nil })
  end
end
