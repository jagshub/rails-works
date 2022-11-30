# frozen_string_literal: true

module Spam::MarkEntity
  extend self
  def call(level:, user:, entity:, current_user:, remarks:, kind:)
    log = Spam::Log.transaction do
      Spam.log_entity(
        user: user,
        kind: kind,
        entity: entity,
        remarks: remarks,
        level: level,
        current_user: current_user,
        action: perform_action_on(entity, level),
      )
    end

    perform_user_action(log) if entity.class == User

    log
  end

  private

  def perform_action_on(entity, level)
    case entity
    when Comment
      if level == :questionable
        entity.hide!
        :hide
      else
        entity.destroy!
        :delete
      end
    when Post
      entity.trash
      :trash
    when User
      :mark_as_spam
    when Vote
      entity.update! credible: false, sandboxed: true
      :mark_as_non_credible
    else raise "Invalid entity - #{ entity.class.name } #{ entity.id }"
    end
  end

  def perform_user_action(log)
    job_payload = log.job_payload

    case log.level
    when 'questionable' then Spam::SpamUserWorker.perform_later(job_payload, role: 'potential_spammer', actions: %w(mark_votes))
    when 'inappropriate' then Spam::SpamUserWorker.perform_later(job_payload, role: 'spammer', actions: %w(mark_votes))
    end
  end
end
