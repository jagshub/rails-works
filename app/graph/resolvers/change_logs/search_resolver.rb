# frozen_string_literal: true

class Graph::Resolvers::ChangeLogs::SearchResolver < Graph::Resolvers::BaseSearch
  scope { ChangeLog::Entry.published.order(date: :desc) }
end
