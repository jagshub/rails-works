# frozen_string_literal: true

class AbTest::ParticipantLogWorker < ApplicationJob
  queue_as :tracking

  include ActiveJobHandleDeserializationError

  def perform(test_name:, user:, visitor_id:, anonymous_id:, variant:)
    AbTest::Participant.create!(
      user: user,
      test_name: test_name,
      variant: variant,
      visitor_id: visitor_id,
      anonymous_id: anonymous_id,
    )
  end
end
