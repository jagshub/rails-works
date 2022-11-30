# frozen_string_literal: true

module MakerReports
  class DigestWorker < ApplicationJob
    include ActiveJobHandleMailjetErrors

    queue_as :notifications

    def perform(maker_report)
      presenter = MakerReports::DigestPresenter.new(maker_report)
      return unless presenter.activities?

      MakerReportMailer.digest(presenter).deliver_now
    end
  end
end
