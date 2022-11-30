# frozen_string_literal: true

# == Schema Information
#
# Table name: banners
#
#  id                 :bigint(8)        not null, primary key
#  user_id            :bigint(8)        not null
#  status             :string           default("active"), not null
#  position           :string           default("mainfeed"), not null
#  start_date         :datetime         not null
#  end_date           :datetime         not null
#  description        :text
#  desktop_image_uuid :string           not null
#  wide_image_uuid    :string           not null
#  tablet_image_uuid  :string           not null
#  mobile_image_uuid  :string           not null
#  url                :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  banner_position           (position)
#  banner_status             (status)
#  index_banners_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Banner < ApplicationRecord
  include Uploadable

  uploadable :desktop_image
  uploadable :wide_image
  uploadable :tablet_image
  uploadable :mobile_image

  belongs_to :user, inverse_of: :banners

  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :desktop_image_uuid, presence: true
  validates :wide_image_uuid, presence: true
  validates :tablet_image_uuid, presence: true
  validates :mobile_image_uuid, presence: true
  validates :url, url: true, presence: true

  validate :ensure_no_multiple_testbanners
  validate :ensure_no_overlap
  validate :ensure_startdate_gt_enddate

  enum status: {
    active: 'active',
    inactive: 'inactive',
    testing: 'testing',
  }

  enum position: {
    'mainfeed': 'mainfeed',
    'sidebar': 'sidebar',
  }

  private

  def ensure_startdate_gt_enddate
    return unless start_date.present? && end_date.present?

    errors.add :start_date, 'must be earlier than end date' if start_date > end_date
  end

  def ensure_no_multiple_testbanners
    return true if status != 'testing'

    if Banner.where('id != ? and position = ? and status = ?', id || 0, position, 'testing').count > 0
      errors.add :status, 'a test banner is already present, you could make it inactive or delete'
      return false
    end
    true
  end

  def ensure_no_overlap
    return true unless start_date.present? && end_date.present?
    return true if status == 'inactive'
    return true if status == 'testing'

    Banner.where('id != ? AND  position = ? and status NOT IN (?)', id || 0, position, ['inactive', 'testing']).find_each do |other|
      if overlaps?(other)
        errors.add :start_date, "banner duration overlaps with banner id: #{ other.id }"
        errors.add :end_date, "banner duration overlaps with banner id: #{ other.id }"
        return false
      end
    end
    true
  end

  def overlaps?(other)
    start_date <= other.end_date && other.start_date <= end_date
  end
end
