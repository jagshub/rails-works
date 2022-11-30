# frozen_string_literal: true

class Ships::SyncPaymentReportsWorker < ApplicationJob
  include ActiveJobHandleNetworkErrors

  def perform
    Ships::SyncPaymentReports.new.call
  end
end
