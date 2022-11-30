# frozen_string_literal: true

class Posts::Submission::Attributes
  attr_reader(
    :additional_links,
    :comment,
    :featured_at,
    :makers,
    :multiplier,
    :post,
    :primary_link,
    :media,
    :topic_ids,
    :draft_uuid,
    :share_with_press,
    :thumbnail_image_uuid,
    :comment_prompts,
  )

  def initialize(params, user = nil)
    @additional_links = extract_array(params[:additional_links])&.map(&:strip)&.reject(&:blank?)
    @comment = extract_comment(params)
    @featured_at = params[:featured_at]
    @makers = extract_makers(params, user)
    @multiplier = params[:multiplier]
    @post = extract_post(params, user)
    @primary_link = extract_primary_link(params)
    @media = extract_media(params)
    @thumbnail_image_uuid = params[:thumbnail_image_uuid]
    @topic_ids = extract_topic_ids(params)
    @draft_uuid = params[:draft_uuid]
    @share_with_press = params[:share_with_press]
    @comment_prompts = extract_array(params[:comment_prompts])
  end

  private

  ACCEPTED_STATES = ['default', 'pre_launch'].freeze

  def extract_product_state(params, user)
    return if params[:product_state].nil?

    has_maker_privileges = !!(user&.admin? || params[:is_maker])
    if has_maker_privileges || ACCEPTED_STATES.include?(params[:product_state])
      params[:product_state]
    else
      ACCEPTED_STATES.first
    end
  end

  def extract_makers(params, user)
    return if !params[:is_maker] && !params[:makers]

    [params[:is_maker] ? { username: user.username } : nil]
      .concat(params[:makers] || [])
      .compact
      .map { |maker| maker[:username] }
  end

  POST_PARAM_NAMES = %i(description name tagline changes_in_version promo_text promo_code promo_expire_at pricing_type share_with_press).freeze

  def extract_post(params, user)
    new_params = params.slice(*POST_PARAM_NAMES)
    new_params[:product_state] = extract_product_state(params, user) if params[:product_state]
    new_params unless new_params.empty?
  end

  def extract_array(array)
    return if array.nil?

    array = Array(array).compact.uniq
    array = yield array if block_given?
    array
  end

  def extract_comment(params)
    return unless params[:comment_body]

    { body: params[:comment_body] }
  end

  def extract_media(params)
    return if !params.key?(:video_media) && !params.key?(:media)

    [params[:video_media]].concat(params[:media] || []).compact
  end

  def extract_primary_link(params)
    return unless params[:url]

    { url: params[:url] }
  end

  def extract_topic_ids(params)
    extract_array(params[:topics]) do |id_or_suggestions|
      id_or_suggestions.pluck(:id).map(&:to_i).reject(&:zero?)
    end
  end
end
