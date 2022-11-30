# frozen_string_literal: true

class Spam::HideCommentsWorker < ApplicationJob
  include ActiveJobHandlePostgresErrors

  def perform(current_user:, user:, parent_log_id:, kind:, level:)
    Spam::Log.transaction do
      time = Time.current
      comments = user.comments.not_hidden
      batch_comment_ids = comments.ids
      comments.find_each do |comment|
        Spam.log_entity(
          user: user,
          action: :hide,
          entity: comment,
          kind: kind.to_sym,
          level: level.to_sym,
          current_user: current_user,
          parent_log_id: parent_log_id,
          remarks: 'Comment is hidden, check parent log for more info.',
        )

        comment.update! hidden_at: time
      end

      Stream::Workers::FeedItemsBatchCleanUp.perform_later(
        target_ids: batch_comment_ids,
        target_type: 'Comment',
      )
    end
  end
end
