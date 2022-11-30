# frozen_string_literal: true

# == Schema Information
#
# Table name: radio_sponsors
#
#  id                     :bigint(8)        not null, primary key
#  name                   :string           not null
#  link                   :string           not null
#  image_uuid             :string           not null
#  start_datetime         :datetime         not null
#  end_datetime           :datetime         not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  image_width            :integer
#  image_height           :integer
#  image_thumbnail_width  :integer
#  image_thumbnail_height :integer
#  image_class_name       :string
#
# Indexes
#
#  index_radio_sponsors_on_start_datetime_and_end_datetime  (start_datetime,end_datetime)
#

class Radio::Sponsor < ApplicationRecord
  include Namespaceable

  validates :name, presence: true
  validates :link, presence: true
  validates :image_uuid, presence: true
  validates :start_datetime, presence: true
  validates :end_datetime, presence: true

  scope :active, ->(current = Time.zone.now) { where('start_datetime <= ? AND end_datetime > ?', current.beginning_of_day, current.end_of_day) }
end
