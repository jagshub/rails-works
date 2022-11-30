# frozen_string_literal: true

module Mobile::Graph::Types
  class VersionOsEnum < BaseEnum
    graphql_name 'VersionOs'

    value 'iOS'
    value 'Android'
  end
end
