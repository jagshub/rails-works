# frozen_string_literal: true

module Mobile::Graph::Types
  class VersionLevelEnum < BaseEnum
    graphql_name 'VersionLevel'

    value 'alpha'
    value 'beta'
    value 'production'
  end
end
