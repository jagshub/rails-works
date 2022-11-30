# frozen_string_literal: true

class Admin::PostForm
  include MiniForm::Model

  POST_PARAMS = %i(
    name
    tagline
    slug
    user_id
    featured_at
    scheduled_at
    score_multiplier
    accepted_duplicate
    description
    disabled_when_scheduled
    promo_text
    promo_code
    promo_expire_at
    product_state
    exclude_from_ranking
  ).freeze

  model :primary_link, attributes: %i(url)
  model :post, attributes: POST_PARAMS, read: %i(id persisted? new_record?)

  # Note(AR): Not using `model :product`, because if it's missing, `update` breaks
  attr_reader :product
  Product::SOCIAL_LINKS.each do |social_link_method|
    delegate social_link_method, to: :product, allow_nil: true
  end

  validates :scheduled_at, presence: true

  def initialize(user, post)
    @user = user
    @post = post
    @product = @post.new_product
    @primary_link = @post.primary_link
  end

  def publish(attributes = {})
    if update(attributes) && update_product(attributes)
      :success
    else
      :error
    end
  end

  def to_model
    post
  end

  def to_param
    post.slug
  end

  private

  attr_reader :user

  def update_product(attributes)
    return true if product.blank?

    Product::SOCIAL_LINKS.each do |social_link_method|
      product[social_link_method] = attributes[social_link_method]
    end

    product.save
  end

  def perform
    post.save!
    product&.save!
  end

  def after_update
    send_metrics_event
  end

  def send_metrics_event
    options = { name: post.name, url: post.url, tagline: post.tagline }
    Metrics.track_create user: user, type: 'post', options: options
  end
end
