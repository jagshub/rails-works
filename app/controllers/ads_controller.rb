# frozen_string_literal: true

class AdsController < ApplicationController
  include AdsHelper

  before_action :set_robot_noindex
  skip_before_action :verify_origin

  def redirect
    channel = Ads::Channel.find params[:attribution_id]
    url = get_url channel, ref: params[:ref]
    track channel, ref: params[:ref]

    redirect_to url, status: :moved_permanently
  end

  def newsletter_redirect
    newsletter = Ads::Newsletter.find params[:attribution_id]
    url = get_url newsletter, ref: 'newsletter'
    track_newsletter newsletter

    redirect_to url, status: :moved_permanently
  end

  def newsletter_sponsor_redirect
    newsletter = Ads::NewsletterSponsor.find params[:attribution_id]
    url = get_url newsletter, ref: 'newsletter'
    track_newsletter newsletter

    redirect_to url, status: :moved_permanently
  end

  private

  def set_robot_noindex
    response.headers['X-Robots-Tag'] = 'noindex'
  end

  def track(channel, ref: nil)
    reference = Ads.validate_reference(ref)

    Ads.trigger_interaction(
      channel: channel,
      reference: reference,
      kind: 'click',
      user: current_user,
      track_code: cookies[:track_code],
      request: request,
    )
  end

  def track_newsletter(subject)
    request_info = RequestInfo.new(request)

    event_data = {
      subject: subject,
      event: 'click',
      request_info: {
        user_agent: request_info.user_agent,
        is_bot: request_info.bot?,
        user_id: current_user.try(:id),
        visitor_id: request.cookies['visitor_id'],
        ip_address: request.ip,
      },
    }

    Ads.trigger_newsletter_event(**event_data)
  end
end
