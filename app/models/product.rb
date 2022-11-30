# frozen_string_literal: true

# == Schema Information
#
# Table name: products
#
#  id                        :bigint(8)        not null, primary key
#  clean_url                 :string
#  website_url               :string
#  tagline                   :string           not null
#  description               :text
#  slug                      :string           not null
#  name                      :string           not null
#  reviewed                  :boolean          default(FALSE), not null
#  source                    :string           not null
#  media_count               :integer          default(0), not null
#  posts_count               :integer          default(0), not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  categories_count          :integer          default(0), not null
#  topics_count              :integer          default(0), not null
#  followers_count           :integer          default(0), not null
#  visible                   :boolean          default(TRUE), not null
#  logo_uuid                 :string
#  reviews_count             :integer          default(0), not null
#  reviews_with_body_count   :integer          default(0), not null
#  reviews_with_rating_count :integer          default(0), not null
#  reviews_rating            :decimal(3, 2)    default(0.0), not null
#  jobs_count                :integer          default(0), not null
#  alternatives_count        :integer          default(0), not null
#  twitter_url               :string
#  instagram_url             :string
#  github_url                :string
#  facebook_url              :string
#  medium_url                :string
#  angellist_url             :string
#  addons_count              :integer          default(0), not null
#  sort_key_max_votes        :integer          default(0), not null
#  total_votes_count         :integer          default(0), not null
#  related_products_count    :integer          default(0), not null
#  latest_post_at            :datetime
#  state                     :string           default("live"), not null
#  earliest_post_at          :datetime
#  user_flags_count          :integer          default(0), not null
#  trashed_at                :datetime
#  stacks_count              :integer          default(0)
#
# Indexes
#
#  index_products_on_addons_count  (addons_count)
#  index_products_on_clean_url     (clean_url) UNIQUE
#  index_products_on_created_at    (created_at)
#  index_products_on_slug          (slug) UNIQUE
#  index_products_on_trashed_at    (trashed_at)
#  index_products_on_website_url   (website_url) UNIQUE
#
class Product < ApplicationRecord
  include ExplicitCounterCache
  include Sluggable
  include Subscribeable
  include Uploadable
  include UserFlaggable
  include Trashable

  uploadable :logo

  extension(
    Search.searchable,
    includes: [:categories, { posts: :makers }, :associated_products, :topics, :links],
    only: :searchable,
  )
  extension(
    Search.searchable_association,
    association: %i(collections),
    if: :saved_change_to_name?,
  )

  sluggable

  audited only: %i(
    clean_url
    website_url
    tagline
    description
    slug
    name
    reviewed
    source
    logo_uuid
    twitter_url
    instagram_url
    github_url
    facebook_url
    medium_url
    angellist_url
    state
    posts_count
  )
  has_associated_audits

  has_many :post_associations,
           class_name: 'Products::PostAssociation',
           inverse_of: :product,
           dependent: :destroy

  has_many :story_mentions_associations, class_name: '::Anthologies::StoryMentionsAssociation', as: :subject, inverse_of: :subject, dependent: :destroy
  has_many :story_mentions, through: :story_mentions_associations, source: :story

  has_many :posts, through: :post_associations, inverse_of: :new_product
  has_many :suggested_post_drafts, class_name: '::PostDraft', inverse_of: :suggested_product, foreign_key: :suggested_product_id, dependent: :nullify
  has_many :featured_posts, -> { featured }, through: :post_associations, source: :post

  has_many :featured_topics, -> { distinct }, through: :featured_posts, source: :topics
  has_many :questions, through: :featured_posts
  has_many :reviews, -> { not_hidden }, inverse_of: :product, dependent: :destroy
  has_many :reviewers, through: :reviews, source: :user, class_name: 'User'
  has_many :positive_review_tags, -> { distinct }, through: :reviews, class_name: 'ReviewTag', source: :positive_tags
  has_many :negative_review_tags, -> { distinct }, through: :reviews, class_name: 'ReviewTag', source: :negative_tags
  has_many :review_summaries, class_name: 'Products::ReviewSummary', inverse_of: :product, dependent: :destroy
  has_many :jobs, -> { published }, inverse_of: :product, dependent: :nullify

  has_many :stacks, class_name: 'Products::Stack', inverse_of: :product, dependent: :nullify
  has_many :alternative_suggestions, class_name: 'Products::AlternativeSuggestion', foreign_key: :product, inverse_of: :product, dependent: :destroy
  has_many :reverse_alternative_suggestions, class_name: 'Products::AlternativeSuggestion', foreign_key: :alternative_product, inverse_of: :product, dependent: :destroy

  has_many :screenshots,
           class_name: 'Products::Screenshot',
           inverse_of: :product,
           dependent: :destroy

  has_many :links,
           class_name: 'Products::Link',
           inverse_of: :product,
           dependent: :destroy

  has_many :category_associations,
           class_name: 'Products::CategoryAssociation',
           inverse_of: :product,
           dependent: :destroy

  has_many :skip_review_suggestions,
           class_name: 'Products::SkipReviewSuggestion',
           inverse_of: :product,
           dependent: :destroy

  has_many :categories, through: :category_associations

  has_many :scrape_results,
           class_name: 'Products::ScrapeResult',
           inverse_of: :product,
           dependent: :destroy

  has_many :media, dependent: :destroy, as: :subject

  has_many :moderation_logs, dependent: :destroy, as: :reference

  has_many :activity_events,
           class_name: 'Products::ActivityEvent',
           dependent: :destroy,
           inverse_of: :product

  has_one :twitter_follower_count, class_name: 'TwitterFollowerCount', as: :subject, dependent: :destroy

  has_many :product_associations, class_name: 'Products::ProductAssociation', inverse_of: :product, dependent: :delete_all

  has_many :product_reverse_associations,
           class_name: 'Products::ProductAssociation',
           foreign_key: :associated_product_id,
           dependent: :delete_all

  has_many :product_topic_associations, foreign_key: :product_id, dependent: :destroy
  has_many :topics, through: :product_topic_associations, source: :topic

  has_many :associated_products, through: :product_associations, source: :associated_product

  has_many :collection_product_associations, class_name: 'Collection::ProductAssociation', inverse_of: :product, dependent: :destroy
  has_many :collections, through: :collection_product_associations

  has_many :related_product_associations, -> { related }, class_name: 'Products::ProductAssociation', inverse_of: :product
  has_many :related_products, through: :related_product_associations, source: :associated_product
  has_many :addon_associations, -> { addon }, class_name: 'Products::ProductAssociation', inverse_of: :product
  has_many :addons, through: :addon_associations, source: :associated_product
  has_many :alternative_associations, -> { alternative }, class_name: 'Products::ProductAssociation', inverse_of: :product
  has_many :alternatives, through: :alternative_associations, source: :associated_product
  has_many :founder_club_deals, -> { active }, class_name: 'FounderClub::Deal', inverse_of: :product, dependent: :nullify

  has_many :upcoming_events, class_name: 'Upcoming::Event', inverse_of: :product, dependent: :destroy
  has_many :current_upcoming_events, -> { current }, class_name: 'Upcoming::Event', inverse_of: :product
  has_one :active_upcoming_event, -> { active }, class_name: 'Upcoming::Event', inverse_of: :product

  has_many :team_members, class_name: 'Team::Member', inverse_of: :product, dependent: :destroy
  has_many :team_requests, class_name: 'Team::Request', inverse_of: :product, dependent: :destroy
  has_many :team_invites, class_name: 'Team::Invite', inverse_of: :product, dependent: :destroy

  enum source: {
    stacks: 'stacks',
    user: 'user',
    admin: 'admin',
    moderation: 'moderation',
    data_migration: 'data_migration',
    post_create: 'post_create',
    post_update: 'post_update',
    product_scraper: 'product_scraper',
  }

  enum state: {
    live: 'live',
    no_longer_online: 'no_longer_online',
  }

  validates :name, presence: true
  validates :clean_url, uniqueness: true, presence: true
  validates :website_url, url: true
  validates :angellist_url, url: true, format: /\A.*angel\.co.*\z/i, allow_blank: true
  validates :twitter_url, url: true, format: /\A.*twitter\.com.*\z/i, allow_blank: true
  validates :instagram_url, url: true, format: /\A.*instagram\.com.*\z/i, allow_blank: true
  validates :github_url, url: true, format: /\A.*github\.com.*\z/i, allow_blank: true
  validates :facebook_url, url: true, format: /\A.*facebook\.com.*\z/i, allow_blank: true
  validates :medium_url, url: true, allow_blank: true

  CORRECT_DOMAINS = {
    angellist_url: 'https://angel.co/',
    facebook_url: 'https://www.facebook.com/',
    github_url: 'https://github.com/',
    instagram_url: 'https://www.instagram.com/',
    medium_url: 'https://medium.com/',
    twitter_url: 'https://twitter.com/',
  }.freeze

  SOCIAL_LINKS = CORRECT_DOMAINS.keys

  before_save :strip_website_url_trailing_slash
  before_validation :set_clean_url
  before_validation :set_defaults

  explicit_counter_cache :posts_count, -> { posts.visible }
  explicit_counter_cache :followers_count, -> { followers }
  explicit_counter_cache :topics_count, -> { topics }
  explicit_counter_cache :media_count, -> { media }
  explicit_counter_cache :jobs_count, -> { jobs }

  explicit_counter_cache :alternatives_count, -> { alternatives }
  explicit_counter_cache :addons_count, -> { addons }
  explicit_counter_cache :related_products_count, -> { related_products }
  explicit_counter_cache :stacks_count, -> { stacks }

  def associated_products_count
    alternatives_count + addons_count + related_products_count
  end

  explicit_counter_cache :reviews_count, -> { reviews.not_hidden }
  explicit_counter_cache :reviews_with_body_count, -> { reviews.not_hidden.with_body }
  explicit_counter_cache :reviews_with_rating_count, -> { reviews.not_hidden.where.not(rating: nil) }

  scope :searchable, -> { not_trashed.live.joins(:posts).merge(Post.featured) }
  scope :reviewed, -> { where(reviewed: true) }
  scope :unreviewed, -> { where(reviewed: false) }
  scope :visible, -> { not_trashed }
  scope :with_posts, -> { where('posts_count > 0') }
  scope :scraped, -> { where(source: 'product_scraper') }
  scope :by_credible_votes, -> { order('sort_key_max_votes DESC') }
  scope :live_first, -> { order(Arel.sql("CASE state WHEN 'live' THEN 1 ELSE 0 END DESC")) }

  # NOTE(DZ) Include fields that can be used in Products::Scrapers::HTML.
  SCRAPABLE_FIELDS = %i(
    name
    tagline
    description
    categories
    images
    logos
    app_store_url
    play_store_url
    keywords
    twitter_links
    facebook_links
    instagram_links
  ).freeze

  def self.reviewed_by(user_id)
    joins(:moderation_logs).where(moderation_logs: { moderator_id: user_id })
  end

  # Note(AR): Needed for custom filter in app/admin/products.rb
  def self.ransackable_scopes(_auth_object = nil)
    [:reviewed_by]
  end

  def self.sitemap
    with_posts
      .not_trashed
      .where.not(state: :no_longer_online)
  end

  def latest_post
    featured_posts.by_created_at.first ||
      posts.visible.by_created_at.first ||
      posts.by_created_at.first
  end

  def first_post
    posts.order('posts.id ASC').first
  end

  # NOTE(DZ): Allows for manual slug input
  def should_generate_new_friendly_id?
    slug.blank?
  end

  def images
    media.where(kind: :image)
  end

  def visible_makers
    makers.reject(&:trashed?)
  end

  def makers
    User.find(find_maker_ids(featured_posts).presence || find_maker_ids(posts))
  end

  def maker_ids
    makers.pluck(:id)
  end

  def logo_uuid_with_fallback
    logo_uuid.presence || latest_post&.thumbnail_image_uuid
  end

  def thumbnail_url(width: 300, height: 300, fit: 'crop', format: nil)
    Image.call(
      logo_uuid_with_fallback,
      width: width,
      height: height,
      fit: fit,
      format: format,
      frame: 1,
    )
  end

  def badges
    # Note(Vlad): we map to_s since subject id on the badge is a string and it crashes
    Badge.where(subject_type: 'Post').where(subject_id: post_ids.map(&:to_s))
  end

  def platforms
    stores = featured_posts.joins(:links).distinct.pluck('legacy_product_links.store')
    stores = posts.joins(:links).distinct.pluck('legacy_product_links.store') if stores.blank?
    stores.map { |store| PlatformStores.find_os_for_store(store) || 'Web' }.uniq
  end

  def searchable_data
    featured_posts = posts.select(&:featured?)
    avg_votes_count =
      if featured_posts.blank?
        0
      else
        featured_posts.map(&:votes_count).sum / featured_posts.size
      end

    Search.document(
      self,
      topics: categories.map(&:name) + topics.map(&:name),
      related_items: associated_products.map(&:name),
      # TODO(DZ) ask michael if we can switch this to total_votes_count
      votes_count: avg_votes_count,
      meta: {
        url: links.map(&:url),
        last_launched_at: posts.blank? ? 0 : posts.max_by(&:date).date,
        launches: posts.map(&:name),
        makers: posts.flat_map { |post| post.makers.map { |m| [m.name, m.username] } },
        # NOTE(DZ): These fields are only to be used by Search::Query::DevProduct
        avg_votes_count: posts.blank? ? 0 : posts.sum(&:votes_count) / posts.size,
        max_votes_count: posts.max_by(&:votes_count)&.votes_count || 0,
        total_votes_count: total_votes_count,
      },
    )
  end

  def refresh_review_counts
    refresh_reviews_count
    refresh_reviews_with_body_count
    refresh_reviews_with_rating_count
  end

  def update_reviews_rating
    new_rating = Posts::ReviewRating.star_rating(self)
    # Note(AR): We use `update_columns` to avoid validation problems, similar
    # to what `ExplicitCounterCache` does:
    update_columns(reviews_rating: new_rating, updated_at: Time.current)
  end

  def update_vote_counts
    # Note(AR): We use `update_columns` to avoid validation problems, similar
    # to what `ExplicitCounterCache` does:
    update_columns(
      sort_key_max_votes: posts.maximum(:credible_votes_count) || 0,
      total_votes_count: Vote.where(subject: posts).visible.count,
      updated_at: Time.current,
    )
  end

  def update_post_timestamps
    latest_post_at = latest_post&.date
    earliest_post_at = posts.visible.by_created_at.last&.date

    update_columns(latest_post_at: latest_post_at, earliest_post_at: earliest_post_at, updated_at: Time.current)
  end

  def reviewers_for_feed(current_user: nil)
    result = current_user ? User.where(id: reviewers).order_by_friends(current_user) : reviewers.distinct
    result.by_follower_count
  end

  def positive_review_tags_for_feed
    ReviewTag
      .joins(:reviews)
      .where(reviews: { product_id: id })
      .merge(Review.not_hidden)
      .group('review_tags.id')
      .order('COUNT(review_tags.id) DESC')
  end

  def website_domain
    Addressable::URI.parse(website_url).domain.to_s
  end

  def sync_topic_associations
    self.topic_ids = posts.joins(:post_topic_associations).pluck(:topic_id).uniq
  rescue StandardError => e
    ErrorReporting.report_error e
  end

  private

  def find_maker_ids(posts)
    # Note(AR): Fetched like this to prioritise latest posts' makers first
    ProductMaker
      .where(post_id: posts.visible.select(:id))
      .order('created_at DESC')
      .group(:user_id, :created_at)
      .pluck(:user_id)
  end

  def strip_website_url_trailing_slash
    self.website_url = website_url[0..-2] if website_url&.last == '/'
  end

  def set_clean_url
    self.clean_url = ::UrlParser.clean_product_url(website_url)
  end

  def set_defaults
    SOCIAL_LINKS.each do |link|
      self[link] = Posts::CleanSocialLinks.call(name: link, value: self[link])
    end
  end
end
