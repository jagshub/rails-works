# frozen_string_literal: true

# == Schema Information
#
# Table name: highlighted_changes
#
#  id                 :bigint(8)        not null, primary key
#  user_id            :bigint(8)        not null
#  status             :string           default("active"), not null
#  title              :string
#  body               :text
#  start_date         :datetime
#  end_date           :datetime
#  desktop_image_uuid :string
#  tablet_image_uuid  :string
#  mobile_image_uuid  :string
#  cta_text           :string
#  cta_url            :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  platform           :string           default("desktop"), not null
#
# Indexes
#
#  highlighted_change_status             (status)
#  index_highlighted_changes_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class HighlightedChange < ApplicationRecord
  include Uploadable

  uploadable :image
  uploadable :desktop_image
  uploadable :tablet_image
  uploadable :mobile_image

  belongs_to :user, inverse_of: :highlighted_changes

  validates :title, presence: true, length: { maximum: 50 }
  validates :body, presence: true, length: { maximum: 500 }
  validates :cta_text, length: { maximum: 20 }
  validates :cta_url, url: true, allow_blank: true
  validates :start_date, presence: true
  validates :end_date, presence: true

  validate :ensure_no_multiple_test_changes
  validate :ensure_no_overlap
  validate :ensure_start_date_is_before_end_date

  enum status: {
    active: 'active',
    inactive: 'inactive',
    testing: 'testing',
  }

  enum platform: {
    'desktop': 'desktop',
    'app': 'app',
  }

  private

  def ensure_start_date_is_before_end_date
    return unless start_date.present? && end_date.present?

    errors.add :start_date, 'must be earlier than end_date' if start_date > end_date
  end

  def ensure_no_multiple_test_changes
    return if status != 'testing'

    if HighlightedChange.where('id != ? and status = ? and platform = ?', id || 0, 'testing', platform).count > 0
      errors.add :status, 'a test change for this platform is already present, you can deactivate it or delete it.'
      return
    end
  end

  def ensure_no_overlap
    return unless start_date.present? && end_date.present?
    return if status == 'inactive'
    return if status == 'testing'

    HighlightedChange.where('id != ? AND platform = ? AND status NOT IN (?)', id || 0, platform, ['inactive', 'testing']).find_each do |other|
      if overlaps?(other)
        errors.add :start_date, "change duration on this platform overlaps with change id: #{ other.id }"
        errors.add :end_date, "change duration on this platform overlaps with change id: #{ other.id } with the same platform"
        return false
      end
    end
  end

  def overlaps?(other)
    start_date <= other.end_date && other.start_date <= end_date
  end
end
