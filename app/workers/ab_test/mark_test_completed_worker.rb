# frozen_string_literal: true

class AbTest::MarkTestCompletedWorker < ApplicationJob
  include ActiveJobHandleDeserializationError

  def perform(test_name:, user:, visitor_id:, variant:, anonymous_id:)
    scope = AbTest::Participant.where(
      test_name: test_name,
      variant: variant,
      completed_at: nil,
    )

    participant = if user.present?
                    scope.where(
                      user: user,
                    ).first
                  elsif visitor_id.present?
                    scope.where(
                      visitor_id: visitor_id,
                    ).first
                  elsif anonymous_id.present?
                    scope.where(
                      anonymous_id: anonymous_id,
                    ).first
                  end
    return if participant.blank?

    participant.update! completed_at: Time.zone.now
  end
end
