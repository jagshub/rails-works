# frozen_string_literal: true

module Spam::MarkInappropriateEntity
  extend self

  def call(user:, entity:, current_user:, remarks:)
    Spam.mark_entity(
      level: :inappropriate,
      kind: :manual,
      entity: entity,
      current_user: current_user,
      user: user,
      remarks: remarks,
    )

    entity
  end
end
