# frozen_string_literal: true

class Spam::TrashCommentsWorker < ApplicationJob
  include ActiveJobHandlePostgresErrors

  def perform(current_user:, user:, parent_log_id:, kind:, level:)
    Spam::Log.transaction do
      user.comments.find_each do |comment|
        Spam.log_entity(
          user: user,
          entity: comment,
          action: :delete,
          kind: kind.to_sym,
          level: level.to_sym,
          current_user: current_user,
          parent_log_id: parent_log_id,
          remarks: 'Comment is trashed, check parent log for more info.',
        )

        comment.trash
      end
    end
  end
end
