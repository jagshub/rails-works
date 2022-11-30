# frozen_string_literal: true

# NOTE(rstankov): This overwrites the build-in GraphQL PageInfo `has_next_page` / `has_previous_page`
#   It checks if currently loaded items are more or equal to limit, if so we assume there is next page
#   We skip an extra expensive count query. In some cases we might fetch an extra page.
#
#   Original implementation:
#     https://github.com/rmosolgo/graphql-ruby/blob/master/lib/graphql/relay/relation_connection.rb#L26-L50
class Graph::Common::FastPageInfo
  delegate :start_cursor, :end_cursor, to: '@connection'

  def initialize(connection)
    @connection = connection
  end

  def has_next_page
    if @connection.first
      @connection.send(:nodes).length >= @connection.first
    else
      false
    end
  end

  def has_previous_page
    if @connection.last
      @connection.send(:nodes).length >= @connection.last
    else
      false
    end
  end
end
