# frozen_string_literal: true

# == Schema Information
#
# Table name: upcoming_events
#
#  id                 :bigint(8)        not null, primary key
#  product_id         :bigint(8)        not null
#  post_id            :bigint(8)
#  user_id            :bigint(8)        not null
#  title              :string           not null
#  description        :string           not null
#  banner_uuid        :string           not null
#  banner_mobile_uuid :string
#  active             :boolean          default(FALSE), not null
#  status             :string           default("pending"), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  user_edited_at     :datetime
#
# Indexes
#
#  index_on_upcoming_event_query_columns           (product_id,post_id,active,status) UNIQUE
#  index_upcoming_events_on_post_id                (post_id) UNIQUE
#  index_upcoming_events_on_product_id_and_active  (product_id,active) UNIQUE WHERE (active = true)
#  index_upcoming_events_on_user_id                (user_id)
#
class Upcoming::Event < ApplicationRecord
  self.ignored_columns = %i(confirmed_at rejected_at)

  include Namespaceable
  include Subscribeable
  include Uploadable

  audited except: %i(updated_at created_at)

  belongs_to :product, inverse_of: :upcoming_events
  belongs_to :post, optional: true, inverse_of: :upcoming_event
  belongs_to :user, inverse_of: :upcoming_events

  has_many :moderation_logs, dependent: :destroy, as: :reference

  validates :post_id, uniqueness: { allow_nil: true }

  uploadable :banner
  uploadable :banner_mobile

  enum status: {
    approved: 'approved',
    rejected: 'rejected',
    pending: 'pending',
  }

  scope :visible, -> { active.approved }
  scope :current, -> { approved.with_scheduled_post.or(where(post: nil)) }
  scope :with_scheduled_post, -> { left_joins(:post).merge(Post.scheduled, rewhere: true) }
  scope :active, -> { with_scheduled_post.where(active: true) }
  scope :unmoderated, -> { left_joins(:moderation_logs).where(moderation_logs: { id: nil }) }
  scope :by_closest_schedule, -> { with_scheduled_post.order('posts.scheduled_at ASC') }

  before_save :toggle_active

  def self.within_days(days)
    with_scheduled_post
      .where(Post.arel_table[:scheduled_at].lteq(days.days.from_now.end_of_day))
  end

  def self.edited_after_moderation
    left_joins(:moderation_logs)
      .group('upcoming_events.id')
      .having('MAX(moderation_logs.created_at) < upcoming_events.user_edited_at')
  end

  def first_launch?
    return false if post.nil?

    post.id == product.first_post&.id
  end

  def approve_and_notify
    return if approved?

    update!(status: :approved, active: true)
    return if post.blank? || post.trashed?

    UpcomingEventMailer.launch_schedule_confirmed(self).deliver_later
  end

  private

  def toggle_active
    return unless active_changed? && active

    product.upcoming_events.update_all(active: false)
  end
end
