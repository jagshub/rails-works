# frozen_string_literal: true

module Graph::Types
  class UpcomingPageSubscriberFilterType < BaseObject
    graphql_name 'UpcomingPageSubscriberFilter'

    field :type, String, null: false
    field :value, String, null: false
  end
end
