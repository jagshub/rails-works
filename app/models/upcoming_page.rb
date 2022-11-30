# frozen_string_literal: true

# == Schema Information
#
# Table name: upcoming_pages
#
#  id                   :integer          not null, primary key
#  name                 :string           not null
#  slug                 :string           not null
#  hiring               :boolean
#  user_id              :integer          not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  subscriber_count     :integer          default(0), not null
#  trashed_at           :datetime
#  tagline              :string
#  featured_at          :datetime
#  widget_intro_message :string
#  webhook_url          :string
#  status               :integer          default("unlisted")
#  ab_started_at        :datetime
#  import_status        :integer          default("under_threshold")
#  ship_account_id      :integer          not null
#  seo_title            :string
#  seo_description      :string
#  seo_image_uuid       :string
#  inbox_slug           :string
#  success_html         :text
#
# Indexes
#
#  index_upcoming_pages_on_inbox_slug       (inbox_slug) UNIQUE
#  index_upcoming_pages_on_name             (name) USING gin
#  index_upcoming_pages_on_ship_account_id  (ship_account_id)
#  index_upcoming_pages_on_slug             (slug) UNIQUE
#  index_upcoming_pages_on_trashed_at       (trashed_at)
#  index_upcoming_pages_on_user_id          (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (ship_account_id => ship_accounts.id)
#

class UpcomingPage < ApplicationRecord
  extension RefreshExplicitCounterCache, :user, :upcoming_pages_count

  include Sluggable
  include ExplicitCounterCache
  include Trashable
  include RandomOrder
  include SlateFieldOverride

  extension Search.searchable, only: :searchable, includes: %i(user topics)

  slate_field :success_text, html_field: :success_html, mode: :everything

  sluggable

  MAX_LENGTH_TAGLINE = 60

  belongs_to :user
  belongs_to :account, class_name: 'ShipAccount', foreign_key: 'ship_account_id', inverse_of: :upcoming_pages

  has_many :subscribers, class_name: 'UpcomingPageSubscriber', inverse_of: :upcoming_page
  has_many :messages, class_name: 'UpcomingPageMessage', inverse_of: :upcoming_page
  has_many :conversations, class_name: 'UpcomingPageConversation'
  has_many :imports, class_name: 'UpcomingPageEmailImport', dependent: :delete_all, inverse_of: :upcoming_page
  has_many :confirmed_subscribers, -> { confirmed }, class_name: 'UpcomingPageSubscriber'
  has_many :contacts, through: :confirmed_subscribers, class_name: 'ShipContact'
  has_many :users, through: :contacts, class_name: 'User'
  has_many :links, class_name: 'UpcomingPageLink', inverse_of: :upcoming_page, dependent: :delete_all

  has_many :upcoming_page_topic_associations, dependent: :delete_all, inverse_of: :upcoming_page

  has_many :topics, through: :upcoming_page_topic_associations, source: :topic
  has_many :variants, class_name: 'UpcomingPageVariant', dependent: :delete_all, inverse_of: :upcoming_page
  has_many :segments, -> { visible }, class_name: 'UpcomingPageSegment', dependent: :delete_all, inverse_of: :upcoming_page
  has_many :surveys, -> { not_trashed }, class_name: 'UpcomingPageSurvey', dependent: :destroy, inverse_of: :upcoming_page
  has_many :subscriber_searches, class_name: 'UpcomingPageSubscriberSearch', dependent: :delete_all, inverse_of: :upcoming_page
  has_many :maker_tasks, class_name: 'UpcomingPageMakerTask', dependent: :delete_all, inverse_of: :upcoming_page

  has_many :moderation_logs, dependent: :destroy, inverse_of: :reference, as: :reference
  has_many :tracking_pixel_logs, class_name: 'TrackingPixel::Log', as: :embeddable, dependent: :destroy

  has_one :ship_subscription, through: :user

  scope :searchable, -> { not_trashed }
  scope :featured, -> { visible.promoted.where(arel_table[:featured_at].lt(Time.current)) }
  scope :by_created_at, -> { order(created_at: :desc) }
  scope :by_featured_at, -> { order('featured_at DESC NULLS LAST, created_at DESC') }
  scope :visible, -> { not_trashed }
  scope :pending_featuring, -> { promoted.where(featured_at: nil) }

  validates :name, presence: true
  validates :tagline, allow_nil: true, length: { maximum: MAX_LENGTH_TAGLINE }
  validates :import_status, presence: true
  validates :inbox_slug, uniqueness: { allow_blank: true }

  validates :webhook_url, url: true, allow_blank: true

  before_validation :clear_inbox_slug

  validate :validate_inbox_slug

  enum status: {
    unlisted: 0,
    promoted: 100,
  }

  enum import_status: {
    under_threshold: 0,
    over_threshold: 100,
    reviewed_imports: 200,
  }

  explicit_counter_cache :subscriber_count, -> { subscribers.confirmed }

  delegate :maintainers, to: :account

  delegate(
    :who_text,
    :what_text,
    :why_text,
    :brand_color,
    :logo_uuid,
    :background_image_uuid,
    :unsplash_background_url,
    :thumbnail_uuid,
    to: :default_variant,
    allow_nil: true,
  )

  class << self
    def for_maintainers(user)
      user_id = user.id.to_i
      from(%(
        (
          SELECT upcoming_pages.* FROM upcoming_pages
            JOIN ship_accounts
              ON ship_accounts.id = upcoming_pages.ship_account_id
             AND ship_accounts.user_id = #{ user_id }
          UNION ALL
          SELECT upcoming_pages.* FROM upcoming_pages
            JOIN ship_accounts
              ON ship_accounts.id = upcoming_pages.ship_account_id
            JOIN ship_account_member_associations
              ON ship_account_member_associations.ship_account_id = ship_accounts.id
             AND ship_account_member_associations.user_id = #{ user_id }
       ) upcoming_pages
      ))
    end

    def for_listing
      slugs = Rails.configuration.settings.array(:upcoming_pages_pinned)

      return featured if slugs.blank?

      ids = UpcomingPage.where(slug: slugs).pluck(:id)

      return featured if ids.blank?

      order_sql = sanitize_sql(["array_position(array[#{ ids.map(&:to_i).join(',') }], #{ table_name }.id)"])
      featured.or(where(id: ids)).order(Arel.sql(order_sql))
    end
  end

  def sluggable_candidates
    [:name, %i(name sluggable_sequence)]
  end

  def topic_ids
    upcoming_page_topic_associations.pluck(:topic_id)
  end

  def subscribers_between(start_time, end_time)
    confirmed_subscribers.not_imported.between_dates(start_time, end_time)
  end

  def variant(kind)
    variants.by_kind(kind).first
  end

  def default_variant
    variants.order_by_kind.first
  end

  def inbox_email
    "#{ inbox_slug.presence || slug }@ship.producthunt.com"
  end

  def searchable_data
    Search.document(self)
  end

  private

  def clear_inbox_slug
    self.inbox_slug = nil if inbox_slug.blank?
  end

  def validate_inbox_slug
    return if inbox_slug.blank?

    errors.add :inbox_slug, "shouldn't include @" if inbox_slug.include?('@')
    errors.add :inbox_slug, :taken if self.class.where(slug: inbox_slug).any?
  end
end
