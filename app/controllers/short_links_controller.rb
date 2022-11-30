# frozen_string_literal: true

class ShortLinksController < ApplicationController
  before_action :set_robot_noindex
  skip_before_action :verify_origin

  def redirect_to_post
    tracker = ShortLinkTracker.new(
      params: params,
      user: current_user,
      remote_ip: request.remote_ip,
      track_cookie: cookies[:track_code] || Mobile::ExtractInfoFromHeaders.get_http_x_track_code(request) || request.headers['X-Visitor'],
      user_agent: Mobile::ExtractInfoFromHeaders.get_http_user_agent(request),
    )

    tracker.track
    redirect_to tracker.url, status: :moved_permanently
  end

  def redirect
    tracker = ShortLinkTracker.new(
      params: params,
      user: current_user,
      remote_ip: request.remote_ip,
      track_cookie: cookies[:track_code] || Mobile::ExtractInfoFromHeaders.get_http_x_track_code(request) || request.headers['X-Visitor'],
      user_agent: Mobile::ExtractInfoFromHeaders.get_http_user_agent(request),
    )

    tracker.track
    redirect_to tracker.url, status: :moved_permanently
  end

  private

  def set_robot_noindex
    response.headers['X-Robots-Tag'] = 'noindex'
  end

  class ShortLinkTracker
    def initialize(params:, user:, remote_ip:, track_cookie:, user_agent: nil)
      @app_id = params[:app_id] || params[:via_application_id]
      @user = user
      @remote_ip = remote_ip
      @track_cookie = track_cookie
      @ref = params[:ref] || 'unknown'
      @post, @product_link = find_post_and_link(params[:post_id], params[:short_code])
      @user_agent = user_agent

      enqueue_for_enrich_clearbit
    end

    def track
      track_click_through if @post
    end

    def url
      return Rails.application.routes.url_helpers.root_path unless @product_link

      link = @product_link.url

      url = ShortLinkBuilder.build(link, @product_link.store)

      url
    rescue URI::InvalidURIError
      Rails.application.routes.url_helpers.root_path
    end

    private

    def find_post_and_link(post_id, short_code)
      product_link = LegacyProductLink.find_by!(short_code: short_code) if short_code.present?

      post = if product_link.nil? && post_id.present?
               Post.find(post_id)
             elsif product_link.present?
               product_link.post
             end

      return [] if post&.trashed?

      [post, product_link || post&.primary_link]
    end

    def track_click_through
      Metrics.track_click_through(
        post: @post,
        user: @user,
        track_code: @track_cookie,
        remote_ip: @remote_ip,
        via_application_id: @app_id,
      )
    end

    def enqueue_for_enrich_clearbit
      return if @user.blank?

      ClearbitProfiles.enqueue_for_enrich(@user)
    end
  end
end
