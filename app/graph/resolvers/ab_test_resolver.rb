# frozen_string_literal: true

class Graph::Resolvers::AbTestResolver < Graph::Resolvers::Base
  type String, null: true

  argument :test_name, String, required: true

  def resolve(test_name:)
    AbTest.variant_for(ctx: context, test: test_name)
  # Note(dhruvparmar372): Cached clients can request a/b variants for tests
  # that have been removed, we should ignore those by returning nil
  rescue KeyError
    nil
  end
end
