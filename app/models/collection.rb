# frozen_string_literal: true

# == Schema Information
#
# Table name: collections
#
#  id                         :integer          not null, primary key
#  user_id                    :integer          not null
#  slug                       :string(255)      not null
#  name                       :string(255)      not null
#  title                      :string(255)
#  created_at                 :datetime
#  updated_at                 :datetime
#  featured_at                :datetime
#  subscriber_count           :integer          default(0), not null
#  last_post_added_at         :datetime
#  post_ids_minhash_signature :hstore
#  image_uuid                 :string
#  intro_html                 :text
#  recap_html                 :text
#  personal                   :boolean          default(FALSE), not null
#  description                :text
#  products_count             :integer          default(0), not null
#  last_product_added_at      :datetime
#
# Indexes
#
#  index_collections_on_featured_at       (featured_at)
#  index_collections_on_slug              (slug) UNIQUE WHERE (featured_at IS NOT NULL)
#  index_collections_on_slug_and_user_id  (slug,user_id) UNIQUE
#  index_collections_on_user_id           (user_id)
#

class Collection < ApplicationRecord
  include Sluggable
  include RandomOrder
  include ExplicitCounterCache

  self.ignored_columns = %i(intro_html recap_html)

  extension(
    Search.searchable,
    includes: %i(user products),
    only: :searchable,
  )

  include Uploadable
  uploadable :image

  belongs_to :user, counter_cache: :collections_count

  has_one :user_with_default, class_name: 'User', inverse_of: :default_collection, foreign_key: :default_collection_id, dependent: :nullify

  has_many :collection_post_associations, dependent: :destroy, inverse_of: :collection
  has_many :posts, through: :collection_post_associations

  has_many :collection_product_associations, class_name: 'Collection::ProductAssociation', dependent: :destroy, inverse_of: :collection
  has_many :products, through: :collection_product_associations, counter_cache: :products_count

  has_many :recently_added_posts, -> { where('collection_post_associations.created_at > ?', Collection.recently_added_posts_period) }, through: :collection_post_associations, source: :post

  has_many :subscriptions, class_name: 'CollectionSubscription', dependent: :destroy
  has_many :subscribed_subscriptions, -> { subscribed }, class_name: 'CollectionSubscription'
  has_many :subscribers, through: :subscribed_subscriptions, source: :user

  has_many :similar_collection_associations, dependent: :destroy, inverse_of: :collection
  has_many :similar_collections, through: :similar_collection_associations

  has_many :collection_topic_associations, dependent: :delete_all, inverse_of: :collection
  has_many :topics, through: :collection_topic_associations, source: :topic

  validates :name, presence: true, length: { maximum: 80 }
  validates :title, length: { maximum: 255 }
  validates :description, length: { maximum: 800 }

  friendly_id :sluggable_candidates, use: %i(slugged history), routes: :default
  validates :slug, uniqueness: { scope: :user_id }
  validates :slug, uniqueness: true, if: -> { featured_at.present? }

  scope :with_preloads, -> { preload preload_attributes }
  scope :by_date, -> { order(arel_table[:created_at].desc) }
  scope :by_feature_date, -> { order('featured_at DESC NULLS LAST') }
  scope :by_update_date, -> { order(updated_at: :desc) }
  scope :by_subscriber_count, -> { order(subscriber_count: :desc) }

  scope :visible, ->(current_user = nil) { where(personal: false).or(where(user_id: current_user&.id)) }
  scope :featured, -> { where(arel_table[:featured_at].lt(Time.current)) }
  scope :published, -> { where(arel_table[:featured_at].lt(Time.current).or(arel_table[:featured_at].eq(nil))) }
  scope :searchable, -> { where(arel_table[:products_count].gteq(5)).where(personal: false).where.not(slug: 'save-for-later').where.not(name: 'Save for Later') }

  scope :with_recently_added_posts, -> { where(arel_table[:last_post_added_at].gt(Collection.recently_added_posts_period)) }

  explicit_counter_cache :subscriber_count, -> { subscriptions.subscribed }

  class << self
    def preload_attributes
      [{ user: User.preload_attributes }]
    end

    def recently_added_posts_period
      2.days.ago
    end

    def default_curator
      ProductHunt.user
    end

    def default_curator_name
      ProductHunt.username
    end

    def for_curator(user: nil, user_id: nil)
      return none if user.nil? && user_id.nil?

      user_id ||= user.id

      where(user_id: user_id)
    end

    def saved_for_later
      find_by slug: 'save-for-later'
    end
  end

  def background_image_banner_url
    Image.call background_image_uuid
  end

  def background_image_uuid
    image_uuid
  end

  def new_post_added!
    update!(last_post_added_at: Time.zone.now)
  end

  def product_added
    update!(last_product_added_at: Time.zone.now)
  end

  def cache_key
    ActiveSupport::Cache.expand_cache_key(super, posts)
  end

  def owner?(user)
    user_id == user.id
  end

  def curator?(user)
    owner?(user)
  end

  def default_curator?
    user.username == self.class.default_curator_name
  end

  def without_curator?
    user.blank? || default_curator?
  end

  def featured?
    featured_at.present? && featured_at < Time.current
  end

  # Note(vlad): Neets to be deprecated and removed
  def posts_count
    @posts_count ||= posts.count
  end

  def should_generate_new_friendly_id?
    name_changed? || slug.blank? ||
      (featured_at_changed? && featured_at_before_last_save.nil?)
  end

  def sluggable_candidates
    [:name, %i(name sluggable_sequence)]
  end

  def sluggable_sequence
    slug = normalize_friendly_id(name)
    scope = slug_scope.where("slug ~* '^#{ slug }-([0-9]+)?$'").where.not(id: id)

    if featured_at.present?
      scope.where.not(featured_at: nil).count + 1
    else
      scope.where(user_id: user_id).count + 1
    end
  end

  def searchable_data
    Search.document(
      self,
      meta: {
        products: products.map(&:name),
        updated_at: updated_at,
      },
    )
  end
end
