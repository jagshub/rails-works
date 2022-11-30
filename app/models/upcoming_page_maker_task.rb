# frozen_string_literal: true

# == Schema Information
#
# Table name: upcoming_page_maker_tasks
#
#  id                   :integer          not null, primary key
#  kind                 :string           not null
#  upcoming_page_id     :integer          not null
#  completed_at         :datetime
#  completed_by_user_id :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_upcoming_page_maker_tasks_on_completed_by_user_id  (completed_by_user_id)
#  index_upcoming_page_maker_tasks_on_upcoming_page_id      (upcoming_page_id)
#

class UpcomingPageMakerTask < ApplicationRecord
  belongs_to :upcoming_page, optional: false
  belongs_to :completed_by_user, class_name: 'User', foreign_key: :completed_by_user_id, optional: true

  validates :kind, presence: true, uniqueness: { scope: :upcoming_page_id }
  validate :existing_kind

  scope :completed, -> { where.not(completed_at: nil) }
  scope :pending, -> { where(completed_at: nil) }

  delegate :title, :description, :url, to: :task

  def task
    @task ||= UpcomingPages::MakerTasks.const_get(kind).new(upcoming_page, self)
  end

  def complete
    update!(completed_at: Time.zone.now)
  end

  private

  def existing_kind
    Module.const_get("UpcomingPages::MakerTasks::#{ kind }")
  rescue NameError
    errors.add(:kind, 'invalid')
  end
end
