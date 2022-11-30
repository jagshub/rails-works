# frozen_string_literal: true

module Graph::Mutations
  class UpdateUpcomingPageSegment < BaseMutation
    argument_record :upcoming_page_segment, UpcomingPageSegment, authorize: :edit, required: true
    argument :name, String, required: false

    returns Graph::Types::UpcomingPageSegmentType

    def perform(upcoming_page_segment:, name: nil)
      upcoming_page_segment.update(name: name)
      upcoming_page_segment
    end
  end
end
