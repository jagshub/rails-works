# frozen_string_literal: true

# == Schema Information
#
# Table name: comments
#
#  id                   :integer          not null, primary key
#  user_id              :integer
#  body                 :text
#  created_at           :datetime
#  updated_at           :datetime
#  parent_comment_id    :integer
#  subject_type         :text
#  subject_id           :integer
#  sticky               :boolean          default(FALSE), not null
#  mentioned_user_ids   :integer          default([]), is an Array
#  votes_count          :integer          default(0), not null
#  credible_votes_count :integer          default(0), not null
#  hidden_at            :datetime
#  replies_count        :integer          default(0), not null
#  user_flags_count     :integer          default(0)
#  trashed_at           :datetime
#  total_votes_count    :integer          default(0), not null
#
# Indexes
#
#  index_comments_on_credible_votes_count         (credible_votes_count)
#  index_comments_on_parent_comment_id            (parent_comment_id)
#  index_comments_on_subject_and_user_and_parent  (subject_type,subject_id,user_id,parent_comment_id)
#  index_comments_on_trashed_at                   (trashed_at)
#  index_comments_on_user_id                      (user_id)
#

class Comment < ApplicationRecord
  include Votable
  include UserFlaggable
  include Trashable
  include UserActivityTrackable

  # Note(AR): When adding a subject type here, update app/services/comments/commentable.rb
  SUBJECT_TYPES = %w(
    Anthologies::Story
    Discussion::Thread
    Goal
    Post
    ProductRequest
    Recommendation
    Review
    UpcomingPageMessage
  ).freeze
  MEDIA_LIMIT = 5

  HasTimeAsFlag.define self, :hidden, enable: :hide!, disable: :unhide!, after_action: :after_hidden_at_set

  belongs_to :user, touch: true, counter_cache: true
  belongs_to :subject, polymorphic: true, touch: true, optional: true

  belongs_to :parent, class_name: 'Comment', foreign_key: 'parent_comment_id', touch: true, optional: true, counter_cache: :replies_count
  has_many :children, -> { visible.order(created_at: :asc) }, class_name: 'Comment', foreign_key: 'parent_comment_id', dependent: :destroy
  has_many :spam_manual_logs, class_name: '::Spam::ManualLog', as: :activity, inverse_of: :activity, dependent: :nullify
  has_one :poll, dependent: :destroy, inverse_of: :subject, as: :subject
  has_one :review, dependent: :destroy, inverse_of: :comment
  has_many :feed_items, class_name: 'Stream::FeedItem', inverse_of: :target, as: :target, dependent: :delete_all
  has_many :spam_action_logs, class_name: '::Spam::ActionLog', as: :subject, inverse_of: :subject, dependent: :destroy
  has_many :media, -> { by_priority }, dependent: :destroy, as: :subject
  has_one :award, class_name: 'Comments::Award', dependent: :destroy, inverse_of: :comment

  validates :body, presence: true, length: { maximum: 8000 }
  validates :user_id, presence: true
  validates :subject, presence: true
  validates :subject_type, inclusion: { in: SUBJECT_TYPES }

  validate :not_a_child_of_a_sticky_comment

  before_validation :ensure_shallow_nesting

  before_save :persist_mentioned_user_ids

  after_commit :create_notifications, on: :create # TODO(andreasklinger): update mentions on edit
  after_commit :refresh_counters, only: %i(create destroy)
  after_commit :refresh_all_vote_counts, on: [:destroy]
  after_update :trigger_update_event

  scope :by_date, -> { order(arel_table[:created_at].desc) }
  scope :by_hidden, -> { order('comments.hidden_at ASC NULLS FIRST') }
  scope :by_sticky, -> { order(arel_table[:sticky].desc) }
  scope :sticky, -> { where(sticky: true) }
  scope :top_level, -> { where(parent_comment_id: nil) }
  scope :with_preloads, -> { preload user: User.preload_attributes }
  scope :with_preloads_for_api, -> { preload user: User.preload_attributes, children: { user: User.preload_attributes } }
  scope :mentioning, ->(user) { where('? = ANY(mentioned_user_ids)', user.id) }
  scope :created_after, ->(date) { where(arel_table[:created_at].gteq(date)) }
  scope :created_before, ->(date) { where(arel_table[:created_at].lteq(date)) }
  scope :visible, -> { not_trashed }
  scope :by_total_votes_count, -> { order(arel_table[:total_votes_count].desc) }

  delegate :name, to: :commentable, prefix: 'subject'

  class << self
    def order_by_friends(user_or_id)
      UserFriendAssociation.apply_order_by_friends(self, 'user_id', user_or_id)
    end
  end

  def as_json(options = {})
    json = super(options)
    json[:user] = { image: user.try(:image).try(:gsub, 'normal', 'reasonably_small'), name: user.try(:name), headline: user.try(:headline), username: user.try(:username) }
    json
  end

  def refresh_total_votes_count
    unless destroyed?
      new_count = votes_count + children.sum(:votes_count)
      update_columns total_votes_count: new_count, updated_at: Time.current if new_count != total_votes_count
    end

    parent&.refresh_total_votes_count
  end

  def refresh_all_vote_counts
    refresh_votes_count
    refresh_credible_votes_count
    refresh_total_votes_count
  end

  private

  # Note(andreasklinger): This is used for notifications
  def persist_mentioned_user_ids
    self.mentioned_user_ids = Notifications::Helpers::GetMentionedUserIds.for_text(body)
    self.mentioned_user_ids |= subject.makers.map(&:id) if subject_type == 'Post' && body.downcase.include?('?makers')
  end

  # Note: We only allow one-level deep nesting of comments
  def ensure_shallow_nesting
    return unless parent.present? && parent.parent.present?

    self.parent = parent.parent
  end

  def not_a_child_of_a_sticky_comment
    return unless parent.present? && parent.sticky?

    errors.add(:parent_comment_id, "can't be child of a sticky comment")
  end

  def create_notifications
    Notifications.notify_about(kind: 'mention', object: self)
    Notifications.notify_about(kind: 'ship_new_message_comment', object: self)
    Notifications.notify_about(kind: 'product_mention', object: self)
  end

  def refresh_counters
    subject.refresh_comments_count if subject.present? && subject.respond_to?(:refresh_comments_count)
  end

  def commentable
    @commentable ||= Comments::Commentable.new(subject)
  end

  def after_hidden_at_set(hidden_at)
    Stream::Workers::FeedItemsCleanUp.perform_later(target: self) if hidden_at.present?
  end

  def trigger_update_event
    Stream::Workers::FeedItemsSyncData.perform_later(target: self) if saved_change_to_attribute?(:body)
  end

  def after_trashing
    Stream::Workers::FeedItemsCleanUp.perform_later(target: self) if trashed_at.present?

    refresh_counters
  end

  def after_restoring
    refresh_counters
  end
end
