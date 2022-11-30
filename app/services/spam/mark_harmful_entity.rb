# frozen_string_literal: true

module Spam::MarkHarmfulEntity
  extend self

  def call(user:, entity:, current_user:, remarks:)
    entity_spam_log = Spam.mark_entity(
      level: :harmful,
      kind: :manual,
      entity: entity,
      current_user: current_user,
      user: user,
      remarks: remarks,
    )

    job_payload = entity_spam_log.job_payload

    Spam::SpamUserWorker.perform_later(job_payload)

    Spam::TrashCommentsWorker.perform_later(job_payload)

    Spam::TrashPostsWorker.perform_later(job_payload)

    entity
  end
end
