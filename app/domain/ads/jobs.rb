# frozen_string_literal: true

module Ads::Jobs
  extend self

  def interaction(channel:, kind:, user:, reference:, track_code:, request:)
    raise "Invalid kind #{ kind }" unless Ads::Interaction.kinds.include? kind

    Ads::Jobs::TrackJob.perform_later(
      channel: channel,
      user: user,
      reference: reference,
      kind: kind,
      ip_address: request.remote_ip,
      track_code: track_code || Mobile::ExtractInfoFromHeaders.get_http_x_track_code(request),
      user_agent: Mobile::ExtractInfoFromHeaders.get_http_user_agent(request),
    )
  end

  def newsletter(subject:, event:, request_info: {})
    valid = Ads::Newsletter::BUDGET_COUNTERS.key?(event)
    raise "Invalid #{ event }" unless valid

    Ads::Jobs::TrackNewsletterJob.perform_later(
      subject: subject,
      event: event,
      request_info: request_info,
    )
  end
end
