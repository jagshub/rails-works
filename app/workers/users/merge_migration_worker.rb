# frozen_string_literal: true

module Users
  class MergeMigrationWorker < ApplicationJob
    def perform(result_user, trashed_user)
      Users::Merge.migrate_associations(
        result_user: result_user,
        trashed_user: trashed_user,
      )
    end
  end
end
