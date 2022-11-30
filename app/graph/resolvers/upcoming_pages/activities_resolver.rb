# frozen_string_literal: true

class Graph::Resolvers::UpcomingPages::ActivitiesResolver < Graph::Resolvers::Base
  type Graph::Types::UpcomingPageActivityType, null: false

  def resolve
    return [] unless ApplicationPolicy.can?(current_user, ApplicationPolicy::MAINTAIN, object)

    UpcomingPages::FetchActivities.new(object)
  end

  class Connection < GraphQL::Pagination::Connection
    def total_count
      items.call.count
    end

    def nodes
      paged_nodes
    end

    def cursor_for(item)
      idx = (after_value ? index_from_cursor(after_value) : 0) + paged_nodes.find_index(item) + 1
      encode(idx.to_s)
    end

    def has_next_page
      first_node.present?
    end

    def has_previous_page
      last_node.present?
    end

    private

    def first_node
      return @first_node if defined? @first_node

      @fist_node = paged_nodes.first
    end

    def last_node
      return @last_node if defined? @last_node

      @last_node = paged_nodes.last
    end

    def paged_nodes
      @paged_nodes ||= fetch_paged_nodes
    end

    def fetch_paged_nodes
      if before_value && after_value
        limit = index_from_cursor(before_value) - last_value
        items.call(
          limit: limit,
          offset: index_from_cursor(after_value) - limit + first_value,
        )
      elsif before_value
        items.call(
          limit: index_from_cursor(before_value) - last_value,
          offset: last_value,
        )
      elsif after_value
        items.call(
          limit: index_from_cursor(after_value),
          offset: first_value,
        )
      elsif first_value
        items.call(
          limit: first_value,
          offset: 0,
        )
      else
        items.call
      end
    end

    def index_from_cursor(cursor)
      decode(cursor).to_i
    end
  end
end
