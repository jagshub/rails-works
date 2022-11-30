# frozen_string_literal: true

module Graph::Types
  class Graph::Types::EmailDigestType < BaseObject
    graphql_name 'EmailDigest'

    field :is_subscribed, Boolean, null: false
  end
end
