# frozen_string_literal: true

# == Schema Information
#
# Table name: posts
#
#  id                        :integer          not null, primary key
#  user_id                   :integer
#  name                      :string(255)
#  tagline                   :string(255)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  slug                      :string(255)
#  link_visits               :integer          default(0), not null
#  link_unique_visits        :integer          default(0), not null
#  score_multiplier          :float            default(1.0)
#  promoted_at               :datetime
#  accepted_duplicate        :boolean          default(FALSE)
#  featured_at               :datetime
#  trashed_at                :datetime
#  product_id                :integer
#  comments_count            :integer          default(0), not null
#  reviews_count             :integer          default(0), not null
#  alternatives_count        :integer          default(0), not null
#  podcast                   :boolean          default(FALSE), not null
#  disabled_when_scheduled   :boolean          default(TRUE)
#  scheduled_at              :datetime         not null
#  description_length        :integer          default(0), not null
#  description_html          :text
#  changes_in_version        :string
#  votes_count               :integer          default(0), not null
#  credible_votes_count      :integer          default(0), not null
#  locked                    :boolean          default(FALSE), not null
#  user_edited_at            :datetime
#  related_posts_count       :integer          default(0), not null
#  user_flags_count          :integer          default(0)
#  promo_code                :string
#  promo_text                :string
#  promo_expire_at           :datetime
#  pricing_type              :string
#  reviews_with_body_count   :integer          default(0), not null
#  thumbnail_image_uuid      :string
#  social_media_image_uuid   :string
#  share_with_press          :boolean          default(FALSE), not null
#  reviews_with_rating_count :integer          default(0), not null
#  reviews_rating            :decimal(3, 2)    default(0.0), not null
#  product_state             :integer          default("default"), not null
#  exclude_from_ranking      :boolean          default(FALSE), not null
#  daily_rank                :integer
#  weekly_rank               :integer
#  monthly_rank              :integer
#  makers_count              :integer          default(0), not null
#
# Indexes
#
#  index_posts_on_comments_count            (comments_count)
#  index_posts_on_created_at                (created_at) WHERE (trashed_at IS NULL)
#  index_posts_on_credible_votes_count      (credible_votes_count)
#  index_posts_on_featured_at               (featured_at) WHERE (trashed_at IS NULL)
#  index_posts_on_featured_at_scheduled_at  (featured_at,scheduled_at)
#  index_posts_on_name_trgm                 (COALESCE((name)::text, ''::text) gin_trgm_ops) USING gin
#  index_posts_on_product_id                (product_id)
#  index_posts_on_product_state             (product_state)
#  index_posts_on_scheduled_at              (scheduled_at)
#  index_posts_on_slug                      (slug) UNIQUE
#  index_posts_on_trashed_at                (trashed_at)
#  posts_user_id_idx                        (user_id) WHERE (trashed_at IS NULL)
#
# Foreign Keys
#
#  fk_rails_...  (product_id => legacy_products.id)
#

