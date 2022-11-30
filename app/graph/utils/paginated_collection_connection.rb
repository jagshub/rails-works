# frozen_string_literal: true

module Graph::Utils
  # A custom connection class that is used to handle collection objects with cursors pagination.
  # The object must respond to:
  # - #fetch(limit:, offset:) => Object[]
  # - #total_count => Integer
  class PaginatedCollectionConnection < GraphQL::Pagination::Connection
    def total_count
      @total_count ||= items.total_count
    end

    def nodes
      @nodes ||= items.fetch(limit: limit, offset: offset)
    end

    def cursor_for(item)
      index = if before_value.present?
                before_index - limit + nodes.find_index(item)
              else
                after_index + nodes.find_index(item) + 1
              end

      encode(index.to_s)
    end

    def has_next_page
      total_count > offset + limit
    end

    def has_previous_page
      offset > 0
    end

    private

    def index_from_cursor(cursor)
      decode(cursor).to_i
    end

    def before_index
      @before_index ||= begin
        return 0 if before_value.blank?

        index_from_cursor(before_value)
      end
    end

    def after_index
      @after_index ||= begin
        return 0 if after_value.blank?

        index_from_cursor(after_value)
      end
    end

    def limit
      return last_value if before_value.present?

      first_value
    end

    def offset
      if before_value.present?
        before_index - limit - 1
      elsif after_value.present?
        after_index
      elsif first_value.present?
        0
      end
    end
  end
end
