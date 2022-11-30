# frozen_string_literal: true

# == Schema Information
#
# Table name: upcoming_page_email_imports
#
#  id                       :integer          not null, primary key
#  state                    :integer          default("pending"), not null
#  payload_csv              :binary
#  upcoming_page_id         :integer          not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  emails_count             :integer          default(0)
#  upcoming_page_segment_id :integer
#  failed_count             :integer          default(0), not null
#  imported_count           :integer          default(0), not null
#  duplicated_count         :integer          default(0), not null
#
# Indexes
#
#  index_upcoming_page_email_imports_on_upcoming_page_id  (upcoming_page_id)
#
# Foreign Keys
#
#  fk_rails_...  (upcoming_page_segment_id => upcoming_page_segments.id)
#

class UpcomingPageEmailImport < ApplicationRecord
  belongs_to :upcoming_page, inverse_of: :imports
  belongs_to :segment, class_name: 'UpcomingPageSegment', foreign_key: 'upcoming_page_segment_id', inverse_of: :imports, optional: true

  enum state: {
    pending: 0,
    completed: 100,
    failed: 200,
    rejected: 300,
    in_review: 400,
    reviewed: 500,
  }

  validates :payload_csv, presence: true
end
