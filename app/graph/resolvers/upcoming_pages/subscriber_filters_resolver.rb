# frozen_string_literal: true

class Graph::Resolvers::UpcomingPages::SubscriberFiltersResolver < Graph::Resolvers::Base
  type [Graph::Types::UpcomingPageSubscriberFilterType], null: false

  Filter = Struct.new(:type, :value)

  def resolve(path:)
    return [] unless ApplicationPolicy.can?(current_user, ApplicationPolicy::MAINTAIN, object)

    field_name = path.last
    object.public_send(field_name.underscore).map do |filter|
      Filter.new filter['type'], filter['value']
    end
  end
end
