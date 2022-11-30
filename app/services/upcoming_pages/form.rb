# frozen_string_literal: true

class UpcomingPages::Form
  include MiniForm::Model
  include UpcomingPages::Form::Links

  VARIANT_ATTRIBUTES = %i(
    background_image_uuid
    thumbnail_uuid
    brand_color
    logo_uuid
    what_text
    who_text
    why_text
    unsplash_background_url
    template_name
    background_color
    media
  ).freeze

  ATTRIBUTES = %i(
    hiring
    name
    slug
    status
    success_text
    tagline
    webhook_url
    widget_intro_message
    seo_title
    seo_description
    seo_image_uuid
  ).freeze

  model :upcoming_page, attributes: ATTRIBUTES, read: %i(id), save: true
  model :variant_a, attributes: VARIANT_ATTRIBUTES, save: true
  model :variant_b, attributes: VARIANT_ATTRIBUTES, prefix: 'variant_b'

  attributes :topic_ids, :variant_b_status

  url_attributes :website, :app_store, :play_store, :twitter, :facebook, :angellist, :privacy_policy

  validates :who_text, html_text_length: { maximum: 300 }
  validates :what_text, html_text_length: { maximum: 300 }
  validates :why_text, html_text_length: { maximum: 300 }

  validates :variant_b_who_text, html_text_length: { maximum: 300 }
  validates :variant_b_what_text, html_text_length: { maximum: 300 }
  validates :variant_b_why_text, html_text_length: { maximum: 300 }

  validate :background_image

  before_update :authorize_save
  before_update :handle_promote
  before_update :authorize_webhooks
  before_update :toggle_ab_testing

  after_update :update_variant_b
  after_update :update_topics
  after_update :update_account_name
  after_update :send_notifications
  after_update :bootstrap_tasks, if: :new_record?
  after_update :complete_tasks

  alias node upcoming_page
  alias graphql_result upcoming_page

  def initialize(user, upcoming_page = nil)
    @user = user
    @upcoming_page = upcoming_page || UpcomingPage.new(user: user, account: find_or_build_ship_account)
    @variant_a = @upcoming_page.variant(:a) || UpcomingPageVariant.new(kind: :a, upcoming_page: @upcoming_page)
    @variant_b = @upcoming_page.variant(:b) || UpcomingPageVariant.new(kind: :b, upcoming_page: @upcoming_page)
    @new_record = @upcoming_page.new_record?
  end

  def media=(value)
    set_media(variant_a, value)
  end

  def variant_b_media=(value)
    set_media(variant_b, value)
  end

  private

  def set_media(variant, value)
    unless value
      variant.media = value
      return
    end

    variant.media = value.to_h
    variant.media['metadata'] = media['metadata'].transform_keys { |key| key.to_s.underscore } if media['metadata']
  end

  def new_record?
    @new_record
  end

  def find_or_build_ship_account
    @user.ship_account || @user.create_ship_account!(subscription: @user.ship_subscription)
  end

  def toggle_ab_testing
    return if variant_b_status.nil?

    @upcoming_page.ab_started_at = variant_b_status == 'enabled' ? @variant_b.created_at || Time.current : nil
  end

  def update_variant_b
    return if variant_b_status.nil?

    if variant_b_status == 'enabled'
      @variant_b.save!
    else
      @variant_b.destroy!
    end
  end

  def update_topics
    return if Array(topic_ids).map(&:to_i) == @upcoming_page.topic_ids
    return if topic_ids.blank?

    UpcomingPage.transaction do
      @upcoming_page.upcoming_page_topic_associations.delete_all

      Topic.where(id: topic_ids).each do |topic|
        @upcoming_page.upcoming_page_topic_associations.create!(topic: topic)
      end
    end
  end

  # NOTE(rstankov): We don't ask for account name when creating ship account
  def update_account_name
    @upcoming_page.account.update! name: @upcoming_page.name unless @upcoming_page.account.name?
  end

  def authorize_save
    if new_record?
      ApplicationPolicy.authorize! @user, :create, @upcoming_page
    else
      ApplicationPolicy.authorize! @user, :update, @upcoming_page
    end
  end

  def authorize_webhooks
    return if @upcoming_page.webhook_url == @upcoming_page.webhook_url_was
    return if @upcoming_page.webhook_url.blank?

    ApplicationPolicy.authorize! @user, :ship_webhooks, @upcoming_page
  end

  def handle_promote
    return if @upcoming_page.status_was == 'promoted'
    return if @upcoming_page.status != 'promoted'

    ApplicationPolicy.authorize! @user, :promote, @upcoming_page
  end

  def bootstrap_tasks
    UpcomingPages::MakerTasks.bootstrap(@upcoming_page)
  end

  def complete_tasks
    UpcomingPages::MakerTasks.complete(@upcoming_page)
  end

  def send_notifications
    ::UpcomingPages::Form::Notifications.call(@upcoming_page)
  end

  def background_image
    errors.add :base, 'You have to either upload or select unsplash image, not both!' if (background_image_uuid.present? && unsplash_background_url.present?) || (variant_b_background_image_uuid.present? && variant_b_unsplash_background_url.present?)
  end
end
