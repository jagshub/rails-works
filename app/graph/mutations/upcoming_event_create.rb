# frozen_string_literal: true

# NOTE(DZ): No team membership permissions needed here. Events require confirmation
module Graph::Mutations
  class UpcomingEventCreate < BaseMutation
    argument_record :post, Post, required: true, authorize: :create_upcoming_event

    argument :title, String, required: true
    argument :description, String, required: true
    argument :banner_uuid, String, required: true
    argument :banner_mobile_uuid, String, required: false

    returns Graph::Types::Upcoming::EventType

    require_current_user

    def perform(post:, **params)
      UpcomingEvents::Form.create(post: post, user: current_user, **params)
    end
  end
end
