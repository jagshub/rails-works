# frozen_string_literal: true

module Graph::Types
  class Discussion::ThreadSubjectType < BaseUnion
    graphql_name 'DiscussionThreadSubject'

    possible_types(
      Graph::Types::MakerGroupType,
      Graph::Types::MakersFestival::EditionType,
      Graph::Types::ChangeLogType,
    )
  end
end
