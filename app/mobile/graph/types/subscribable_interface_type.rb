# frozen_string_literal: true

module Mobile::Graph::Types
  module SubscribableInterfaceType
    include Mobile::Graph::Types::BaseInterface

    graphql_name 'Subscribable'

    field :id, ID, null: false
    field :is_subscribed, Boolean, resolver: Mobile::Graph::Resolvers::IsSubscribed, null: false
    field :is_muted, Boolean, resolver: Mobile::Graph::Resolvers::IsSubscriptionMuted, null: false
  end
end
