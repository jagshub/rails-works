# frozen_string_literal: true

module Graph::Mutations
  class CreateUpcomingPageSegment < BaseMutation
    argument_record :upcoming_page, UpcomingPage, required: true, authorize: :maintain
    argument :name, String, required: false

    returns Graph::Types::UpcomingPageSegmentType

    def perform(upcoming_page:, name: false)
      segment = UpcomingPageSegment.new(
        upcoming_page: upcoming_page,
        name: name,
      )

      ApplicationPolicy.authorize!(current_user, :new, segment)

      segment.save
      segment
    end
  end
end
