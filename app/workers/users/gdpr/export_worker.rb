# frozen_string_literal: true

module Users::GDPR
  class ExportWorker < ApplicationJob
    include ActiveJobRetriesCount

    def perform(user:)
      export = Users::GDPR::Export.new(user: user)
      export.invoke!
    end
  end
end
