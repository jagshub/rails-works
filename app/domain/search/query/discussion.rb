# frozen_string_literal: true

class Search::Query::Discussion < Search::Query::Base
  def initialize(query, &block)
    super(query, models: [Discussion::Thread], &block)
  end
end
