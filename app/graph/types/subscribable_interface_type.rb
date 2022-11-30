# frozen_string_literal: true

module Graph::Types
  module SubscribableInterfaceType
    include Graph::Types::BaseInterface

    graphql_name 'Subscribable'

    field :id, ID, null: false
    field :is_subscribed, Boolean, resolver: Graph::Resolvers::IsSubscribed, null: false
    field :is_muted, Boolean, resolver: Graph::Resolvers::IsSubscriptionMuted, null: false
  end
end
