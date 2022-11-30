# frozen_string_literal: true

module Graph::Mutations
  class DestroyUpcomingPageSegment < BaseMutation
    argument_record :upcoming_page_segment, UpcomingPageSegment, authorize: :destroy, required: true

    returns Graph::Types::CollectionType

    def perform(upcoming_page_segment:)
      upcoming_page_segment.trash
      upcoming_page_segment
    end
  end
end
