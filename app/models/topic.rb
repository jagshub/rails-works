# frozen_string_literal: true

# == Schema Information
#
# Table name: topics
#
#  id                         :integer          not null, primary key
#  name                       :string           not null
#  description                :string           default(""), not null
#  slug                       :string           not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  posts_count                :integer          default(0), not null
#  image_uuid                 :string
#  followers_count            :integer          default(0), not null
#  post_ids_minhash_signature :hstore
#  subscribers_count          :integer          default(0), not null
#  stories_count              :integer          default(0), not null
#  emoji                      :string
#  kind                       :integer
#  parent_id                  :bigint(8)
#
# Indexes
#
#  index_topics_on_lower(name)  (lower((name)::text)) UNIQUE
#  index_topics_on_parent_id    (parent_id)
#  index_topics_on_slug         (slug) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (parent_id => topics.id)
#

class Topic < ApplicationRecord
  include RandomOrder
  include Sluggable
  sluggable

  include Uploadable
  uploadable :image

  include ExplicitCounterCache
  include Subscribeable

  extension Search.searchable, includes: %i(aliases)

  enum kind: {
    topic: 0,
    platform: 1,
    category: 2,
  }

  CATEGORIES = [
    'Tech',
    'Games',
    'Podcasts',
    'Books',
  ].freeze

  PLATFORMS = [
    'PC',
    'Android',
    'ANDROID',
    'Xbox One',
    'PS4',
    'Vita',
    'Wii U',
    'iPhone',
    'iPad',
    'Apple Watch',
    'Linux',
    'Safari Extensions',
    'Firefox Extensions',
    'Kindle',
    'Windows',
    'Mac',
    'Browser',
    'Website',
    'PlayStation VR',
    'HTC Vive',
    'Apple TV',
    'Chrome Extensions',
  ].freeze

  extension(
    Search.searchable_association,
    association: %i(
      posts
      products
      upcoming_pages
    ),
    if: :saved_change_to_name?,
  )

  belongs_to :parent, class_name: 'Topic', inverse_of: :sub_topics, optional: true

  has_many :sub_topics, foreign_key: :parent_id, class_name: 'Topic', inverse_of: :parent
  has_many :aliases, class_name: 'TopicAlias', dependent: :delete_all
  has_many :topic_user_association, inverse_of: :topic, dependent: :delete_all

  has_many :post_topic_associations, foreign_key: :topic_id, dependent: :delete_all
  has_many :posts, through: :post_topic_associations, source: :post
  has_many :products, through: :posts, source: :new_product

  explicit_counter_cache :posts_count, -> { posts }

  has_many :upcoming_page_topic_associations, foreign_key: :topic_id, dependent: :delete_all, inverse_of: :topic
  has_many :upcoming_pages, through: :upcoming_page_topic_associations, source: :upcoming_page

  has_many :collection_topic_associations, foreign_key: :topic_id, dependent: :delete_all
  has_many :collections, through: :collection_topic_associations, source: :collection

  has_many :product_request_topic_associations, foreign_key: :topic_id, dependent: :delete_all
  has_many :product_requests, through: :product_request_topic_associations, source: :product_request

  explicit_counter_cache :stories_count, -> { anthologies_stories.published }

  has_many :golden_kitty_categories, class_name: '::GoldenKitty::Category', inverse_of: :topic, dependent: :nullify

  explicit_counter_cache :subscribers_count, -> { subscriptions }
  explicit_counter_cache :followers_count, -> { subscribers }

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  scope :by_name, -> { order(arel_table[:name].asc) }
  scope :by_date, -> { order(arel_table[:created_at].desc) }
  scope :by_followers_count, -> { order(arel_table[:followers_count].desc) }

  class << self
    def by_query(query)
      alias_query = TopicAlias.select('DISTINCT(topic_id)').where('LOWER(name) LIKE ?', LikeMatch.simple(query))
      order_query = sanitize_sql_for_order([Arel.sql('CASE WHEN LOWER(name) = ? THEN 1 ELSE 2 END'), query.strip.downcase])

      where(id: alias_query).reorder(order_query)
    end

    def by_name_or_alias(name)
      find_by(name: name) || find_by(id: TopicAlias.where(name: name).pluck(:topic_id))
    end
  end

  def platform?
    PLATFORMS.include?(name)
  end

  def refresh_counters(counters = %i(subscribers followers posts stories))
    counters.each do |counter|
      public_send("refresh_#{ counter }_count")
    end
  end

  def searchable_data
    Search.document(
      self,
      body: description,
      related_items: aliases.map(&:name),
      # NOTE(DZ): For now, give topics a very high votes count so they show up.
      # We can use followers_count later if we have a better rank function.
      votes_count: 100_000,
    )
  end
end