class Post < ApplicationRecord
  FEATURE_STATES = %i(unfeature feature schedule).freeze
  MAX_LENGTH_NAME = 110
  MAX_LENGTH_TAGLINE = 60

  # NOTE(naman): change on frontend too when the update below numbers
  MAX_LENGTH_PROMO_TEXT = 25
  MAX_LENGTH_PROMO_CODE = 15

  extension(
    Search.searchable,
    only: :searchable,
    includes: %i(user makers topics links new_product),
  )
  extension(
    Search.searchable_association,
    association: %i(new_product),
    if: :saved_change_to_name?,
  )

  extension HandleInvalidUnicode, %i(name tagline)

  include Sluggable
  include Trashable
  include Commentable
  include ExplicitCounterCache
  include Votable
  include SlateFieldOverride
  include RandomOrder
  include Subscribeable
  include UserFlaggable
  include PgSearch::Model
  include Uploadable

  uploadable :thumbnail_image
  uploadable :social_media_image

  audited only: %i(promo_text promo_code promo_expire_at name tagline description_html scheduled_at featured_at product_state)

  pg_search_scope :search_by_name, against: :name, using: {
    trigram: {
      word_similarity: true,
    },
  }

  slate_field :description, mode: :none

  has_one :product_association, class_name: 'Products::PostAssociation', inverse_of: :post, dependent: :destroy
  # NOTE(DZ): product-name-refactor
  has_one :new_product, through: :product_association, source: :product, class_name: 'Product', inverse_of: :posts
  belongs_to :user, counter_cache: true

  has_many :links, class_name: 'LegacyProductLink', foreign_key: :post_id, inverse_of: :post
  has_one :primary_link,
          -> { primary },
          class_name: 'LegacyProductLink',
          validate: true,
          inverse_of: :post,
          foreign_key: :post_id,
          autosave: true

  has_many :link_trackers, dependent: :destroy
  has_many :moderation_logs, dependent: :destroy, as: :reference
  has_many :moderation_duplicate_post_requests, class_name: '::Moderation::DuplicatePostRequest', inverse_of: :post, dependent: :destroy

  has_many :post_topic_associations, foreign_key: :post_id, dependent: :destroy
  has_many :topics, through: :post_topic_associations, source: :topic

  has_many :golden_kitty_nominations, class_name: 'GoldenKitty::Nominee', inverse_of: :post, dependent: :destroy
  has_many :golden_kitty_finalist, class_name: 'GoldenKitty::Finalist', inverse_of: :post, dependent: :destroy

  has_many :product_makers, dependent: :destroy
  has_many :makers, foreign_key: 'user_id', through: :product_makers, source: :user
  has_many :maker_suggestions, dependent: :destroy

  has_many :collection_post_associations, dependent: :destroy
  has_many :collections, through: :collection_post_associations

  has_many :reviews, dependent: :nullify
  has_many :reviewers, foreign_key: :user_id, through: :reviews, source: :user

  has_many :positive_review_tags, -> { distinct }, through: :reviews, class_name: 'ReviewTag', source: :positive_tags
  has_many :negative_review_tags, -> { distinct }, through: :reviews, class_name: 'ReviewTag', source: :negative_tags

  has_many :maker_reports, dependent: :destroy, inverse_of: :post

  has_many :badges, as: :subject, dependent: :destroy, inverse_of: :subject

  has_many :promotions, class_name: 'PromotedProduct', inverse_of: :post, dependent: :destroy

  has_many :seo_queries, as: :subject, dependent: :destroy

  has_many :feed_items, class_name: 'Stream::FeedItem', inverse_of: :target, as: :target, dependent: :delete_all

  has_many :tracking_pixel_logs, class_name: 'TrackingPixel::Log', as: :embeddable, dependent: :destroy

  has_many :ad_campaigns, class_name: 'Ads::Campaign', inverse_of: :post, dependent: :nullify
  has_many :spam_manual_logs, class_name: '::Spam::ManualLog', as: :activity, inverse_of: :activity, dependent: :nullify
  has_many :story_mentions_associations, class_name: '::Anthologies::StoryMentionsAssociation', as: :subject, inverse_of: :subject, dependent: :destroy

  has_many :media, -> { by_priority }, dependent: :destroy, as: :subject
  has_many :questions, inverse_of: :post, dependent: :destroy

  has_many :activity_events, class_name: 'Products::ActivityEvent', as: :subject, dependent: :destroy
  has_one :twitter_follower_count, class_name: 'TwitterFollowerCount', as: :subject, dependent: :destroy

  has_one :funding_survey, inverse_of: :post, dependent: :destroy

  has_many :launch_day_reports, class_name: 'Posts::LaunchDayReport', dependent: :destroy, inverse_of: :post
  has_one :upcoming_event, class_name: 'Upcoming::Event', inverse_of: :post, dependent: :destroy
  has_many :comment_awards, class_name: 'Comments::Award', through: :comments, source: :award

  has_many :comment_prompts, inverse_of: :post, dependent: :destroy

  delegate :url, :short_code, to: :primary_link
  enum product_state: { default: 0, no_longer_online: 100, pre_launch: 200 }

  enum pricing_type: {
    free: 'free',
    free_options: 'free_options',
    payment_required: 'payment_required',
  }

  before_validation :set_defaults, on: :create
  after_commit :schedule_post_launch_mailers, on: :create
  after_commit :set_product_state, on: :update
  before_destroy :destroy_links

  validates :primary_link, presence: true
  validates :name, presence: true, length: { maximum: MAX_LENGTH_NAME }
  validates :tagline, presence: true, length: { maximum: MAX_LENGTH_TAGLINE }
  validate :featured_date_after_scheduled
  validates :promo_text, presence: true, length: { maximum: MAX_LENGTH_PROMO_TEXT }, if: -> { promo_code.present? || promo_expire_at.present? }
  validates :promo_code, presence: true, length: { maximum: MAX_LENGTH_PROMO_CODE }, if: -> { promo_text.present? || promo_expire_at.present? }

  explicit_counter_cache :votes_count, -> { votes.visible }
  explicit_counter_cache :reviews_count, -> { reviews.not_hidden }
  explicit_counter_cache :reviews_with_body_count, -> { reviews.not_hidden.with_body }
  explicit_counter_cache :reviews_with_rating_count, -> { reviews.where.not(rating: nil) }

  sluggable

  scope :with_preloads_for_api, -> { preload preload_attributes_for_api }

  scope :by_date, -> { order(arel_table[:featured_at].desc) }
  scope :by_created_at, -> { order(arel_table[:scheduled_at].desc) }
  scope :by_featured_at, -> { order('posts.featured_at DESC NULLS LAST, posts.scheduled_at') }
  scope :by_votes, -> { order(arel_table[:votes_count].desc) }
  scope :by_credible_votes, -> { order(Arel.sql('posts.credible_votes_count * posts.score_multiplier DESC')) }
  scope :by_comments_count, -> { order(arel_table[:comments_count].desc) }

  scope :searchable, -> { visible }
  scope :today, -> { where(arel_table[:scheduled_at].gt(Time.current.beginning_of_day)) }
  scope :visible, -> { not_trashed.where(arel_table[:scheduled_at].lt(Time.current)).where('featured_at IS NULL OR featured_at <= ?', Time.current) }
  scope :featured, -> { not_trashed.where(arel_table[:featured_at].lt(Time.current)) }
  scope :not_promoted, -> { visible.where(promoted_at: nil) }
  scope :not_duplicated, -> { where(accepted_duplicate: false) }
  scope :not_excluded_from_ranking, -> { where(exclude_from_ranking: false) }
  scope :successful, -> { featured.where(arel_table[:votes_count].gt(20)) }
  scope :for_date, ->(date) { where(date_arel.gt(date)) }
  scope :on_date, ->(date) { where(date_arel.between(date.beginning_of_day..date.beginning_of_day + 1.day)) }
  scope :for_featured_date, ->(date) { where_date_eq(:featured_at, date) }
  scope :for_scheduled_date, ->(date) { where_date_eq(:scheduled_at, date) }
  scope :between_dates, ->(start_date, end_date) { where_date_between(:featured_at, start_date, end_date) }
  scope :alive, -> { where.not(product_state: :no_longer_online) }
  scope :scheduled, -> { not_trashed.where(arel_table[:scheduled_at].gt(Time.current)) }
  scope :not_archived, -> { where(arel_table[:scheduled_at].gt(14.days.ago)) }

  scope :without_desciption, -> { where('description_length = 0') }
  scope :with_short_description, -> { where('description_length BETWEEN ? AND ?', 1, 50) }
  scope :with_long_description, -> { where('description_length > ?', 250) }

  class << self
    def preload_attributes_for_api
      [:makers, :topics, :links, { user: User.preload_attributes }]
    end

    def having_url(urls)
      urls = Array(urls).map { |url| UrlParser.clean_url(url) }

      joins(:links).merge(LegacyProductLink.where(clean_url: urls))
    end

    def in_topic(topic)
      joins(:post_topic_associations).where('post_topic_associations.topic_id' => topic)
    end

    def date_arel
      Arel::Nodes::NamedFunction.new(
        'coalesce',
        [arel_table[:featured_at], arel_table[:scheduled_at]],
      )
    end

    def sitemap
      main_scope = successful
        .featured
        .where.not(product_state: :no_longer_online)

      scope = main_scope.left_joins(:product_association).where(product_post_associations: { id: nil })

      scope.or(main_scope.not_archived)
    end
  end

  def state
    if trashed?
      :trashed
    elsif scheduled?
      :scheduled
    elsif featured_at.nil?
      :not_featured
    elsif featured?
      :featured
    else
      raise 'Post state unknown'
    end
  end

  def needs_moderation?
    return true if moderation_logs.empty?
    return false if user_edited_at.blank?

    user_edited_at >= moderation_logs.order(id: :desc).first.created_at
  end

  def visible?
    !trashed? && scheduled_at&.past?
  end

  def featured?
    visible? && !!featured_at&.past?
  end

  def scheduled?
    featured_at&.future? || !!scheduled_at&.future?
  end

  def visible_makers
    @visible_makers ||= makers.visible.to_a
  end

  def maker_inside?
    makers.exists?
  end

  def comment_by_submitter
    @comment ||= comments.top_level.find_by(user: user)
  end

  def date
    featured_at || scheduled_at || created_at
  end

  def refresh_review_counts
    refresh_reviews_count
    refresh_reviews_with_body_count
    refresh_reviews_with_rating_count
  end

  def post_votes
    votes
  end

  def description_text
    Sanitizers::HtmlToText.call(description)
  end

  def images
    media.where(kind: :image)
  end

  def admin_search_display_name
    "#{ name } (#{ id })"
  end

  def thumbnail_image_uuid
    self[:thumbnail_image_uuid].presence || DEFAULT_POST_THUMBNAIL_UUID
  end

  def thumbnail_url(width: 300, height: 300, fit: 'crop', format: nil)
    Image.call(
      thumbnail_image_uuid,
      width: width,
      height: height,
      fit: fit,
      format: format,
    )
  end

  def searchable_data
    Search.document(
      self,
      body: [description_text, tagline].compact.join(' '),
      related_items: (new_product&.associated_products || []).map(&:name),
      topics: topics.map(&:name),
      created_at: featured_at || scheduled_at || created_at,
      meta: {
        makers: makers.flat_map { |m| [m.name, m.username] },
        featured: featured?,
        sunset: no_longer_online?,
        url: links.map(&:url),
      },
    )
  end

  def update_reviews_rating
    new_rating = Posts::ReviewRating.star_rating(self)
    # Note(AR): We use `update_columns` to avoid validation problems, similar
    # to what `ExplicitCounterCache` does:
    update_columns(reviews_rating: new_rating, updated_at: Time.current)
  end

  def archived?
    date < 14.days.ago
  end

  def show_daily_rank?
    featured? && !exclude_from_ranking? && daily_rank.present?
  end

  def show_weekly_rank?
    featured? && !exclude_from_ranking? && weekly_rank.present?
  end

  private

  def before_trashing
    self.featured_at = nil
    collection_post_associations.delete_all
    Stream::Workers::FeedItemsCleanUp.perform_later(target: self)
    Posts::CleanUpRankingsWorker.perform_later(post: self)
  end

  def after_trashing
    return if new_product.blank?

    new_product.refresh_posts_count
    Products::RefreshActivityEvents.new(new_product).call
  end

  def set_defaults
    self.scheduled_at ||= Time.current
  end

  def featured_date_after_scheduled
    return if scheduled_at.blank?
    return if featured_at.blank?

    errors.add(:featured_at, 'must be a date after the "Scheduled At" date') if scheduled_at > featured_at
  end

  def schedule_post_launch_mailers
    Posts::ScheduleDripMails.perform_later(post: self)
  end

  def destroy_links
    # Note(AR): Links are not allowed to be destroyed if they're primary
    primary_link.update_column(:primary_link, false)
    links.destroy_all
  end

  def set_product_state
    return if new_product.blank? || !saved_change_to_product_state?

    Products.set_product_state(new_product)
  end
end
