# frozen_string_literal: true

class Posts::UpdateForm
  include MiniForm::Model

  model :post, save: true, attributes: %i(
    name
    tagline
    description
    promo_text
    promo_code
    promo_expire_at
    pricing_type
    product_state
  )

  model :product, save: true, attributes: %i(
    angellist_url
    twitter_url
    facebook_url
    github_url
    instagram_url
    medium_url
  )

  model :link, save: true, attributes: %i(
    url
  )

  attributes(
    :makers,
    :additional_links,
    :media,
    :multiplier,
    :featured_at,
    :locked,
    :thumbnail_image_uuid,
    :social_media_image_uuid,
    :topic_ids,
  )

  alias graphql_result post
  alias node post

  MAX_FIELD_LENGTH = { description: 260, name: 40 }.freeze

  validate :ensure_no_emoji_in_name
  validate :ensure_attr_lengths
  validate :ensure_thumbnail_present
  validate :ensure_unique_additional_links
  validate :ensure_minimum_one_topic_id
  validate :ensure_not_ph_url

  before_update :update_user_edited_at

  def initialize(post, user: nil)
    @post = post
    @link = post.primary_link
    @product = post.new_product || find_and_attach_product(link.url, post) || create_product_for(post)
    @user = user
    @topic_ids = post.topic_ids
  end

  def description=(value)
    post.description = value
    description_text = Sanitizers::HtmlToText.call(value, extract_attr: false)
    post.description_length = description_text.nil? ? 0 : description_text.length
  end

  STATES_FOR_ALL = %w(default pre_launch).freeze
  def product_state=(value)
    return if !can_moderate? && !STATES_FOR_ALL.include?(value)

    post.product_state = value
  end

  def makers=(value)
    Posts::Submission::SetMakers.call(
      post: post,
      user: user,
      makers: value,
    )
  end

  def url=(value)
    link.url = value

    return if value.blank?
    return unless link.url_changed?
    return if post.product_association.blank?
    return unless post.product_association.source.in? ['post_create', 'post_update']

    product = Products::Find.by_url(value)
    old_product = @product

    return if product&.id == old_product&.id

    if product
      Products::MovePost.call(post: post, product: product, source: 'post_update')
    else
      product = create_product_for(post, url: value)
    end

    product.update!(old_product.changes.transform_values { |_before, after| after })
    # Reset changes:
    old_product.reload

    Products::RefreshActivityEventsWorker.perform_later(product)
  end

  def additional_links=(value)
    @additional_links = value

    Posts::Submission::SetAdditionalLinks.call(
      post: post,
      user: user,
      links: value,
    )
  end

  def featured_at=(value)
    Posts::Submission::SetDates.call(
      post: post,
      user: user,
      featured_at: value,
    )
  end

  def multiplier=(value)
    return unless can_moderate?

    Moderation.change_multiplier(by: user, post: post, multiplier: value) if user.admin?
  end

  def locked=(value)
    return unless can_moderate?

    Moderation.change_locked(by: user, post: post, locked: value) if user.admin?
  end

  def perform
    post.topic_ids = topic_ids
    Posts::Submission::SetMedia.call(
      post: post,
      user: user,
      media: media,
      thumbnail_image_uuid: thumbnail_image_uuid,
      social_media_image_uuid: social_media_image_uuid,
    )
  end

  private

  attr_reader :user

  def can_moderate?
    ApplicationPolicy.can?(user, :moderate, post)
  end

  def ensure_attr_lengths
    # NOTE(emilov): we use post.send(:description) instead of post[:description] because due to how this is set up, the latter is sometimes nil
    MAX_FIELD_LENGTH.each do |field, max_length|
      next if post.send(field).blank?

      # NOTE(emilov): if we have e.g. :description_length attr, use that for length
      len_field = "#{ field }_length".to_sym
      len = post.respond_to?(len_field) ? post.send(len_field) : post.send(field).length

      errors.add field, "should not be more than #{ max_length } characters" if len > max_length
    end
  end

  def update_user_edited_at
    return if can_moderate?

    post.user_edited_at = Time.current
  end

  def ensure_no_emoji_in_name
    return unless attributes[:name].to_s =~ /\p{Emoji_Presentation}/u

    errors.add :name, "can't include emoji"
  end

  def ensure_thumbnail_present
    return unless attributes[:thumbnail_image_uuid].nil?

    errors.add :thumbnail_image_uuid, 'You must have a thumbnail image!'
  end

  def ensure_unique_additional_links
    return if @additional_links.nil?

    has_duplicates = @additional_links.tally.values.any? { |x| x >= 2 }

    return unless has_duplicates

    errors.add :additional_links, 'Duplicate URLs'
  end

  def ensure_minimum_one_topic_id
    return unless topic_ids.empty?

    errors.add :topic_ids, 'need at least 1 topic for post'
  end

  def ensure_not_ph_url
    return unless UrlParser.ph_url?(link.url) && !user.admin?

    errors.add :link, 'cannot be a Producthunt url'
  end

  def find_and_attach_product(url, post)
    existing_product = Products::Find.by_url(url)
    return if existing_product.blank?

    Products::MovePost.call(post: post, product: existing_product, source: 'post_update')
    existing_product
  end

  def create_product_for(post, **params)
    Products::Create.for_post(post, product_source: 'post_update', **params)
  end
end
