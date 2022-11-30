# frozen_string_literal: true

module Users
  extend self

  def merge(result_user:, trashed_user:)
    Users::Merge.basics(result_user: result_user, trashed_user: trashed_user)
    Users::MergeMigrationWorker.perform_later(result_user, trashed_user)
  end

  def better_role?(old_role:, new_role:)
    Users::BetterRole.call(old_role: old_role, new_role: new_role)
  end

  def sync_header(user, medium:, overwrite: false)
    Users::SyncHeaderWorker.perform_later(user.id, medium: medium, overwrite: overwrite)
  end
end
