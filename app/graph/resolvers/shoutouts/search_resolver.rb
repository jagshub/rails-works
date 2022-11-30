# frozen_string_literal: true

class Graph::Resolvers::Shoutouts::SearchResolver < Graph::Resolvers::Base
  argument :year, Integer, required: false

  def resolve(year: nil)
    year ||= Time.zone.now.year - 1

    Shoutout.not_trashed.by_priority.by_year(year)
  end
end
