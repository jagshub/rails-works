# frozen_string_literal: true

# == Schema Information
#
# Table name: votes
#
#  id               :integer          not null, primary key
#  subject_type     :text             not null
#  subject_id       :integer          not null
#  user_id          :integer          not null
#  credible         :boolean          default(TRUE), not null
#  sandboxed        :boolean          default(FALSE), not null
#  created_at       :datetime
#  updated_at       :datetime
#  source           :string
#  source_component :string
#
# Indexes
#
#  index_votes_on_created_at                                (created_at)
#  index_votes_on_source                                    (source) WHERE (source IS NOT NULL)
#  index_votes_on_subject_type_and_subject_id_and_credible  (subject_type,subject_id,credible)
#  index_votes_on_updated_at                                (updated_at)
#  index_votes_on_user_id_and_subject_type_and_subject_id   (user_id,subject_type,subject_id) UNIQUE
#

class Vote < ApplicationRecord
  SUBJECT_TYPES = %w(
    Comment
    Goal
    Post
    Recommendation
    RecommendedProduct
    Review
    Shoutout
    Anthologies::Story
    ChangeLog::Entry
    Discussion::Thread
    MakersFestival::Participant
    Products::ProductAssociation
  ).freeze

  MOBILE_SUBJECT_TYPES = %w(
    Comment
    Post
    Anthologies::Story
    Discussion::Thread
    Review
  ).freeze

  belongs_to :user, touch: true
  belongs_to :subject, polymorphic: true, touch: true

  extension HasApiActions

  extension RefreshExplicitCounterCache, :user, :votes_count

  has_one :vote_info, dependent: :destroy
  has_many :check_results, class_name: 'VoteCheckResult', dependent: :destroy
  has_many :spam_action_logs, class_name: '::Spam::ActionLog', as: :subject, inverse_of: :subject, dependent: :destroy
  has_many :spam_manual_logs, class_name: '::Spam::ManualLog', as: :activity, inverse_of: :activity, dependent: :nullify

  validates :user_id, presence: true, uniqueness: { scope: %i(subject_type subject_id) }

  after_commit :clean_notifications, on: %i(create update)
  scope :visible, -> { where(sandboxed: false) }
  scope :credible, -> { where(credible: true) }
  scope :by_date, -> { order(arel_table[:created_at].desc) }

  scope :created_after, ->(time) { where(arel_table[:created_at].gteq(time)) }
  scope :created_before, ->(time) { where(arel_table[:created_at].lteq(time)) }
  scope :updated_after, ->(time) { where(arel_table[:updated_at].gteq(time)) }

  # NOTE(rstankov): Adds subject related scopes like: for_comments, for_posts
  Votable.scopes self, class_names: %w(Comment Post)

  class << self
    def order_by_friends(user_or_id)
      UserFriendAssociation.apply_order_by_friends(self, 'user_id', user_or_id)
    end

    def as_seen_by(user)
      return visible if user.nil? || !Spam::User.sandboxed_user?(user)

      where arel_table[:sandboxed].eq(false).or(arel_table[:user_id].eq(user.id))
    end
  end

  private

  def clean_notifications
    Stream::Workers::FeedItemsCleanUp.perform_later(target: self) if sandboxed && previous_changes['sandboxed'].present?
  end
end
