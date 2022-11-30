# frozen_string_literal: true

class Metrics::Worker < ApplicationJob
  queue_as :tracking

  def perform(distinct_id:, action:, params: {})
    analytics = Segment::Analytics.new(write_key: Rails.application.config.x.segment_token,
                                       stub: Rails.env.test?,
                                       on_error: proc { |_status, msg| Rails.logger.error msg })

    analytics.track(user_id: distinct_id, event: action, properties: params)
    analytics.flush
  end
end
