# frozen_string_literal: true

module Graph::Mutations
  class GoalsExport < BaseMutation
    returns Graph::Types::UserType

    def perform
      Maker::Goals::GoalsExportToCsvWorker.perform_later user: current_user
      current_user
    end
  end
end
