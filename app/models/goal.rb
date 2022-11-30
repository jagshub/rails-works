# frozen_string_literal: true

# == Schema Information
#
# Table name: goals
#
#  id                   :integer          not null, primary key
#  completed_at         :datetime
#  comments_count       :integer          default(0), not null
#  user_id              :integer          not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  due_at               :datetime
#  votes_count          :integer          default(0), not null
#  credible_votes_count :integer          default(0), not null
#  maker_group_id       :integer          not null
#  social_image_url     :string
#  title_html           :text
#  current              :boolean          default(FALSE), not null
#  current_until        :datetime
#  focused_duration     :integer          default(0)
#  current_started      :datetime
#  source               :string
#  hidden_at            :datetime
#  feed_date            :date             not null
#  trending_at          :date
#
# Indexes
#
#  index_goals_on_completed_at         (completed_at)
#  index_goals_on_due_at               (due_at)
#  index_goals_on_feed_date            (feed_date) WHERE (hidden_at IS NULL)
#  index_goals_on_hidden_at            (hidden_at)
#  index_goals_on_maker_group_id       (maker_group_id)
#  index_goals_on_source               (source) WHERE (source IS NOT NULL)
#  index_goals_on_trending_at          (trending_at) WHERE ((hidden_at IS NULL) AND (trending_at IS NOT NULL))
#  index_goals_on_user_id              (user_id)
#  index_goals_on_user_id_and_current  (user_id,current) UNIQUE WHERE current
#
# Foreign Keys
#
#  fk_rails_...  (maker_group_id => maker_groups.id)
#  fk_rails_...  (user_id => users.id)
#

class Goal < ApplicationRecord
  TITLE_MAX_LENGTH = 80

  include Commentable
  include Subscribeable
  include Votable
  include SlateFieldOverride
  include RandomOrder

  HasTimeAsFlag.define self, :hidden, enable: :hide, disable: :show, after_action: :handle_activities

  slate_field :title, mode: :url_and_username

  belongs_to :group, class_name: 'MakerGroup', foreign_key: 'maker_group_id', inverse_of: :goals, touch: :last_activity_at, counter_cache: true
  belongs_to :user, inverse_of: :goals, optional: false, counter_cache: true

  has_many :moderation_logs, dependent: :destroy, as: :reference

  extension HasApiActions

  has_many :maker_activities, as: :subject, inverse_of: :subject, dependent: :delete_all

  validates :title, presence: true

  before_create :set_feed_date
  after_commit :refresh_counters, only: %i(create destroy)
  after_update :update_activity_group, if: :saved_change_to_maker_group_id?

  scope :by_completed, -> { order(completed_at: :desc) }
  scope :by_date, -> { order(arel_table[:id].desc) }
  scope :completed, -> { where(arel_table[:completed_at].not_eq(nil)) }
  scope :due, -> { where(arel_table[:due_at].not_eq(nil)) }
  scope :due_on, ->(day) { where_date_eq(:due_at, day) }
  scope :uncompleted, -> { where(arel_table[:completed_at].eq(nil)) }
  scope :overdue, -> { where.not(due_at: nil).where(arel_table[:due_at].lt(Time.current)).order('due_at DESC') }
  scope :current, -> { where(current: true).where(arel_table[:current_until].gt(Time.current)) }
  scope :current_today, -> { where(arel_table[:current_until].gt(Time.current.beginning_of_day)) }
  scope :order_by_friends, ->(user_or_id) { UserFriendAssociation.apply_order_by_friends(self, 'user_id', user_or_id) }
  scope :ordered, lambda {
    select_clause = <<-SQL
      goals.*,
      CASE
      WHEN
       completed_at < DATE_TRUNC('day', NOW() AT TIME ZONE 'PST')
       THEN NULL
      WHEN
       due_at IS NULL
         OR due_at < NOW()
       THEN DATE_TRUNC('day', NOW() AT TIME ZONE 'PST') AT TIME ZONE 'PST'
      ELSE
       due_at
      END AS "corrected_due_at"
    SQL

    select(select_clause)
      .order('corrected_due_at ASC, completed_at DESC, id ASC')
  }

  def completed?
    completed_at.present?
  end

  def due?
    due_at&.future?
  end

  def title_text
    Sanitizers::HtmlToText.call(title)
  end

  def mark_as_complete!
    now = DateTime.current
    update!(completed_at: now, feed_date: now.to_date)
  end

  def mark_as_incomplete!
    update!(completed_at: nil, feed_date: created_at.to_date)
  end

  private

  def refresh_counters
    user.refresh_completed_goals_count
    group.refresh_completed_goals_count
  end

  def handle_activities(value)
    maker_activities.update_all hidden_at: value
  end

  def update_activity_group
    maker_activities.update_all maker_group_id: maker_group_id
  end

  def set_feed_date
    self.feed_date = created_at.to_date
  end
end
