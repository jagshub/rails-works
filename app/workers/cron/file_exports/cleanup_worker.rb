# frozen_string_literal: true

class Cron::FileExports::CleanupWorker < ApplicationJob
  def perform
    FileExport.expired.find_each(&:delete_file)
  end
end
