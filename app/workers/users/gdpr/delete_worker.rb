# frozen_string_literal: true

module Users::GDPR
  class DeleteWorker < ApplicationJob
    include ActiveJobRetriesCount

    def perform(user:)
      Users::GDPR::Delete.call(user: user)
    end
  end
end
