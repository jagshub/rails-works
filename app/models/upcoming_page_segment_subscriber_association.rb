# frozen_string_literal: true

# == Schema Information
#
# Table name: upcoming_page_segment_subscriber_associations
#
#  id                          :integer          not null, primary key
#  upcoming_page_segment_id    :integer          not null
#  upcoming_page_subscriber_id :integer          not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#
# Indexes
#
#  upcoming_page_subscriber_assoc_segment_subscriber  (upcoming_page_segment_id,upcoming_page_subscriber_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (upcoming_page_segment_id => upcoming_page_segments.id)
#  fk_rails_...  (upcoming_page_subscriber_id => upcoming_page_subscribers.id)
#

class UpcomingPageSegmentSubscriberAssociation < ApplicationRecord
  belongs_to :upcoming_page_segment
  belongs_to :upcoming_page_subscriber

  validates :upcoming_page_subscriber_id, uniqueness: { scope: :upcoming_page_segment_id }

  validate :ensure_from_same_upcoming_page

  attr_readonly :upcoming_page_segment_id, :upcoming_page_subscriber_id

  private

  def ensure_from_same_upcoming_page
    return unless upcoming_page_segment.upcoming_page_id != upcoming_page_subscriber.upcoming_page_id

    errors.add(:upcoming_page_subscriber_id, "upcoming page isn't the same as the segments one")
  end
end
