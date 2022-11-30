# frozen_string_literal: true

class SubjectMediaModification::CreateModificationRecordsWorker < ApplicationJob
  queue_as :long_running

  def perform(subject:, target_column:)
    SubjectMediaModification::CreateModificationRecords.call(subject: subject, target_column: target_column)
  end
end
