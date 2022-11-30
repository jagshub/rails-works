# frozen_string_literal: true

class Spam::TrashPostsWorker < ApplicationJob
  include ActiveJobHandlePostgresErrors

  def perform(current_user:, user:, parent_log_id:, kind:, level:)
    Spam::Log.transaction do
      user.posts.not_trashed.find_each do |post|
        Spam.log_entity(
          user: user,
          entity: post,
          action: :trash,
          kind: kind.to_sym,
          level: level.to_sym,
          current_user: current_user,
          parent_log_id: parent_log_id,
          remarks: 'Post is trashed, check parent log for more info.',
        )

        post.trash
      end
    end
  end
end
