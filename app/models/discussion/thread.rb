# frozen_string_literal: true

# == Schema Information
#
# Table name: discussion_threads
#
#  id                   :integer          not null, primary key
#  title                :string           not null
#  description          :text
#  comments_count       :integer          default(0), not null
#  trashed_at           :datetime
#  subject_type         :string           not null
#  subject_id           :integer          not null
#  user_id              :integer          not null
#  anonymous            :boolean          default(FALSE), not null
#  pinned               :boolean          default(FALSE), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  hidden_at            :datetime
#  social_image_url     :string
#  votes_count          :integer          default(0), not null
#  credible_votes_count :integer          default(0), not null
#  featured_at          :date
#  trending_at          :date
#  approved_at          :datetime
#  slug                 :string           not null
#  status               :string           default("pending"), not null
#
# Indexes
#
#  index_discussion_thread_on_user_subject                  (user_id,subject_id,subject_type)
#  index_discussion_threads_on_created_at                   (created_at) WHERE (hidden_at IS NULL)
#  index_discussion_threads_on_credible_votes_count         (credible_votes_count)
#  index_discussion_threads_on_featured_at                  (featured_at) WHERE ((featured_at IS NOT NULL) AND (hidden_at IS NULL))
#  index_discussion_threads_on_hidden_at                    (hidden_at)
#  index_discussion_threads_on_slug                         (slug) UNIQUE
#  index_discussion_threads_on_status                       (status)
#  index_discussion_threads_on_subject_type_and_subject_id  (subject_type,subject_id)
#  index_discussion_threads_on_title                        (title) USING gin
#  index_discussion_threads_on_trashed_at                   (trashed_at) WHERE (trashed_at IS NOT NULL)
#  index_discussion_threads_on_trending_at                  (trending_at) WHERE ((hidden_at IS NULL) AND (trending_at IS NOT NULL))
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class Discussion::Thread < ApplicationRecord
  include Namespaceable
  include Commentable
  include Subscribeable
  include Sluggable
  include Trashable
  include Votable
  include RandomOrder
  include UserActivityTrackable

  audited except: %i(votes_count comments_count)

  extension Search.searchable, only: :searchable, includes: %i(user category)

  sluggable candidate: :title

  HasTimeAsFlag.define self, :hidden, enable: :hide, disable: :show, after_action: :handle_activities

  validates :title, presence: true, length: { maximum: 100 }
  validates :user_id, presence: true
  validates :subject, presence: true

  belongs_to :subject, polymorphic: true, inverse_of: :discussions
  belongs_to :user, inverse_of: :discussion_threads

  has_many :maker_activities, as: :subject, inverse_of: :subject, dependent: :destroy
  has_many :feed_items, class_name: 'Stream::FeedItem', inverse_of: :target, as: :target, dependent: :delete_all
  has_many :spam_manual_logs, class_name: '::Spam::ManualLog', as: :activity, inverse_of: :activity, dependent: :nullify

  has_one :poll, dependent: :destroy, inverse_of: :subject, as: :subject
  has_one :change_log_entry,
          class_name: 'ChangeLog::Entry',
          inverse_of: :discussion,
          foreign_key: :discussion_thread_id,
          dependent: :nullify
  has_one :category_associations, class_name: 'Discussion::CategoryAssociation', foreign_key: :discussion_thread_id, dependent: :destroy
  has_one :category, class_name: 'Discussion::Category', through: :category_associations

  after_create :trigger_create_event, :create_maker_activity, :send_slack_notification
  after_update :trigger_update_event
  after_commit :refresh_counters, only: %i(create update destroy)

  scope :searchable, -> { approved }
  scope :visible, -> { not_hidden.not_trashed }
  scope :featured, -> { visible.where.not(featured_at: nil) }
  scope :trending, -> { visible.where(trending_at: Time.current.to_date) }
  scope :pinned, -> { visible.where(pinned: true).order(created_at: :desc) }
  scope :by_popular, -> { order(credible_votes_count: :desc) }

  enum status: {
    pending: 'pending',
    approved: 'approved',
    rejected: 'rejected',
  }

  SUBJECT_TYPES = %w(
    MakersFestival::Edition
    MakerGroup
  ).freeze

  class << self
    def graphql_type
      Graph::Types::Discussion::ThreadType
    end
  end

  def searchable_data
    Search.document(
      self,
      # NOTE(DZ): Discussion upvotes are low, boost them up at index
      votes_count: votes_count * 50,
      topics: [category&.name].compact,
      body: ActionController::Base.helpers.strip_tags(description),
    )
  end

  def beta?
    subject_type == 'MakerGroup' &&
      [MakerGroup::IOS_BETA, MakerGroup::ANDROID_BETA].include?(subject_id)
  end

  def approved?
    status == 'approved'
  end

  private

  def trigger_create_event
    ApplicationEvents.trigger(:discussion_thread_created, self)
  end

  def trigger_update_event
    Stream::Workers::FeedItemsSyncData.perform_later(target: self) if saved_change_to_attribute?(:title) || saved_change_to_attribute?(:description)
  end

  def refresh_counters
    subject.refresh_discussions_count
    category.refresh_discussion_thread_count if category.present?
  end

  def create_maker_activity
    MakerActivity.create! subject: self, activity_type: 'discussion_created', user: user, maker_group_id: subject_id if subject_type == 'MakerGroup'
  end

  def handle_activities(hidden_at)
    maker_activities.update_all hidden_at: hidden_at
    Stream::Workers::FeedItemsCleanUp.perform_later(target: self) if hidden_at.present?
  end

  def before_trashing
    Stream::Workers::FeedItemsCleanUp.perform_later(target: self)
  end

  def send_slack_notification
    Discussion::PendingSlackNotifier.send_notification(self)
  end
end
