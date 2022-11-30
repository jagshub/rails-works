# frozen_string_literal: true

# == Schema Information
#
# Table name: anthologies_stories
#
#  id                   :integer          not null, primary key
#  title                :string           not null
#  slug                 :string           not null
#  header_image_uuid    :string
#  mins_to_read         :integer          default(0)
#  description          :string
#  body_html            :text
#  user_id              :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  votes_count          :integer          default(0), not null
#  credible_votes_count :integer          default(0), not null
#  comments_count       :integer          default(0), not null
#  published_at         :datetime
#  header_image_credit  :string
#  category             :string           not null
#  featured_position    :integer
#  social_image_uuid    :string
#  author_name          :string
#  author_url           :string
#
# Indexes
#
#  index_anthologies_stories_on_credible_votes_count  (credible_votes_count)
#  index_anthologies_stories_on_featured_position     (featured_position) UNIQUE WHERE (featured_position IS NOT NULL)
#  index_anthologies_stories_on_title                 (title) USING gin
#  index_anthologies_stories_on_user_id               (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class Anthologies::Story < ApplicationRecord
  include Commentable
  include Namespaceable
  include Votable
  include Sluggable
  include Uploadable

  extension Search.searchable, only: :searchable, includes: :author

  HasTimeAsFlag.define self, :published

  sluggable

  uploadable :social_image

  enum featured_position: {
    'first_section': 0,
    'second_section': 1,
  }

  belongs_to :author, class_name: 'User',
                      foreign_key: :user_id,
                      inverse_of: :stories,
                      optional: true

  has_one :newsletter,
          inverse_of: :anthologies_story,
          foreign_key: :anthologies_story_id,
          dependent: :nullify

  has_many :related_story_associations, -> { order(position: :asc) },
           dependent: :destroy

  has_many :related_stories, class_name: 'Anthologies::Story',
                             through: :related_story_associations,
                             source: :related,
                             foreign_key: :story_id

  has_many :story_mentions_associations, class_name: '::Anthologies::StoryMentionsAssociation', foreign_key: :story_id, inverse_of: :story, dependent: :destroy
  has_many :post_mentions, through: :story_mentions_associations, source: :subject, source_type: 'Post'
  has_many :user_mentions, through: :story_mentions_associations, source: :subject, source_type: 'User'
  has_many :product_mentions, through: :story_mentions_associations, source: :subject, source_type: 'Product'

  validates :title, :author, :category, presence: true
  validates :featured_position, uniqueness: true, allow_blank: true
  validates :mins_to_read, numericality: { greater_than: 0, integer_only: true }
  validates :description, length: {
    maximum: 200,
    too_long: 'should be under 200 characters for optimized search results',
  }
  validates :title, length: {
    maximum: 80,
    too_long: 'should be under 80 characters for optimized search results',
  }

  scope :searchable, -> { published }
  scope :by_published_at, -> { order('published_at DESC') }
  scope :by_newest, -> { order(published_at: :desc, credible_votes_count: :desc) }
  scope :by_popular, -> { order(Arel.sql("DATE_PART('year', published_at) DESC"), Arel.sql("DATE_PART('month', published_at) DESC"), credible_votes_count: :desc) }
  scope :by_trending, -> { order(Arel.sql("DATE_PART('year', published_at) DESC"), Arel.sql("DATE_PART('week', published_at) DESC"), credible_votes_count: :desc) }

  enum category: {
    news: 'news',
    maker_stories: 'maker_stories',
    announcements: 'announcements',
    how_to: 'how_to',
    interviews: 'interviews',
    opinions: 'opinions',
    web3: 'web3',
  }

  class << self
    def graphql_type
      Graph::Types::Anthologies::StoryType
    end
  end

  def sluggable_candidates
    [:title, %i(title sluggable_sequence)]
  end

  def sluggable_sequence
    slug = normalize_friendly_id(title)
    counter = slug_scope.where("slug ~* '^#{ slug }(-[0-9]+)?$'").count
    counter + 1
  end

  def should_generate_new_friendly_id?
    slug.blank? || title_changed?
  end

  def searchable_data
    Search.document(
      self,
      topics: [category].compact,
      body: [description, ActionController::Base.helpers.strip_tags(body_html)],
      user: [author.name, author.username].compact,
    )
  end
end
