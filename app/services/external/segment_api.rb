# frozen_string_literal: true

module External::SegmentApi
  ANALYTICS = Segment::Analytics.new(write_key: Rails.application.config.x.segment_token,
                                     stub: Rails.env.test?,
                                     on_error: proc { |_status, msg| Rails.logger.error msg })

  extend self

  def track(data)
    raise ArgumentError if data[:event].blank?
    raise ArgumentError if data[:anonymous_id].blank? && data[:user_id].blank?

    ANALYTICS.track(data)
  end

  def flush
    ANALYTICS.flush
  end

  # NOTE(Nikolay): Segment Migration Guide: https://segment.com/docs/privacy-portal/user-deletion-and-suppression/
  # Segment API Guide: https://reference.segmentapis.com/?version=latest#57a69434-76cc-43cc-a547-98c319182247
  def gdpr_delete(user_id:)
    headers = {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{ ENV.fetch('SEGMENT_ACCESS_TOKEN') }",
    }
    body = { 'regulation_type': 'Suppress_With_Delete', 'attributes': { 'name': 'userId', 'values': [user_id.to_s] } }.to_json

    HTTParty.post(
      'https://platform.segmentapis.com/v1beta/workspaces/producthunt/regulations',
      headers: headers,
      body: body,
    )
  end
end
