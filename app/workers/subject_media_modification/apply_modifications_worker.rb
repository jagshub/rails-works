# frozen_string_literal: true

class SubjectMediaModification::ApplyModificationsWorker < ApplicationJob
  queue_as :long_running

  def perform(revert: false)
    revert ? SubjectMediaModification::ApplyModifications.revert : SubjectMediaModification::ApplyModifications.modify
  end
end
