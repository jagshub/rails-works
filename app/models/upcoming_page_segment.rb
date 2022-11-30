# frozen_string_literal: true

# == Schema Information
#
# Table name: upcoming_page_segments
#
#  id               :integer          not null, primary key
#  name             :string           not null
#  trashed_at       :datetime
#  upcoming_page_id :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_upcoming_page_segments_on_upcoming_page_id  (upcoming_page_id)
#
# Foreign Keys
#
#  fk_rails_...  (upcoming_page_id => upcoming_pages.id)
#

class UpcomingPageSegment < ApplicationRecord
  include Trashable

  belongs_to :upcoming_page, inverse_of: :segments
  has_many :upcoming_page_segment_subscriber_associations, dependent: :delete_all, inverse_of: :upcoming_page_segment
  has_many :upcoming_page_subscribers, through: :upcoming_page_segment_subscriber_associations, source: :upcoming_page_subscriber
  has_many :imports, class_name: 'UpcomingPageEmailImport', dependent: :nullify, inverse_of: :upcoming_page

  validates :name, presence: true

  scope :visible, -> { not_trashed }
end
