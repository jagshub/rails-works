# frozen_string_literal: true

module Graph::Mutations
  class UpcomingPageChangeStatus < BaseMutation
    argument_record :upcoming_page, UpcomingPage
    argument :promoted, Boolean, required: false

    returns Graph::Types::UpcomingPageType

    def perform(upcoming_page:, promoted:)
      form = UpcomingPages::Form.new(current_user, upcoming_page)
      form.update(
        status: promoted == true ? 'promoted' : 'unlisted',
      )
      form
    end
  end
end
