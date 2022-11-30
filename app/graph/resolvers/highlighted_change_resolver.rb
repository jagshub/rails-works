# frozen_string_literal: true

module Graph::Resolvers
  class HighlightedChangeResolver < Graph::Resolvers::Base
    type Graph::Types::HighlightedChangeType, null: true

    def resolve
      if current_user&.admin?
        change = ::HighlightedChange.testing.first
        return change if change
      end

      ::HighlightedChange.active.find_by('? BETWEEN DATE(start_date) AND DATE(end_date)', Time.zone.today)
    end
  end
end
