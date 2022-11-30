# frozen_string_literal: true

module Graph::Mutations
  class UpcomingPageSubscribersExport < BaseMutation
    argument_record :upcoming_page, UpcomingPage, required: true, authorize: ApplicationPolicy::MAINTAIN

    returns Graph::Types::UpcomingPageType

    def perform(upcoming_page:)
      UpcomingPages::ExportSubscribersToCsvWorker.perform_later user: current_user, upcoming_page: upcoming_page

      upcoming_page
    end
  end
end
