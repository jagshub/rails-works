# frozen_string_literal: true

module Graph::Mutations
  class UpcomingPageDestroy < BaseMutation
    argument_record :upcoming_page, UpcomingPage, authorize: :destroy, required: true

    returns Graph::Types::UpcomingPageType

    def perform(upcoming_page:)
      upcoming_page.trash
      upcoming_page
    end
  end
end
