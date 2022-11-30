# frozen_string_literal: true

# == Schema Information
#
# Table name: reviews
#
#  id                   :integer          not null, primary key
#  user_id              :integer          not null
#  sentiment            :integer
#  votes_count          :integer          default(0), not null
#  credible_votes_count :integer          default(0), not null
#  created_at           :datetime
#  updated_at           :datetime
#  score_multiplier     :float            default(1.0), not null
#  score                :integer          default(0), not null
#  usage_duration       :integer
#  comments_count       :integer          default(0), not null
#  pros_html            :text
#  cons_html            :text
#  body_html            :text
#  hidden_at            :datetime
#  comment_id           :bigint(8)
#  rating               :integer
#  overall_experience   :string
#  currently_using      :integer
#  product_id           :bigint(8)
#  version              :integer          default(2), not null
#  user_flags_count     :integer          default(0), not null
#  post_id              :bigint(8)
#
# Indexes
#
#  index_reviews_on_comment_id              (comment_id)
#  index_reviews_on_credible_votes_count    (credible_votes_count)
#  index_reviews_on_post_id                 (post_id)
#  index_reviews_on_product_id_and_user_id  (product_id,user_id)
#  index_reviews_on_user_id                 (user_id)
#  index_reviews_on_votes_count             (votes_count)
#
# Foreign Keys
#
#  fk_rails_...  (comment_id => comments.id)
#  fk_rails_...  (post_id => posts.id)
#

class Review < ApplicationRecord
  VERSION_WITH_PROS_CONS = 1
  VERSION_WITH_SENTIMENT = 2
  VERSION_WITH_RATING = 3

  include Votable
  include Commentable
  include UserFlaggable
  include UserActivityTrackable

  HasTimeAsFlag.define self, :hidden, enable: :hide!, disable: :unhide!, after_action: :after_hidden_at_set

  belongs_to :user
  belongs_to :product, optional: true
  belongs_to :post, inverse_of: :reviews, optional: true
  belongs_to :comment, inverse_of: :review, optional: true
  has_many :flags, as: :subject, dependent: :destroy

  has_many :tag_associations, class_name: 'ReviewTagAssociation', inverse_of: :review, dependent: :destroy
  has_many :positive_tag_associations, -> { positive }, class_name: 'ReviewTagAssociation', inverse_of: :review
  has_many :negative_tag_associations, -> { negative }, class_name: 'ReviewTagAssociation', inverse_of: :review

  has_many :review_summary_associations, class_name: 'Products::ReviewSummaryAssociation', dependent: :destroy
  has_many :summaries, through: :review_summary_associations

  has_many :positive_tags, through: :positive_tag_associations, class_name: 'ReviewTag', source: :tag
  has_many :negative_tags, through: :negative_tag_associations, class_name: 'ReviewTag', source: :tag

  validates :rating, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 5, only_integer: true, allow_nil: true }

  validates :version, numericality: { greater_than_or_equal_to: VERSION_WITH_PROS_CONS, less_than_or_equal_to: VERSION_WITH_RATING, only_integer: true, allow_nil: true }

  enum currently_using: {
    yes: 100,
    no: 200,
    previously_used: 300,
  }

  # Note(AR): Legacy
  enum sentiment: {
    negative: 100,
    neutral: 200,
    positive: 300,
  }

  # TODO(AR): Legacy enough to archive
  enum usage_duration: {
    never_used: 0,
    for_1_day: 200,
    for_1_week: 300,
    for_1_month: 400,
    for_1_year: 500,
  }

  scope :with_sentiment, -> { where.not(sentiment: nil) }
  scope :with_rating, -> { where.not(rating: nil) }
  scope :with_comment, -> { where(arel_table[:comment_id].not_eq(nil)) }
  scope :with_body, -> { with_comment.or(with_rating.where.not(overall_experience: nil)) }
  scope :with_body_for_mobile, -> { where.not(overall_experience: nil).or(where.not(body_html: nil)) }

  scope :with_hidden_reviews_at_end, -> { order(arel_table[:hidden_at].desc) }
  scope :by_rating, -> { order(Arel.sql('rating IS NOT NULL DESC, overall_experience IS NOT NULL DESC')) }
  scope :by_credible_votes_count_ranking, -> { order(Arel.sql('(reviews.credible_votes_count * reviews.score_multiplier) DESC')) }
  scope :by_score, -> { order(Arel.sql('(reviews.score * reviews.score_multiplier) DESC')) }

  scope :created_after, ->(date) { where(arel_table[:created_at].gteq(date)) }
  scope :created_before, ->(date) { where(arel_table[:created_at].lteq(date)) }

  def self.with_query(query)
    left_joins(:comment)
    .where('overall_experience ILIKE :query OR body_html ILIKE :query OR comments.body ILIKE :query',
           query: LikeMatch.by_words(query))
  end

  before_create :compute_score
  before_update :compute_score
  after_create :refresh_subjects
  after_update :refresh_subjects, :trigger_update_event
  after_destroy :refresh_subjects

  def body
    overall_experience || body_html
  end

  def comment_body
    comment&.body
  end

  def refresh_subjects
    post&.refresh_review_counts
    post&.update_reviews_rating

    product&.refresh_review_counts
    product&.update_reviews_rating
  end

  def compute_score
    self.score = Reviews::Scoring.new(self).score
  end

  private

  def after_hidden_at_set(value)
    Stream::Workers::FeedItemsCleanUp.perform_later(target: self) if value.present?
  end

  def trigger_update_event
    Stream::Workers::FeedItemsSyncData.perform_later(target: self) if saved_change_to_attribute?(:overall_experience) || saved_change_to_attribute?(:body_html) || saved_change_to_attribute?(:rating)
  end
end
