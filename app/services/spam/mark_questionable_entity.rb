# frozen_string_literal: true

module Spam::MarkQuestionableEntity
  extend self

  def call(user:, entity:, current_user:, remarks:)
    Spam.mark_entity(
      level: :questionable,
      kind: :manual,
      entity: entity,
      current_user: current_user,
      user: user,
      remarks: remarks,
    )

    entity
  end
end
