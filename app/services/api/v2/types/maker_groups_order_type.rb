# frozen_string_literal: true

module API::V2::Types
  class MakerGroupsOrderType < BaseEnum
    value 'LAST_ACTIVE', 'Returns MakerGroups in descending order of last active date.'
    value 'MEMBERS_COUNT', 'Returns MakerGroups in descending order of members count.'
    value 'GOALS_COUNT', 'Returns MakerGroups in descending order of goals count.'
    value 'NEWEST', 'Returns MakerGroups in descending order of creation date.'
  end
end
