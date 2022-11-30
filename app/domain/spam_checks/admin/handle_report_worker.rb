# frozen_string_literal: true

class SpamChecks::Admin::HandleReportWorker < ApplicationJob
  include ActiveJobHandlePostgresErrors
  include ActiveJobHandleDeserializationError

  def perform(report, handled_by, action)
    if action == :mark_as_spam
      SpamChecks::Reports.mark_as_spam(report, handled_by)
    elsif action == :mark_as_false_positive
      SpamChecks::Reports.mark_as_false_positive(report, handled_by)
    end
  end
end
