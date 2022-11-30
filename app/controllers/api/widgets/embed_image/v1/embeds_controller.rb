# frozen_string_literal: true

class API::Widgets::EmbedImage::V1::EmbedsController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found
  after_action :track, except: %i(chart_comments chart_votes)

  def featured_post_badge
    @post = Post.not_trashed.friendly.find(params[:post_id])

    render_badge(
      icon: :default_logo,
      theme: params[:theme],
      title: @post.featured? ? 'FEATURED ON' : 'FIND US ON',
      subtitle: 'Product Hunt',
      upvote_count: @post.votes_count,
      metric_type: :upvotes,
    )
  end

  def top_post_badge
    @post = Post.not_trashed.friendly.find(params[:post_id])
    badge = Badges::TopPostBadge.where(subject: @post).with_data(period: (params[:period] || 'daily')).first!

    render_badge(
      icon: badge_icon_from(badge).to_sym,
      theme: params[:theme],
      title: 'PRODUCT HUNT',
      subtitle: badge_subtitle_from(badge),
      metric_type: :upvotes,
    )
  end

  def top_post_topic_badge
    @post = Post.not_trashed.friendly.find(params[:post_id])
    data = {
      period: (params[:period] || 'weekly'),
      topic_name: params[:topic],
    }.compact

    badge = Badges::TopPostTopicBadge.where(subject: @post).with_data(data).first!

    render_badge(
      theme: params[:theme],
      title: badge_topic_title_from(badge),
      subtitle: badge_topic_subtitle_from(badge),
      icon: :default_logo,
    )
  end

  def golden_kitty_badge
    @post = Post.not_trashed.friendly.find(params[:post_id])
    badge = Badges::GoldenKittyAwardBadge.find_by! subject: @post

    render_badge(
      icon: :golden_kitty,
      theme: params[:theme],
      title: "#{ badge.year } PRODUCT HUNT",
      subtitle: 'Golden Kitty Winner',
      metric_type: :upvotes,
    )
  end

  # NOTE(RAJ): This is not removed to support websites already using this embed.
  def review_post_badge
    @post = Post.not_trashed.friendly.find(params[:post_id])

    render_badge(
      icon: :default_logo,
      theme: params[:theme],
      title: 'LEAVE A REVIEW ON',
      subtitle: 'Product Hunt',
      metric_type: :review,
    )
  end

  def chart_comments
    svg = Rails.cache.fetch("embed_image/chart_comments/v2/#{ params[:post_id] }-#{ params[:frame] }", expires_in: 1.hour) do
      Posts::SvgCharts.post_comments(
        post: Post.not_trashed.find(params[:post_id]),
        frame: params[:frame],
      )
    end

    response.headers['Content-Type'] = 'image/svg+xml'

    render body: svg
  end

  def chart_votes
    svg = Rails.cache.fetch("embed_image/chart_votes/v2/#{ params[:post_id] }-#{ params[:frame] }", expires_in: 1.hour) do
      Posts::SvgCharts.post_votes(
        post: Post.not_trashed.find(params[:post_id]),
        frame: params[:frame],
      )
    end

    response.headers['Content-Type'] = 'image/svg+xml'

    render body: svg
  end

  def follow_product_badge
    render_badge(
      icon: :default_logo,
      theme: params[:theme],
      title: 'FOLLOW US ON',
      subtitle: 'Product Hunt',
      size: params[:size],
      small_size_title: 'Follow',
    )
  end

  def review_product_badge
    @product = Product.not_trashed.friendly.find(params[:product_id])

    render_badge(
      icon: :default_logo,
      theme: params[:theme],
      title: 'LEAVE A REVIEW ON',
      subtitle: 'Product Hunt',
      metric_type: :review,
    )
  end

  private

  def render_badge(options)
    response.headers['Content-Type'] = 'image/svg+xml'

    render body: EmbedSvg.generate(options)
  end

  def track
    return unless @post

    kind = action_name.to_sym
    kind = :default_post_badge if kind == :featured_post_badge && !@post.featured?

    TrackingPixel.track(@post, kind, request.referer)
  end

  def badge_icon_from(badge)
    return "#{ badge.period }_#{ badge.position }" if badge.period == 'daily'

    badge.period
  end

  def badge_subtitle_from(badge)
    period = 'Day'
    period = 'Week' if badge.period == 'weekly'
    period = 'Month' if badge.period == 'monthly'

    "##{ badge.position } Product of the #{ period }"
  end

  def badge_topic_title_from(badge)
    period = 'WEEK'
    period = 'MONTH' if badge.period == 'monthly'

    "##{ badge.position } PRODUCT OF THE #{ period }"
  end

  def badge_topic_subtitle_from(badge)
    badge.topic_name.to_s
  end

  NOT_FOUND = {
    error: 'not_found',
    error_description: 'We could not find any object with this ID',
  }.freeze

  def handle_record_not_found
    render json: NOT_FOUND, status: :not_found
  end
end
