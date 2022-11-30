# frozen_string_literal: true

module Mobile::Graph::Types
  class FlagReasonEnumType < BaseEnum
    graphql_name 'FlagReasonEnum'

    Flag.reasons.each do |reason, _k|
      value reason, reason.humanize
    end
  end
end
