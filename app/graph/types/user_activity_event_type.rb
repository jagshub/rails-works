# frozen_string_literal: true

module Graph::Types
  class UserActivitySubjectType < BaseUnion
    possible_types(
      ReviewType,
      Discussion::ThreadType,
      CommentType,
    )
  end
  class UserActivityEventType < BaseNode
    field :occurred_at, DateTimeType, null: false
    association :subject, UserActivitySubjectType, null: false
  end
end
